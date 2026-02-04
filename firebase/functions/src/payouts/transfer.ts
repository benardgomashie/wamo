import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import axios from 'axios';

const db = admin.firestore();

// Paystack Transfer API configuration
const PAYSTACK_SECRET_KEY = functions.config().paystack?.secret_key;
const PAYSTACK_TRANSFER_URL = 'https://api.paystack.co/transfer';
const PAYSTACK_RECIPIENT_URL = 'https://api.paystack.co/transferrecipient';

interface TransferRecipient {
  type: 'mobile_money';
  name: string;
  account_number: string;
  bank_code: string; // Mobile Money network code
  currency: 'GHS';
}

/**
 * Initiates a payout request for a campaign
 * Called by campaign creators when they want to withdraw funds
 */
export const requestPayout = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { campaignId, momoNumber, momoNetwork } = data;

  if (!campaignId || !momoNumber || !momoNetwork) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
  }

  const userId = context.auth.uid;

  try {
    // Get campaign details
    const campaignDoc = await db.collection('campaigns').doc(campaignId).get();
    if (!campaignDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Campaign not found');
    }

    const campaign = campaignDoc.data()!;

    // Verify ownership
    if (campaign.ownerId !== userId) {
      throw new functions.https.HttpsError('permission-denied', 'Not campaign owner');
    }

    // Check campaign status
    if (campaign.status === 'frozen') {
      throw new functions.https.HttpsError('failed-precondition', 'Campaign is frozen');
    }

    // Check if campaign has ended or reached goal
    const now = new Date();
    const endDate = campaign.endDate?.toDate();
    const hasEnded = endDate && endDate < now;
    const hasReachedGoal = campaign.raisedAmount >= campaign.targetAmount;

    if (!hasEnded && !hasReachedGoal) {
      throw new functions.https.HttpsError(
        'failed-precondition', 
        'Campaign must end or reach goal before payout'
      );
    }

    // Check if there are sufficient funds (must have at least raised something)
    if (campaign.raisedAmount <= 0) {
      throw new functions.https.HttpsError('failed-precondition', 'No funds available for payout');
    }

    // Check if payout already exists for this campaign
    const existingPayout = await db.collection('payouts')
      .where('campaignId', '==', campaignId)
      .where('status', 'in', ['pending_review', 'approved', 'processing', 'completed'])
      .get();

    if (!existingPayout.empty) {
      throw new functions.https.HttpsError('already-exists', 'Payout already requested');
    }

    // Calculate payout amount (platform fee already deducted from donations)
    // raisedAmount is the net amount after all fees were collected from donors
    const payoutAmount = campaign.raisedAmount;
    const platformFeeCollected = campaign.totalFees || 0; // Total platform fees collected

    // Get user details
    const userDoc = await db.collection('users').doc(userId).get();
    const user = userDoc.data()!;

    // Determine initial status based on user verification and history
    let initialStatus = 'pending_review'; // Default: manual review for first-time creators

    // Check if user has had successful payouts before
    const previousPayouts = await db.collection('payouts')
      .where('creatorId', '==', userId)
      .where('status', '==', 'completed')
      .get();

    // Auto-approve for verified creators with successful payout history
    if (user.isVerified && !previousPayouts.empty) {
      initialStatus = 'approved';
    }

    // Create payout record
    const payoutData = {
      campaignId,
      creatorId: userId,
      amount: payoutAmount,
      platformFeeDeducted: platformFeeCollected,
      status: initialStatus,
      recipientMomoNumber: momoNumber,
      recipientMomoNetwork: momoNetwork,
      requestedAt: admin.firestore.FieldValue.serverTimestamp(),
      retryCount: 0,
    };

    const payoutRef = await db.collection('payouts').add(payoutData);

    // Update campaign payout status
    await campaignDoc.ref.update({
      payoutStatus: initialStatus,
      payoutId: payoutRef.id,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // If auto-approved, trigger transfer immediately
    if (initialStatus === 'approved') {
      await processPayoutTransfer(payoutRef.id);
    }

    return {
      success: true,
      payoutId: payoutRef.id,
      status: initialStatus,
      amount: payoutAmount,
      message: initialStatus === 'approved' 
        ? 'Payout approved and processing'
        : 'Payout submitted for review',
    };
  } catch (error: any) {
    console.error('Error requesting payout:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

/**
 * Approves a pending payout (admin only)
 */
export const approvePayout = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  // Verify admin role
  const userDoc = await db.collection('users').doc(context.auth.uid).get();
  if (!userDoc.exists || userDoc.data()?.role !== 'admin') {
    throw new functions.https.HttpsError('permission-denied', 'Admin access required');
  }

  const { payoutId, notes } = data;

  if (!payoutId) {
    throw new functions.https.HttpsError('invalid-argument', 'Payout ID required');
  }

  try {
    const payoutDoc = await db.collection('payouts').doc(payoutId).get();
    if (!payoutDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Payout not found');
    }

    const payout = payoutDoc.data()!;

    if (payout.status !== 'pending_review') {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'Only pending payouts can be approved'
      );
    }

    // Update payout status
    await payoutDoc.ref.update({
      status: 'approved',
      approvedBy: context.auth.uid,
      approvedAt: admin.firestore.FieldValue.serverTimestamp(),
      adminNotes: notes || null,
    });

    // Log admin action
    await db.collection('admin_logs').add({
      action: 'approve_payout',
      payoutId,
      campaignId: payout.campaignId,
      adminId: context.auth.uid,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      notes,
    });

    // Trigger transfer
    await processPayoutTransfer(payoutId);

    return { success: true, message: 'Payout approved and processing initiated' };
  } catch (error: any) {
    console.error('Error approving payout:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

/**
 * Processes an approved payout by initiating Paystack transfer
 */
async function processPayoutTransfer(payoutId: string): Promise<void> {
  const payoutDoc = await db.collection('payouts').doc(payoutId).get();
  if (!payoutDoc.exists) {
    throw new Error('Payout not found');
  }

  const payout = payoutDoc.data()!;

  try {
    // Step 1: Create transfer recipient if not exists
    let recipientCode = payout.paystackRecipientCode;

    if (!recipientCode) {
      // Map network name to Paystack bank code
      const bankCode = getMomoNetworkCode(payout.recipientMomoNetwork);

      const recipientData: TransferRecipient = {
        type: 'mobile_money',
        name: payout.recipientMomoNumber, // Paystack uses number as name for MoMo
        account_number: payout.recipientMomoNumber,
        bank_code: bankCode,
        currency: 'GHS',
      };

      const recipientResponse = await axios.post(
        PAYSTACK_RECIPIENT_URL,
        recipientData,
        {
          headers: {
            Authorization: `Bearer ${PAYSTACK_SECRET_KEY}`,
            'Content-Type': 'application/json',
          },
        }
      );

      if (!recipientResponse.data.status) {
        throw new Error(`Failed to create recipient: ${recipientResponse.data.message}`);
      }

      recipientCode = recipientResponse.data.data.recipient_code;

      // Save recipient code
      await payoutDoc.ref.update({ paystackRecipientCode: recipientCode });
    }

    // Step 2: Initiate transfer
    // Convert amount to pesewas (Paystack uses smallest currency unit)
    const amountInPesewas = Math.round(payout.amount * 100);

    const transferData = {
      source: 'balance',
      amount: amountInPesewas,
      recipient: recipientCode,
      reason: `Payout for campaign ${payout.campaignId}`,
      reference: `payout_${payoutId}_${Date.now()}`,
    };

    const transferResponse = await axios.post(
      PAYSTACK_TRANSFER_URL,
      transferData,
      {
        headers: {
          Authorization: `Bearer ${PAYSTACK_SECRET_KEY}`,
          'Content-Type': 'application/json',
        },
      }
    );

    if (!transferResponse.data.status) {
      throw new Error(`Transfer initiation failed: ${transferResponse.data.message}`);
    }

    const transferCode = transferResponse.data.data.transfer_code;

    // Update payout status to processing
    await payoutDoc.ref.update({
      status: 'processing',
      paystackTransferCode: transferCode,
      initiatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Update campaign payout status
    await db.collection('campaigns').doc(payout.campaignId).update({
      payoutStatus: 'processing',
    });

    console.log(`Transfer initiated for payout ${payoutId}: ${transferCode}`);
  } catch (error: any) {
    console.error(`Error processing transfer for payout ${payoutId}:`, error);

    // Update payout to failed status
    await payoutDoc.ref.update({
      status: 'failed',
      failureReason: error.message || 'Transfer processing failed',
      retryCount: admin.firestore.FieldValue.increment(1),
    });

    throw error;
  }
}

/**
 * Maps Mobile Money network name to Paystack bank code
 */
function getMomoNetworkCode(network: string): string {
  const networkMap: { [key: string]: string } = {
    'MTN': 'MTN',
    'Vodafone': 'VOD',
    'AirtelTigo': 'ATL',
  };

  const code = networkMap[network];
  if (!code) {
    throw new Error(`Unsupported Mobile Money network: ${network}`);
  }

  return code;
}

/**
 * Handles Paystack transfer webhook
 * Updates payout status based on transfer success/failure
 */
export const paystackTransferWebhook = functions.https.onRequest(async (req, res) => {
  // Verify Paystack signature
  const hash = req.headers['x-paystack-signature'];
  const secret = PAYSTACK_SECRET_KEY;

  if (!hash || !secret) {
    return res.status(401).send('Unauthorized');
  }

  const crypto = require('crypto');
  const expectedHash = crypto
    .createHmac('sha512', secret)
    .update(JSON.stringify(req.body))
    .digest('hex');

  if (hash !== expectedHash) {
    return res.status(401).send('Invalid signature');
  }

  const event = req.body;

  // Handle transfer.success event
  if (event.event === 'transfer.success') {
    const transferCode = event.data.transfer_code;

    // Find payout by transfer code
    const payoutsQuery = await db.collection('payouts')
      .where('paystackTransferCode', '==', transferCode)
      .limit(1)
      .get();

    if (!payoutsQuery.empty) {
      const payoutDoc = payoutsQuery.docs[0];

      await payoutDoc.ref.update({
        status: 'completed',
        completedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Update campaign status
      const payout = payoutDoc.data();
      await db.collection('campaigns').doc(payout.campaignId).update({
        payoutStatus: 'completed',
      });

      console.log(`Payout ${payoutDoc.id} completed successfully`);
    }
  }

  // Handle transfer.failed event
  if (event.event === 'transfer.failed') {
    const transferCode = event.data.transfer_code;

    const payoutsQuery = await db.collection('payouts')
      .where('paystackTransferCode', '==', transferCode)
      .limit(1)
      .get();

    if (!payoutsQuery.empty) {
      const payoutDoc = payoutsQuery.docs[0];

      await payoutDoc.ref.update({
        status: 'failed',
        failureReason: event.data.reason || 'Transfer failed',
        retryCount: admin.firestore.FieldValue.increment(1),
      });

      // Update campaign status
      const payout = payoutDoc.data();
      await db.collection('campaigns').doc(payout.campaignId).update({
        payoutStatus: 'failed',
      });

      console.log(`Payout ${payoutDoc.id} failed: ${event.data.reason}`);
    }
  }

  res.status(200).send('Webhook processed');
});

/**
 * Retries a failed payout
 */
export const retryPayout = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { payoutId } = data;

  if (!payoutId) {
    throw new functions.https.HttpsError('invalid-argument', 'Payout ID required');
  }

  const payoutDoc = await db.collection('payouts').doc(payoutId).get();
  if (!payoutDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'Payout not found');
  }

  const payout = payoutDoc.data()!;

  // Verify ownership or admin
  const userDoc = await db.collection('users').doc(context.auth.uid).get();
  const isAdmin = userDoc.data()?.role === 'admin';
  const isOwner = payout.creatorId === context.auth.uid;

  if (!isAdmin && !isOwner) {
    throw new functions.https.HttpsError('permission-denied', 'Access denied');
  }

  if (payout.status !== 'failed') {
    throw new functions.https.HttpsError('failed-precondition', 'Only failed payouts can be retried');
  }

  if (payout.retryCount >= 3) {
    throw new functions.https.HttpsError('failed-precondition', 'Maximum retry attempts reached');
  }

  try {
    // Reset status to approved and retry
    await payoutDoc.ref.update({
      status: 'approved',
      failureReason: null,
    });

    await processPayoutTransfer(payoutId);

    return { success: true, message: 'Payout retry initiated' };
  } catch (error: any) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});
