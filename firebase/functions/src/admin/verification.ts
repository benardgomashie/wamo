import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * Request More Information from Campaign Creator
 * Sends notification to creator asking for additional documents/info
 */
export const requestMoreInfo = functions.https.onCall(async (data, context) => {
  // Verify admin authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { campaignId, message } = data;

  if (!campaignId || !message) {
    throw new functions.https.HttpsError('invalid-argument', 'Campaign ID and message are required');
  }

  try {
    const campaignRef = db.collection('campaigns').doc(campaignId);
    const campaignDoc = await campaignRef.get();

    if (!campaignDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Campaign not found');
    }

    // Update campaign with requested info
    await campaignRef.update({
      'verification.requestedInfo': message,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Send notification to creator (implement based on your notification system)
    const campaign = campaignDoc.data();
    await db.collection('notifications').add({
      userId: campaign?.ownerId,
      type: 'info_requested',
      title: 'Additional Information Required',
      message: message,
      campaignId: campaignId,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      read: false,
    });

    return {
      success: true,
      message: 'Information request sent to creator',
    };
  } catch (error: any) {
    console.error('Error requesting more info:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

/**
 * Update Campaign Verification Status
 * Allows admin to update the 3-level verification checklist
 */
export const updateVerification = functions.https.onCall(async (data, context) => {
  // Verify admin authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { campaignId, verification } = data;

  if (!campaignId || !verification) {
    throw new functions.https.HttpsError('invalid-argument', 'Campaign ID and verification data are required');
  }

  try {
    const campaignRef = db.collection('campaigns').doc(campaignId);
    const campaignDoc = await campaignRef.get();

    if (!campaignDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Campaign not found');
    }

    // Build update object with dot notation
    const updates: any = {
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (verification.identityVerified !== undefined) {
      updates['verification.identityVerified'] = verification.identityVerified;
    }

    if (verification.needVerified !== undefined) {
      updates['verification.needVerified'] = verification.needVerified;
    }

    if (verification.momoVerified !== undefined) {
      updates['verification.momoVerified'] = verification.momoVerified;
    }

    if (verification.verificationNotes !== undefined) {
      updates['verification.verificationNotes'] = verification.verificationNotes;
    }

    if (verification.redFlags !== undefined) {
      updates['verification.redFlags'] = verification.redFlags;
    }

    // Update campaign
    await campaignRef.update(updates);

    return {
      success: true,
      message: 'Verification updated successfully',
    };
  } catch (error: any) {
    console.error('Error updating verification:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

/**
 * Auto-detect Red Flags
 * Called when campaign is submitted or updated
 * Checks for suspicious patterns
 */
export const detectRedFlags = functions.firestore
  .document('campaigns/{campaignId}')
  .onWrite(async (change, context) => {
    const campaignId = context.params.campaignId;
    const newData = change.after.exists ? change.after.data() : null;
    const oldData = change.before.exists ? change.before.data() : null;

    // Skip if campaign is deleted
    if (!newData) return;

    const redFlags: string[] = [];

    try {
      // Check 1: Mismatched names (ID vs creator name)
      if (newData.verification?.fullName && newData.verification?.idType) {
        const idName = newData.verification.fullName.toLowerCase().trim();
        const creatorName = newData.creatorName?.toLowerCase().trim() || '';
        
        if (idName !== creatorName && !idName.includes(creatorName)) {
          redFlags.push('Name mismatch between ID and account');
        }
      }

      // Check 2: Multiple campaigns from same phone number
      if (newData.verification?.phoneNumber) {
        const samPhoneCampaigns = await db
          .collection('campaigns')
          .where('verification.phoneNumber', '==', newData.verification.phoneNumber)
          .get();

        if (samPhoneCampaigns.size > 1) {
          redFlags.push(`${samPhoneCampaigns.size} campaigns from same phone number`);
        }
      }

      // Check 3: Reused images (simple check - same URL)
      if (newData.proofUrls && newData.proofUrls.length > 0) {
        for (const url of newData.proofUrls) {
          const sameImageCampaigns = await db
            .collection('campaigns')
            .where('proofUrls', 'array-contains', url)
            .get();

          if (sameImageCampaigns.size > 1) {
            redFlags.push('Proof image used in multiple campaigns');
            break; // Only flag once
          }
        }
      }

      // Check 4: Missing verification documents for pending campaigns
      if (newData.status === 'pending') {
        if (!newData.verification?.phoneVerified) {
          redFlags.push('Phone number not verified');
        }

        if (!newData.verification?.idImageUrl) {
          redFlags.push('ID document not uploaded');
        }

        if (!newData.verification?.proofDocuments || newData.verification.proofDocuments.length === 0) {
          redFlags.push('No proof documents uploaded');
        }

        if (!newData.verification?.momoNumber) {
          redFlags.push('Mobile Money not configured');
        }
      }

      // Update campaign with red flags if any found
      if (redFlags.length > 0) {
        await change.after.ref.update({
          'verification.redFlags': redFlags,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        console.log(`Red flags detected for campaign ${campaignId}:`, redFlags);
      } else if (oldData?.verification?.redFlags && oldData.verification.redFlags.length > 0) {
        // Clear red flags if none found
        await change.after.ref.update({
          'verification.redFlags': [],
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    } catch (error) {
      console.error('Error detecting red flags:', error);
      // Don't throw - this is a background function
    }
  });
