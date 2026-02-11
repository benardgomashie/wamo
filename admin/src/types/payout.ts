export interface Payout {
  id: string;
  campaignId: string;
  creatorId: string;
  amount: number;
  momoNetwork: string;
  momoNumber: string;
  status: 'pending_review' | 'approved' | 'processing' | 'completed' | 'failed' | 'on_hold';
  requestedAt: Date | string;
  approvedAt?: Date | string;
  approvedBy?: string;
  adminNotes?: string;
  processedAt?: Date | string;
  errorMessage?: string;
  transactionReference?: string;
}

export interface PayoutWithCampaign extends Payout {
  campaignTitle?: string;
  creatorName?: string;
  creatorEmail?: string;
}
