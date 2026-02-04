import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * Admin function to approve a campaign
 * Requires admin role
 */
export const approveCampaign = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  // Verify admin role
  const userDoc = await db.collection('users').doc(context.auth.uid).get();
  if (!userDoc.exists || userDoc.data()?.role !== 'admin') {
    throw new functions.https.HttpsError('permission-denied', 'User is not an admin');
  }

  const { campaignId, notes } = data;

  if (!campaignId) {
    throw new functions.https.HttpsError('invalid-argument', 'Campaign ID is required');
  }

  try {
    // Get campaign
    const campaignRef = db.collection('campaigns').doc(campaignId);
    const campaignDoc = await campaignRef.get();

    if (!campaignDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Campaign not found');
    }

    const campaign = campaignDoc.data()!;

    // Update campaign status
    await campaignRef.update({
      status: 'active',
      approvedAt: admin.firestore.FieldValue.serverTimestamp(),
      approvedBy: context.auth.uid,
      adminNotes: notes || null,
    });

    // Log action
    await db.collection('admin_logs').add({
      action: 'approve_campaign',
      campaignId,
      adminId: context.auth.uid,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      notes: notes || null,
    });

    // TODO: Send notification to campaign creator
    functions.logger.info('Campaign approved', {
      campaignId,
      adminId: context.auth.uid,
      campaignTitle: campaign.title,
    });

    return {
      success: true,
      message: 'Campaign approved successfully',
    };
  } catch (error) {
    functions.logger.error('Error approving campaign', error);
    throw new functions.https.HttpsError('internal', 'Failed to approve campaign');
  }
});

/**
 * Admin function to reject a campaign
 * Requires admin role
 */
export const rejectCampaign = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  // Verify admin role
  const userDoc = await db.collection('users').doc(context.auth.uid).get();
  if (!userDoc.exists || userDoc.data()?.role !== 'admin') {
    throw new functions.https.HttpsError('permission-denied', 'User is not an admin');
  }

  const { campaignId, reason, notes } = data;

  if (!campaignId || !reason) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Campaign ID and rejection reason are required'
    );
  }

  try {
    // Get campaign
    const campaignRef = db.collection('campaigns').doc(campaignId);
    const campaignDoc = await campaignRef.get();

    if (!campaignDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Campaign not found');
    }

    const campaign = campaignDoc.data()!;

    // Update campaign status
    await campaignRef.update({
      status: 'rejected',
      rejectedAt: admin.firestore.FieldValue.serverTimestamp(),
      rejectedBy: context.auth.uid,
      rejectionReason: reason,
      adminNotes: notes || null,
    });

    // Log action
    await db.collection('admin_logs').add({
      action: 'reject_campaign',
      campaignId,
      adminId: context.auth.uid,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      reason,
      notes: notes || null,
    });

    // TODO: Send notification to campaign creator with rejection reason
    functions.logger.info('Campaign rejected', {
      campaignId,
      adminId: context.auth.uid,
      campaignTitle: campaign.title,
      reason,
    });

    return {
      success: true,
      message: 'Campaign rejected',
    };
  } catch (error) {
    functions.logger.error('Error rejecting campaign', error);
    throw new functions.https.HttpsError('internal', 'Failed to reject campaign');
  }
});

/**
 * Admin function to freeze a campaign
 * Requires admin role
 */
export const freezeCampaign = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  // Verify admin role
  const userDoc = await db.collection('users').doc(context.auth.uid).get();
  if (!userDoc.exists || userDoc.data()?.role !== 'admin') {
    throw new functions.https.HttpsError('permission-denied', 'User is not an admin');
  }

  const { campaignId, reason, notes } = data;

  if (!campaignId || !reason) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Campaign ID and freeze reason are required'
    );
  }

  try {
    // Get campaign
    const campaignRef = db.collection('campaigns').doc(campaignId);
    const campaignDoc = await campaignRef.get();

    if (!campaignDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Campaign not found');
    }

    const campaign = campaignDoc.data()!;

    // Update campaign status
    await campaignRef.update({
      status: 'frozen',
      frozenAt: admin.firestore.FieldValue.serverTimestamp(),
      frozenBy: context.auth.uid,
      freezeReason: reason,
      adminNotes: notes || null,
    });

    // Log action
    await db.collection('admin_logs').add({
      action: 'freeze_campaign',
      campaignId,
      adminId: context.auth.uid,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      reason,
      notes: notes || null,
    });

    // TODO: Send notification to campaign creator
    functions.logger.info('Campaign frozen', {
      campaignId,
      adminId: context.auth.uid,
      campaignTitle: campaign.title,
      reason,
    });

    return {
      success: true,
      message: 'Campaign frozen',
    };
  } catch (error) {
    functions.logger.error('Error freezing campaign', error);
    throw new functions.https.HttpsError('internal', 'Failed to freeze campaign');
  }
});

/**
 * Admin function to get campaign review queue
 * Returns pending campaigns for verification
 */
export const getCampaignQueue = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  // Verify admin role
  const userDoc = await db.collection('users').doc(context.auth.uid).get();
  if (!userDoc.exists || userDoc.data()?.role !== 'admin') {
    throw new functions.https.HttpsError('permission-denied', 'User is not an admin');
  }

  const { status = 'pending', limit = 50 } = data;

  try {
    const querySnapshot = await db
      .collection('campaigns')
      .where('status', '==', status)
      .orderBy('createdAt', 'desc')
      .limit(limit)
      .get();

    const campaigns = querySnapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    return {
      success: true,
      campaigns,
      count: campaigns.length,
    };
  } catch (error) {
    functions.logger.error('Error fetching campaign queue', error);
    throw new functions.https.HttpsError('internal', 'Failed to fetch campaign queue');
  }
});

/**
 * Admin function to handle campaign reports
 */
export const reportCampaign = functions.https.onCall(async (data, context) => {
  // Authentication optional for reports
  const { campaignId, reason, details } = data;

  if (!campaignId || !reason) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Campaign ID and reason are required'
    );
  }

  try {
    // Create report
    await db.collection('campaign_reports').add({
      campaignId,
      reason,
      details: details || null,
      reportedBy: context.auth?.uid || 'anonymous',
      reportedAt: admin.firestore.FieldValue.serverTimestamp(),
      status: 'pending',
    });

    // If multiple reports, auto-freeze
    const reportsSnapshot = await db
      .collection('campaign_reports')
      .where('campaignId', '==', campaignId)
      .where('status', '==', 'pending')
      .get();

    if (reportsSnapshot.size >= 3) {
      // Auto-freeze campaign with 3+ reports
      await db.collection('campaigns').doc(campaignId).update({
        status: 'frozen',
        frozenAt: admin.firestore.FieldValue.serverTimestamp(),
        freezeReason: 'Multiple user reports',
        adminNotes: `Auto-frozen after ${reportsSnapshot.size} reports`,
      });

      functions.logger.warn('Campaign auto-frozen due to multiple reports', {
        campaignId,
        reportCount: reportsSnapshot.size,
      });
    }

    return {
      success: true,
      message: 'Report submitted successfully',
    };
  } catch (error) {
    functions.logger.error('Error reporting campaign', error);
    throw new functions.https.HttpsError('internal', 'Failed to submit report');
  }
});
