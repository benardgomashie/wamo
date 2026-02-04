import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import axios from 'axios';
import * as crypto from 'crypto';

const db = admin.firestore();

/**
 * Paystack Webhook Handler
 * Verifies webhook signature and processes payment events
 */
export const paystackWebhook = functions.https.onRequest(async (req, res) => {
  try {
    // Verify Paystack signature
    const hash = crypto
      .createHmac('sha512', process.env.PAYSTACK_SECRET_KEY || '')
      .update(JSON.stringify(req.body))
      .digest('hex');

    if (hash !== req.headers['x-paystack-signature']) {
      functions.logger.warn('Invalid Paystack signature');
      return res.status(401).send('Invalid signature');
    }

    const event = req.body;
    functions.logger.info('Paystack webhook received', { event: event.event });

    // Handle different event types
    switch (event.event) {
      case 'charge.success':
        await handleSuccessfulCharge(event.data);
        break;
      case 'transfer.success':
        await handleSuccessfulTransfer(event.data);
        break;
      case 'transfer.failed':
        await handleFailedTransfer(event.data);
        break;
      default:
        functions.logger.info('Unhandled event type', { event: event.event });
    }

    return res.status(200).send('Webhook processed');
  } catch (error) {
    functions.logger.error('Webhook processing error', error);
    return res.status(500).send('Webhook processing failed');
  }
});

/**
 * Handle successful payment charge
 */
async function handleSuccessfulCharge(data: any) {
  const reference = data.reference;
  const metadata = data.metadata;

  // Verify transaction with Paystack
  const verification = await verifyTransaction(reference);

  if (!verification.success) {
    functions.logger.error('Transaction verification failed', { reference });
    return;
  }

  // Extract donation details from metadata
  const campaignId = metadata.campaign_id;
  const donorName = metadata.donor_name;
  const donorContact = metadata.donor_contact;
  const donationAmount = parseFloat(metadata.donation_amount || 0);
  const platformFee = parseFloat(metadata.platform_fee || 0);
  const paystackFee = parseFloat(metadata.paystack_fee || 0);
  const amount = data.amount / 100; // Paystack amounts are in kobo/pesewas
  const isAnonymous = metadata.is_anonymous === 'true' || metadata.is_anonymous === true;
  const message = metadata.message || null;

  // Create donation record
  const donationRef = db.collection('donations').doc();
  await donationRef.set({
    id: donationRef.id,
    campaign_id: campaignId,
    donor_name: isAnonymous ? 'Anonymous' : (donorName || 'Anonymous'),
    donor_contact: isAnonymous ? null : (donorContact || null),
    amount: donationAmount,
    total_paid: amount,
    platform_fee: platformFee,
    paystack_fee: paystackFee,
    payment_method: data.channel,
    status: 'successful',
    reference: reference,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
    is_anonymous: isAnonymous,
    message: message,
  });

  // Update campaign raised amount and donation count
  const campaignRef = db.collection('campaigns').doc(campaignId);
  await campaignRef.update({
    raisedAmount: admin.firestore.FieldValue.increment(donationAmount),
    donationCount: admin.firestore.FieldValue.increment(1),
  });

  functions.logger.info('Donation recorded successfully', {
    donationId: donationRef.id,
    campaignId,
    amount,
  });
}

/**
 * Handle successful payout transfer
 */
async function handleSuccessfulTransfer(data: any) {
  const reference = data.reference;
  const transferCode = data.transfer_code;

  // Find payout by transaction reference
  const payoutSnapshot = await db
    .collection('payouts')
    .where('transaction_reference', '==', reference)
    .limit(1)
    .get();

  if (payoutSnapshot.empty) {
    functions.logger.warn('Payout not found for transfer', { reference });
    return;
  }

  const payoutDoc = payoutSnapshot.docs[0];
  await payoutDoc.ref.update({
    status: 'completed',
    completed_at: admin.firestore.FieldValue.serverTimestamp(),
  });

  functions.logger.info('Payout completed successfully', {
    payoutId: payoutDoc.id,
    reference,
  });
}

/**
 * Handle failed payout transfer
 */
async function handleFailedTransfer(data: any) {
  const reference = data.reference;

  const payoutSnapshot = await db
    .collection('payouts')
    .where('transaction_reference', '==', reference)
    .limit(1)
    .get();

  if (payoutSnapshot.empty) {
    functions.logger.warn('Payout not found for failed transfer', { reference });
    return;
  }

  const payoutDoc = payoutSnapshot.docs[0];
  await payoutDoc.ref.update({
    status: 'failed',
    notes: `Transfer failed: ${data.message || 'Unknown error'}`,
  });

  functions.logger.error('Payout transfer failed', {
    payoutId: payoutDoc.id,
    reference,
    message: data.message,
  });
}

/**
 * Verify transaction with Paystack API
 */
async function verifyTransaction(reference: string): Promise<{ success: boolean }> {
  try {
    const response = await axios.get(
      `https://api.paystack.co/transaction/verify/${reference}`,
      {
        headers: {
          Authorization: `Bearer ${process.env.PAYSTACK_SECRET_KEY}`,
        },
      }
    );

    return {
      success: response.data.status && response.data.data.status === 'success',
    };
  } catch (error) {
    functions.logger.error('Transaction verification error', error);
    return { success: false };
  }
}
