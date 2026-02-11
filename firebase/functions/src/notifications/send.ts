import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();
const messaging = admin.messaging();

interface NotificationPayload {
  title: string;
  body: string;
  data?: { [key: string]: string };
}

/**
 * Send push notification to user via FCM
 */
async function sendPushNotification(
  userId: string,
  payload: NotificationPayload
): Promise<void> {
  try {
    // Get user's FCM token
    const userDoc = await db.collection('users').doc(userId).get();
    const fcmToken = userDoc.data()?.fcmToken;

    if (!fcmToken) {
      console.log(`No FCM token for user ${userId}`);
      return;
    }

    // Send notification
    const message = {
      token: fcmToken,
      notification: {
        title: payload.title,
        body: payload.body,
      },
      data: payload.data || {},
      android: {
        priority: 'high' as const,
        notification: {
          sound: 'default',
          channelId: 'wamo_notifications',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
    };

    await admin.messaging().send(message);
    console.log(`Push notification sent to user ${userId}`);
  } catch (error: any) {
    // Token might be invalid, remove it
    if (error.code === 'messaging/invalid-registration-token' ||
        error.code === 'messaging/registration-token-not-registered') {
      await db.collection('users').doc(userId).update({
        fcmToken: admin.firestore.FieldValue.delete(),
      });
      console.log(`Removed invalid FCM token for user ${userId}`);
    } else {
      console.error(`Error sending push notification: ${error}`);
    }
  }
}

/**
 * Create in-app notification in Firestore
 */
async function createInAppNotification(
  userId: string,
  type: string,
  payload: NotificationPayload
): Promise<void> {
  try {
    await db.collection('notifications').add({
      userId,
      type,
      title: payload.title,
      body: payload.body,
      isRead: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      data: payload.data || {},
      actionUrl: payload.data?.actionUrl || null,
    });
    console.log(`In-app notification created for user ${userId}`);
  } catch (error) {
    console.error(`Error creating in-app notification: ${error}`);
  }
}

/**
 * Send notification (both push and in-app)
 */
export const sendNotification = functions.https.onCall(async (data, context) => {
  // Verify user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { userId, title, body, data: notificationData } = data;

  try {
    // Get user's FCM token
    const userDoc = await db.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'User not found');
    }

    const userData = userDoc.data()!;
    const fcmToken = userData.fcm_token;

    if (!fcmToken) {
      functions.logger.warn('User has no FCM token', { userId });
      return { success: false, message: 'No FCM token' };
    }

    // Send push notification
    const message = {
      notification: {
        title,
        body,
      },
      data: notificationData || {},
      token: fcmToken,
    };

    await messaging.send(message);

    // Create in-app notification record
    await db.collection('notifications').add({
      user_id: userId,
      title,
      body,
      data: notificationData || {},
      is_read: false,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    functions.logger.info('Notification sent successfully', { userId, title });

    return { success: true };
  } catch (error) {
    functions.logger.error('Error sending notification', error);
    throw new functions.https.HttpsError('internal', 'Failed to send notification');
  }
});

/**
 * Trigger: Send notification when donation is created
 */
export const onDonationCreated = functions.firestore
  .document('donations/{donationId}')
  .onCreate(async (snapshot, context) => {
    const donation = snapshot.data();
    const campaignId = donation.campaignId;
    const amount = donation.amount;
    const donorName = donation.donorName || 'Anonymous';

    // Get campaign to find creator
    const campaignDoc = await db.collection('campaigns').doc(campaignId).get();
    if (!campaignDoc.exists) return;

    const campaign = campaignDoc.data()!;
    const creatorId = campaign.ownerId;
    const campaignTitle = campaign.title;

    // Send notification to creator
    await sendPushNotification(creatorId, {
      title: '🎉 New Donation!',
      body: `${donorName} donated GHS ${amount.toFixed(2)} to "${campaignTitle}"`,
      data: {
        type: 'donation_received',
        campaignId,
        donationId: context.params.donationId,
        actionUrl: `/campaigns/${campaignId}`,
      },
    });

    await createInAppNotification(creatorId, 'donation_received', {
      title: '🎉 New Donation!',
      body: `${donorName} donated GHS ${amount.toFixed(2)} to "${campaignTitle}"`,
      data: {
        campaignId,
        donationId: context.params.donationId,
        actionUrl: `/campaigns/${campaignId}`,
      },
    });

    // Check for milestone (25%, 50%, 75%, 100%)
    const progress = (campaign.raisedAmount + amount) / campaign.targetAmount;
    const milestones = [0.25, 0.5, 0.75, 1.0];
    
    for (const milestone of milestones) {
      const previousProgress = campaign.raisedAmount / campaign.targetAmount;
      if (previousProgress < milestone && progress >= milestone) {
        const percentage = milestone * 100;
        await sendPushNotification(creatorId, {
          title: `🎯 ${percentage}% Milestone Reached!`,
          body: `Your campaign "${campaignTitle}" has reached ${percentage}% of its goal!`,
          data: {
            type: 'milestone_reached',
            campaignId,
            milestone: percentage.toString(),
            actionUrl: `/campaigns/${campaignId}`,
          },
        });

        await createInAppNotification(creatorId, 'milestone_reached', {
          title: `🎯 ${percentage}% Milestone Reached!`,
          body: `Your campaign "${campaignTitle}" has reached ${percentage}% of its goal!`,
          data: {
            campaignId,
            milestone: percentage.toString(),
            actionUrl: `/campaigns/${campaignId}`,
          },
        });
      }
    }
  });

/**
 * Trigger: Send notification when campaign is approved/rejected
 */
export const onCampaignApproved = functions.firestore
  .document('campaigns/{campaignId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Check if status changed to approved
    if (before.status !== 'active' && after.status === 'active') {
      const creatorId = after.ownerId;
      const campaignTitle = after.title;

      await sendPushNotification(creatorId, {
        title: '✅ Campaign Approved!',
        body: `Your campaign "${campaignTitle}" has been approved and is now live!`,
        data: {
          type: 'campaign_approved',
          campaignId: context.params.campaignId,
          actionUrl: `/campaigns/${context.params.campaignId}`,
        },
      });

      await createInAppNotification(creatorId, 'campaign_approved', {
        title: '✅ Campaign Approved!',
        body: `Your campaign "${campaignTitle}" has been approved and is now live!`,
        data: {
          campaignId: context.params.campaignId,
          actionUrl: `/campaigns/${context.params.campaignId}`,
        },
      });
    }

    // Check if status changed to rejected
    if (before.status !== 'rejected' && after.status === 'rejected') {
      const creatorId = after.ownerId;
      const campaignTitle = after.title;
      const rejectionReason = after.rejectionReason || 'Please review campaign guidelines';

      await sendPushNotification(creatorId, {
        title: '❌ Campaign Needs Attention',
        body: `Your campaign "${campaignTitle}" requires updates: ${rejectionReason}`,
        data: {
          type: 'campaign_rejected',
          campaignId: context.params.campaignId,
          actionUrl: `/campaigns/${context.params.campaignId}`,
        },
      });

      await createInAppNotification(creatorId, 'campaign_rejected', {
        title: '❌ Campaign Needs Attention',
        body: `Your campaign "${campaignTitle}" requires updates: ${rejectionReason}`,
        data: {
          campaignId: context.params.campaignId,
          reason: rejectionReason,
          actionUrl: `/campaigns/${context.params.campaignId}`,
        },
      });
    }
  });

/**
 * Trigger: Send notification when payout is completed/failed
 */
export const onPayoutCompleted = functions.firestore
  .document('payouts/{payoutId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Check if status changed to completed
    if (before.status !== 'completed' && after.status === 'completed') {
      const creatorId = after.creatorId;
      const amount = after.amount;

      await sendPushNotification(creatorId, {
        title: '💰 Payout Completed!',
        body: `GHS ${amount.toFixed(2)} has been sent to your Mobile Money account`,
        data: {
          type: 'payout_completed',
          payoutId: context.params.payoutId,
          campaignId: after.campaignId,
          actionUrl: `/payouts/${context.params.payoutId}`,
        },
      });

      await createInAppNotification(creatorId, 'payout_completed', {
        title: '💰 Payout Completed!',
        body: `GHS ${amount.toFixed(2)} has been sent to your Mobile Money account`,
        data: {
          payoutId: context.params.payoutId,
          campaignId: after.campaignId,
          amount: amount.toString(),
          actionUrl: `/payouts/${context.params.payoutId}`,
        },
      });
    }

    // Check if status changed to failed
    if (before.status !== 'failed' && after.status === 'failed') {
      const creatorId = after.creatorId;
      const failureReason = after.failureReason || 'Unknown error';

      await sendPushNotification(creatorId, {
        title: '⚠️ Payout Failed',
        body: `Your payout could not be processed: ${failureReason}`,
        data: {
          type: 'payout_failed',
          payoutId: context.params.payoutId,
          actionUrl: `/payouts/${context.params.payoutId}`,
        },
      });

      await createInAppNotification(creatorId, 'payout_failed', {
        title: '⚠️ Payout Failed',
        body: `Your payout could not be processed: ${failureReason}`,
        data: {
          payoutId: context.params.payoutId,
          reason: failureReason,
          actionUrl: `/payouts/${context.params.payoutId}`,
        },
      });
    }
  });

