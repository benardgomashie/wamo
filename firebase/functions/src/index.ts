import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Initialize Firebase Admin
admin.initializeApp();

// Export webhook handlers
export { paystackWebhook } from './webhooks/paystack';

// Export campaign triggers
export { onCampaignCreated, onDonationCreated } from './campaigns/triggers';

// Export admin functions
export {
  approveCampaign,
  rejectCampaign,
  freezeCampaign,
  getCampaignQueue,
  reportCampaign,
} from './admin/campaigns';

// Export payout functions
export {
  requestPayout,
  approvePayout,
  paystackTransferWebhook,
  retryPayout,
} from './payouts/transfer';

// Export notification functions
export {
  sendNotification,
  onDonationCreated,
  onCampaignApproved,
  onPayoutCompleted,
  sendCampaignEndingNotifications,
} from './notifications/send';

// Example: Simple health check function
export const healthCheck = functions.https.onRequest((req, res) => {
  res.status(200).send({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    service: 'Wamo Cloud Functions',
  });
});
