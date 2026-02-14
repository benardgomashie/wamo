'use client';

import { useState, useEffect } from 'react';
import { collection, query, where, getDocs } from 'firebase/firestore';
import { db } from '@/lib/firebase/config';
import { approveCampaign, rejectCampaign, freezeCampaign } from '@/lib/firebase/functions';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { formatCurrency, formatDateTime, getStatusColor } from '@/lib/utils';
import { AlertTriangle, Check, X, Pause, Eye } from 'lucide-react';
import type { Campaign } from '@/types/campaign';
import CampaignDetailModal from '@/components/campaign-detail-modal';

export default function ReportsPage() {
  const [campaigns, setCampaigns] = useState<Campaign[]>([]);
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState<string | null>(null);
  const [selectedCampaign, setSelectedCampaign] = useState<Campaign | null>(null);

  useEffect(() => {
    loadReportedCampaigns();
  }, []);

  const loadReportedCampaigns = async () => {
    setLoading(true);
    try {
      const q = query(
        collection(db, 'campaigns'),
        where('isReported', '==', true)
      );
      const snapshot = await getDocs(q);
      const campaignsData = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      })) as Campaign[];
      setCampaigns(campaignsData);
    } catch (error) {
      console.error('Error loading reported campaigns:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = async (campaignId: string) => {
    setActionLoading(campaignId);
    try {
      await approveCampaign({ campaignId });
      await loadReportedCampaigns();
      alert('Campaign approved and unflagged');
    } catch (error: any) {
      alert(error.message || 'Failed to approve campaign');
    } finally {
      setActionLoading(null);
    }
  };

  const handleReject = async (campaignId: string) => {
    const reason = prompt('Enter rejection reason:');
    if (!reason) return;

    setActionLoading(campaignId);
    try {
      await rejectCampaign({ campaignId, reason });
      await loadReportedCampaigns();
      alert('Campaign rejected');
    } catch (error: any) {
      alert(error.message || 'Failed to reject campaign');
    } finally {
      setActionLoading(null);
    }
  };

  const handleFreeze = async (campaignId: string) => {
    const reason = prompt('Enter freeze reason:');
    if (!reason) return;

    setActionLoading(campaignId);
    try {
      await freezeCampaign({ campaignId, reason });
      await loadReportedCampaigns();
      alert('Campaign frozen');
    } catch (error: any) {
      alert(error.message || 'Failed to freeze campaign');
    } finally {
      setActionLoading(null);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-3">
        <AlertTriangle className="h-8 w-8 text-red-500" />
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Reported Campaigns</h1>
          <p className="mt-2 text-gray-600">
            Review community-reported campaigns requiring immediate attention
          </p>
        </div>
      </div>

      {loading ? (
        <div className="text-center py-12">
          <div className="h-8 w-8 animate-spin rounded-full border-4 border-[#2FA4A9] border-t-transparent mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading reported campaigns...</p>
        </div>
      ) : campaigns.length === 0 ? (
        <Card>
          <CardContent className="py-12 text-center">
            <p className="text-gray-600">No reported campaigns</p>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-6">
          {campaigns.map((campaign) => (
            <Card key={campaign.id} className="border-red-200">
              <CardContent className="p-6">
                <div className="flex gap-6">
                  {campaign.proofUrls?.[0] && (
                    <img
                      src={campaign.proofUrls[0]}
                      alt={campaign.title}
                      className="w-32 h-32 object-cover rounded-lg"
                    />
                  )}

                  <div className="flex-1">
                    <div className="flex items-start justify-between">
                      <div>
                        <div className="flex items-center gap-3">
                          <h3 className="text-lg font-semibold text-gray-900">
                            {campaign.title}
                          </h3>
                          <Badge className={getStatusColor(campaign.status)}>
                            {campaign.status.replace('_', ' ')}
                          </Badge>
                          <Badge className="bg-red-100 text-red-700">
                            {campaign.reportCount || 1} {campaign.reportCount === 1 ? 'Report' : 'Reports'}
                          </Badge>
                        </div>
                        <p className="text-sm text-gray-500 mt-1">
                          by {(campaign as any).creatorName || campaign.ownerId || 'Unknown'}
                        </p>
                      </div>
                    </div>

                    <div className="mt-4 grid grid-cols-3 gap-4 text-sm">
                      <div>
                        <span className="text-gray-500">Target:</span>
                        <span className="ml-2 font-semibold">
                          {formatCurrency(campaign.targetAmount)}
                        </span>
                      </div>
                      <div>
                        <span className="text-gray-500">Raised:</span>
                        <span className="ml-2 font-semibold">
                          {formatCurrency(campaign.raisedAmount)}
                        </span>
                      </div>
                      <div>
                        <span className="text-gray-500">Created:</span>
                        <span className="ml-2 font-semibold">
                          {formatDateTime(campaign.createdAt)}
                        </span>
                      </div>
                    </div>

                    {/* Red Flags */}
                    {campaign.verification?.redFlags && campaign.verification.redFlags.length > 0 && (
                      <div className="mt-4 bg-red-50 border border-red-200 rounded-lg p-3">
                        <div className="flex items-center gap-2 text-red-700 font-semibold text-sm mb-2">
                          <AlertTriangle className="h-4 w-4" />
                          Red Flags Detected
                        </div>
                        <ul className="list-disc list-inside text-xs text-red-600 space-y-1">
                          {campaign.verification.redFlags.map((flag, idx) => (
                            <li key={idx}>{flag}</li>
                          ))}
                        </ul>
                      </div>
                    )}

                    <div className="mt-6 flex items-center gap-3">
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => setSelectedCampaign(campaign)}
                      >
                        <Eye className="h-4 w-4 mr-2" />
                        Review Details
                      </Button>

                      {campaign.status === 'pending' && (
                        <>
                          <Button
                            variant="primary"
                            size="sm"
                            onClick={() => handleApprove(campaign.id)}
                            disabled={actionLoading === campaign.id}
                          >
                            <Check className="h-4 w-4 mr-2" />
                            Approve & Unflag
                          </Button>
                          <Button
                            variant="danger"
                            size="sm"
                            onClick={() => handleReject(campaign.id)}
                            disabled={actionLoading === campaign.id}
                          >
                            <X className="h-4 w-4 mr-2" />
                            Reject
                          </Button>
                        </>
                      )}

                      {campaign.status === 'active' && (
                        <Button
                          variant="secondary"
                          size="sm"
                          onClick={() => handleFreeze(campaign.id)}
                          disabled={actionLoading === campaign.id}
                        >
                          <Pause className="h-4 w-4 mr-2" />
                          Freeze Campaign
                        </Button>
                      )}
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}

      <CampaignDetailModal
        campaign={selectedCampaign}
        isOpen={!!selectedCampaign}
        onClose={() => setSelectedCampaign(null)}
        onUpdate={loadReportedCampaigns}
      />
    </div>
  );
}