/**
 * Scheduled function: Send campaign ending soon notifications
 * Runs daily at 9 AM WAT
 */
export const sendCampaignEndingNotifications = functions.pubsub
  .schedule('0 9 * * *')
  .timeZone('Africa/Accra')
  .onRun(async (context) => {
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    tomorrow.setHours(23, 59, 59, 999);

    // Find campaigns ending within 24 hours
    const campaignsSnapshot = await db.collection('campaigns')
      .where('status', '==', 'active')
      .where('endDate', '<=', admin.firestore.Timestamp.fromDate(tomorrow))
      .get();

    const notifications = campaignsSnapshot.docs.map(async (doc) => {
      const campaign = doc.data();
      const creatorId = campaign.ownerId;
      const campaignTitle = campaign.title;

      await sendPushNotification(creatorId, {
        title: '⏰ Campaign Ending Soon',
        body: `Your campaign "${campaignTitle}" ends in less than 24 hours!`,
        data: {
          type: 'campaign_ending_soon',
          campaignId: doc.id,
          actionUrl: `/campaigns/${doc.id}`,
        },
      });

      await createInAppNotification(creatorId, 'campaign_ending_soon', {
        title: '⏰ Campaign Ending Soon',
        body: `Your campaign "${campaignTitle}" ends in less than 24 hours!`,
        data: {
          campaignId: doc.id,
          actionUrl: `/campaigns/${doc.id}`,
        },
      });
    });

    await Promise.all(notifications);
    console.log(`Sent ${notifications.length} campaign ending notifications`);
  });
