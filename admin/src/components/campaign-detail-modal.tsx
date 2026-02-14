'use client';

import { useState } from 'react';
import { Campaign, VerificationData } from '@/types/campaign';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { formatCurrency, formatDateTime } from '@/lib/utils';
import { 
  CheckCircle, 
  XCircle, 
  AlertTriangle, 
  Phone, 
  CreditCard, 
  FileText,
  Image as ImageIcon,
  User
} from 'lucide-react';
import { updateVerification } from '@/lib/firebase/functions';

interface CampaignDetailModalProps {
  campaign: Campaign | null;
  isOpen: boolean;
  onClose: () => void;
  onUpdate: () => void;
}

export default function CampaignDetailModal({
  campaign,
  isOpen,
  onClose,
  onUpdate,
}: CampaignDetailModalProps) {
  const [saving, setSaving] = useState(false);
  const [verification, setVerification] = useState<VerificationData>({
    phoneNumber: campaign?.verification?.phoneNumber || '',
    phoneVerified: campaign?.verification?.phoneVerified || false,
    fullName: campaign?.verification?.fullName || '',
    idType: campaign?.verification?.idType,
    idNumber: campaign?.verification?.idNumber,
    idImageUrl: campaign?.verification?.idImageUrl,
    selfieUrl: campaign?.verification?.selfieUrl,
    identityVerified: campaign?.verification?.identityVerified || false,
    proofDocuments: campaign?.verification?.proofDocuments || [],
    needVerified: campaign?.verification?.needVerified || false,
    momoNetwork: campaign?.verification?.momoNetwork,
    momoNumber: campaign?.verification?.momoNumber,
    momoVerified: campaign?.verification?.momoVerified || false,
    verificationNotes: campaign?.verification?.verificationNotes || '',
    requestedInfo: campaign?.verification?.requestedInfo,
    redFlags: campaign?.verification?.redFlags || [],
  });

  if (!campaign) return null;

  const handleVerificationToggle = (field: 'identityVerified' | 'needVerified' | 'momoVerified') => {
    setVerification((prev) => ({
      ...prev,
      [field]: !prev[field],
    }));
  };

  const handleSaveVerification = async () => {
    setSaving(true);
    try {
      await updateVerification({
        campaignId: campaign.id,
        verification: {
          identityVerified: verification.identityVerified || false,
          needVerified: verification.needVerified || false,
          momoVerified: verification.momoVerified || false,
          verificationNotes: verification.verificationNotes || '',
        },
      });
      alert('Verification updated successfully');
      onUpdate();
      onClose();
    } catch (error: any) {
      alert(error.message || 'Failed to update verification');
    } finally {
      setSaving(false);
    }
  };

  const getProofLabel = (category: string) => {
    switch (category) {
      case 'medical':
        return 'Hospital bill, doctor\'s note, admission slip';
      case 'education':
        return 'School invoice, admission letter';
      case 'funeral':
        return 'Funeral flyer, letter from family/church';
      case 'emergency':
        return 'Photos, letter from community leader';
      default:
        return 'Supporting documents';
    }
  };

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle className="text-2xl">{campaign.title}</DialogTitle>
        </DialogHeader>

        <div className="space-y-6">
          {/* Campaign Info */}
          <div className="grid grid-cols-2 gap-4 text-sm">
            <div>
              <span className="text-gray-500">Creator:</span>
              <span className="ml-2 font-semibold">
                {campaign.creatorName || campaign.ownerId || 'Unknown'}
              </span>
            </div>
            <div>
              <span className="text-gray-500">Category:</span>
              <span className="ml-2 font-semibold capitalize">
                {campaign.category || campaign.cause || 'general'}
              </span>
            </div>
            <div>
              <span className="text-gray-500">Target:</span>
              <span className="ml-2 font-semibold">{formatCurrency(campaign.targetAmount)}</span>
            </div>
            <div>
              <span className="text-gray-500">Created:</span>
              <span className="ml-2 font-semibold">{formatDateTime(campaign.createdAt)}</span>
            </div>
          </div>

          {/* Red Flags */}
          {campaign.verification?.redFlags && campaign.verification.redFlags.length > 0 && (
            <div className="bg-red-50 border border-red-200 rounded-lg p-4">
              <div className="flex items-center gap-2 text-red-700 font-semibold mb-2">
                <AlertTriangle className="h-5 w-5" />
                Red Flags Detected
              </div>
              <ul className="list-disc list-inside text-sm text-red-600 space-y-1">
                {campaign.verification.redFlags.map((flag, idx) => (
                  <li key={idx}>{flag}</li>
                ))}
              </ul>
            </div>
          )}

          {/* 3-Level Verification Checklist */}
          <div className="border border-gray-200 rounded-lg p-4 space-y-4">
            <h3 className="font-semibold text-lg">Verification Checklist</h3>

            {/* Level 1: Identity */}
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <User className="h-5 w-5 text-[#2FA4A9]" />
                  <span className="font-semibold">Level 1: Identity Verification</span>
                </div>
                <button
                  onClick={() => handleVerificationToggle('identityVerified')}
                  className="text-sm"
                >
                  {verification.identityVerified ? (
                    <CheckCircle className="h-6 w-6 text-green-500" />
                  ) : (
                    <XCircle className="h-6 w-6 text-gray-300" />
                  )}
                </button>
              </div>
              <div className="ml-8 space-y-2 text-sm">
                <div className="flex items-center gap-2">
                  <Phone className="h-4 w-4" />
                  <span>Phone: {campaign.verification?.phoneNumber || 'Not provided'}</span>
                  {campaign.verification?.phoneVerified && (
                    <Badge className="bg-green-100 text-green-700 text-xs">OTP Verified</Badge>
                  )}
                </div>
                <div className="flex items-center gap-2">
                  <CreditCard className="h-4 w-4" />
                  <span>ID: {campaign.verification?.idType?.replace('_', ' ').toUpperCase() || 'Not provided'}</span>
                </div>
                {campaign.verification?.idImageUrl && (
                  <a
                    href={campaign.verification.idImageUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-2 text-[#2FA4A9] hover:underline"
                  >
                    <ImageIcon className="h-4 w-4" />
                    View ID Document
                  </a>
                )}
                {campaign.verification?.selfieUrl && (
                  <a
                    href={campaign.verification.selfieUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-2 text-[#2FA4A9] hover:underline"
                  >
                    <ImageIcon className="h-4 w-4" />
                    View Selfie
                  </a>
                )}
              </div>
            </div>

            {/* Level 2: Need */}
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <FileText className="h-5 w-5 text-[#F39C3D]" />
                  <span className="font-semibold">Level 2: Need Verification</span>
                </div>
                <button
                  onClick={() => handleVerificationToggle('needVerified')}
                  className="text-sm"
                >
                  {verification.needVerified ? (
                    <CheckCircle className="h-6 w-6 text-green-500" />
                  ) : (
                    <XCircle className="h-6 w-6 text-gray-300" />
                  )}
                </button>
              </div>
              <div className="ml-8 space-y-2 text-sm">
                <p className="text-gray-600">Expected: {getProofLabel(campaign.category || campaign.cause || '')}</p>
                {(campaign.verification?.proofDocuments?.length ?? 0) > 0 ? (
                  <div className="space-y-1">
                    {(campaign.verification?.proofDocuments ?? []).map((doc, idx) => (
                      <a
                        key={idx}
                        href={doc.url}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="flex items-center gap-2 text-[#2FA4A9] hover:underline"
                      >
                        <FileText className="h-4 w-4" />
                        Document {idx + 1} - {doc.type}
                      </a>
                    ))}
                  </div>
                ) : (
                  <p className="text-gray-400">No proof documents uploaded</p>
                )}
              </div>
            </div>

            {/* Level 3: Payout */}
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <Phone className="h-5 w-5 text-green-500" />
                  <span className="font-semibold">Level 3: Payout Verification</span>
                </div>
                <button
                  onClick={() => handleVerificationToggle('momoVerified')}
                  className="text-sm"
                >
                  {verification.momoVerified ? (
                    <CheckCircle className="h-6 w-6 text-green-500" />
                  ) : (
                    <XCircle className="h-6 w-6 text-gray-300" />
                  )}
                </button>
              </div>
              <div className="ml-8 space-y-2 text-sm">
                <div className="flex items-center gap-2">
                  <span>Mobile Money: {campaign.verification?.momoNetwork || 'Not provided'}</span>
                </div>
                <div className="flex items-center gap-2">
                  <span>Number: {campaign.verification?.momoNumber || 'Not provided'}</span>
                  {campaign.verification?.momoVerified && (
                    <Badge className="bg-green-100 text-green-700 text-xs">Verified</Badge>
                  )}
                </div>
              </div>
            </div>
          </div>

          {/* Campaign Story */}
          <div>
            <h3 className="font-semibold mb-2">Campaign Story</h3>
            <p className="text-sm text-gray-700 whitespace-pre-wrap">{campaign.story}</p>
          </div>

          {/* Admin Notes */}
          <div>
            <label className="block font-semibold mb-2">Admin Notes</label>
            <textarea
              className="w-full border border-gray-300 rounded-lg p-3 text-sm"
              rows={3}
              placeholder="Add verification notes..."
              value={verification.verificationNotes || ''}
              onChange={(e) =>
                setVerification((prev) => ({ ...prev, verificationNotes: e.target.value }))
              }
            />
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={onClose}>
            Close
          </Button>
          <Button variant="primary" onClick={handleSaveVerification} disabled={saving}>
            {saving ? 'Saving...' : 'Save Verification'}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
