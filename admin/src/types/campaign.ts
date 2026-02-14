export interface VerificationData {
  // Level 1: Identity Verification
  phoneNumber: string;
  phoneVerified: boolean;
  fullName: string;
  idType?: 'ghana_card' | 'national_id' | 'passport';
  idNumber?: string;
  idImageUrl?: string;
  selfieUrl?: string;
  identityVerified: boolean;
  
  // Level 2: Need Verification
  proofDocuments: Array<{
    url: string;
    type: string;
    uploadedAt: string;
  }>;
  needVerified: boolean;
  
  // Level 3: Payout Verification
  momoNetwork?: string;
  momoNumber?: string;
  momoVerified: boolean;
  
  // Admin notes
  verificationNotes?: string;
  requestedInfo?: string;
  redFlags?: string[];
}

export interface Campaign {
  id: string;
  ownerId: string;
  creatorName?: string;
  title: string;
  category?: string;
  cause: string;
  story: string;
  targetAmount: number;
  currentAmount?: number;
  raisedAmount: number;
  imageUrl?: string;
  status: 'draft' | 'pending' | 'active' | 'rejected' | 'frozen' | 'completed' | 'expired';
  createdAt: Date | string;
  endDate: Date | string;
  verifiedAt?: Date | string;
  approvedBy?: string;
  approvedAt?: Date | string;
  adminNotes?: string;
  rejectionReason?: string;
  proofUrls: string[];
  payoutMethod: string;
  payoutDetails: string;
  donorCount?: number;
  verification?: VerificationData;
  isReported?: boolean;
  reportCount?: number;
}

export interface CampaignWithOwner extends Campaign {
  ownerName?: string;
  ownerEmail?: string;
  ownerPhone?: string;
}
