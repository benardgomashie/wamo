import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * Trigger when a new campaign is created
 */
export const onCampaignCreated = functions.firestore
  .document('campaigns/{campaignId}')
  .onCreate(async (snap, context) => {
    const campaign = snap.data();
    const campaignId = context.params.campaignId;

    functions.logger.info('New campaign created', {
      campaignId,
      ownerId: campaign.owner_id,
      title: campaign.title,
    });

    // TODO: Send notification to admins for verification
    // TODO: Send confirmation to campaign creator
  });

/**
 * Trigger when a new donation is created
 */
export const onDonationCreated = functions.firestore
  .document('donations/{donationId}')
  .onCreate(async (snap, context) => {
    const donation = snap.data();
    const donationId = context.params.donationId;

    functions.logger.info('New donation created', {
      donationId,
      campaignId: donation.campaign_id,
      amount: donation.amount,
    });

    // Get campaign details
    const campaignDoc = await db.collection('campaigns').doc(donation.campaign_id).get();

    if (!campaignDoc.exists) {
      functions.logger.error('Campaign not found for donation', {
        campaignId: donation.campaign_id,
      });
      return;
    }

    const campaign = campaignDoc.data()!;
    const progress = (campaign.raised_amount / campaign.target_amount) * 100;

    // Check for milestone notifications (25%, 50%, 75%, 100%)
    const milestones = [25, 50, 75, 100];
    for (const milestone of milestones) {
      const previousProgress = ((campaign.raised_amount - donation.amount) / campaign.target_amount) * 100;
      
      if (previousProgress < milestone && progress >= milestone) {
        functions.logger.info('Milestone reached', {
          campaignId: donation.campaign_id,
          milestone: `${milestone}%`,
        });
        // TODO: Send milestone notification
      }
    }

    // TODO: Send donation notification to campaign owner
    // TODO: Send thank you notification to donor (if not anonymous)
  });
