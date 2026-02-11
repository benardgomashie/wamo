import { httpsCallable } from 'firebase/functions';
import { functions } from './config';

// Campaign Management Functions
export const approveCampaign = httpsCallable<
  { campaignId: string; notes?: string },
  { success: boolean; message: string }
>(functions, 'approveCampaign');

export const rejectCampaign = httpsCallable<
  { campaignId: string; reason: string },
  { success: boolean; message: string }
>(functions, 'rejectCampaign');

export const freezeCampaign = httpsCallable<
  { campaignId: string; reason: string },
  { success: boolean; message: string }
>(functions, 'freezeCampaign');

export const listPendingCampaigns = httpsCallable<
  void,
  { campaigns: any[] }
>(functions, 'listPendingCampaigns');

// Payout Management Functions
export const approvePayout = httpsCallable<
  { payoutId: string; notes?: string },
  { success: boolean; message: string }
>(functions, 'approvePayout');

export const getPayoutHistory = httpsCallable<
  { status?: string; limit?: number },
  { payouts: any[] }
>(functions, 'getPayoutHistory');

export const requestMoreInfo = httpsCallable<
  { campaignId: string; message: string },
  { success: boolean; message: string }
>(functions, 'requestMoreInfo');

export const updateVerification = httpsCallable<
  { 
    campaignId: string; 
    verification: Partial<{
      identityVerified: boolean;
      needVerified: boolean;
      momoVerified: boolean;
      verificationNotes: string;
      redFlags: string[];
    }>;
  },
  { success: boolean; message: string }
>(functions, 'updateVerification');
