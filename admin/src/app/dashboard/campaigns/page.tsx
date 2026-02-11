'use client';

import { useState, useEffect } from 'react';
import { collection, query, where, getDocs } from 'firebase/firestore';
import { db } from '@/lib/firebase/config';
import { approveCampaign, rejectCampaign, freezeCampaign, requestMoreInfo } from '@/lib/firebase/functions';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { formatCurrency, formatDate, getStatusColor } from '@/lib/utils';
import { Check, X, Pause, Eye, AlertTriangle, MessageSquare } from 'lucide-react';
import type { Campaign } from '@/types/campaign';
import CampaignDetailModal from '@/components/campaign-detail-modal';

export default function CampaignsPage() {
  const [campaigns, setCampaigns] = useState<Campaign[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<string>('pending');
  const [actionLoading, setActionLoading] = useState<string | null>(null);
  const [selectedCampaign, setSelectedCampaign] = useState<Campaign | null>(null);

  useEffect(() => {
    loadCampaigns();
  }, [filter]);

  const loadCampaigns = async () => {
    setLoading(true);
    try {
      const q = query(
        collection(db, 'campaigns'),
        where('status', '==', filter)
      );
      const snapshot = await getDocs(q);
      const data = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      })) as Campaign[];
      setCampaigns(data);
    } catch (error) {
      console.error('Error loading campaigns:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = async (campaignId: string) => {
    setActionLoading(campaignId);
    try {
      await approveCampaign({ campaignId });
      await loadCampaigns();
      alert('Campaign approved successfully');
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
      await loadCampaigns();
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
      await loadCampaigns();
      alert('Campaign frozen');
    } catch (error: any) {
      alert(error.message || 'Failed to freeze campaign');
    } finally {
      setActionLoading(null);
    }
  };

  const handleRequestMoreInfo = async (campaignId: string) => {
    const message = prompt('What additional information do you need?');
    if (!message) return;

    setActionLoading(campaignId);
    try {
      await requestMoreInfo({ campaignId, message });
      alert('Request sent to campaign creator');
    } catch (error: any) {
      alert(error.message || 'Failed to send request');
    } finally {
      setActionLoading(null);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Campaigns</h1>
          <p className="mt-2 text-gray-600">Review and manage campaigns</p>
        </div>
      </div>

      {/* Filters */}
      <div className="flex gap-2">
        {['pending', 'active', 'rejected', 'frozen'].map((status) => (
          <button
            key={status}
            onClick={() => setFilter(status)}
            className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
              filter === status
                ? 'bg-[#2FA4A9] text-white'
                : 'bg-white text-gray-700 border border-gray-200 hover:bg-gray-50'
            }`}
          >
            {status.charAt(0).toUpperCase() + status.slice(1)}
          </button>
        ))}
      </div>

      {/* Campaigns List */}
      {loading ? (
        <div className="text-center py-12">
          <div className="h-8 w-8 animate-spin rounded-full border-4 border-[#2FA4A9] border-t-transparent mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading campaigns...</p>
        </div>
      ) : campaigns.length === 0 ? (
        <Card>
          <CardContent className="py-12 text-center">
            <p className="text-gray-600">No {filter} campaigns found</p>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-6">
          {campaigns.map((campaign) => (
            <Card key={campaign.id}>
              <CardContent className="p-6">
                <div className="flex gap-6">
                  {/* Campaign Image */}
                  {campaign.proofUrls?.[0] && (
                    <img
                      src={campaign.proofUrls[0]}
                      alt={campaign.title}
                      className="w-32 h-32 rounded-lg object-cover"
                    />
                  )}

                  {/* Campaign Details */}
                  <div className="flex-1">
                    <div className="flex items-start justify-between">
                      <div>
                        <div className="flex items-center gap-2">
                          <h3 className="text-xl font-semibold text-gray-900">
                            {campaign.title}
                          </h3>
                          {campaign.verification?.redFlags && campaign.verification.redFlags.length > 0 && (
                            <span title="Red flags detected">
                              <AlertTriangle className="h-5 w-5 text-red-500" />
                            </span>
                          )}
                        </div>
                        <div className="mt-1 flex items-center gap-2">
                          <Badge className={getStatusColor(campaign.status)}>
                            {campaign.status}
                          </Badge>
                          <span className="text-sm text-gray-500">
                            {campaign.cause}
                          </span>
                          {campaign.isReported && (
                            <Badge className="bg-red-100 text-red-700 text-xs">
                              Reported
                            </Badge>
                          )}
                        </div>
                      </div>
                    </div>

                    <p className="mt-3 text-gray-600 line-clamp-2">
                      {campaign.story}
                    </p>

                    <div className="mt-4 grid grid-cols-3 gap-4">
                      <div>
                        <p className="text-sm text-gray-500">Target</p>
                        <p className="font-semibold text-gray-900">
                          {formatCurrency(campaign.targetAmount)}
                        </p>
                      </div>
                      <div>
                        <p className="text-sm text-gray-500">Raised</p>
                        <p className="font-semibold text-gray-900">
                          {formatCurrency(campaign.raisedAmount || 0)}
                        </p>
                      </div>
                      <div>
                        <p className="text-sm text-gray-500">End Date</p>
                        <p className="font-semibold text-gray-900">
                          {formatDate(campaign.endDate)}
                        </p>
                      </div>
                    </div>

                    {/* Actions */}
                    {campaign.status === 'pending' && (
                      <div className="mt-4 flex gap-2">
                        <Button
                          size="sm"
                          variant="outline"
                          onClick={() => setSelectedCampaign(campaign)}
                        >
                          <Eye className="h-4 w-4 mr-1" />
                          Review
                        </Button>
                        <Button
                          size="sm"
                          variant="primary"
                          onClick={() => handleApprove(campaign.id)}
                          disabled={actionLoading === campaign.id}
                        >
                          <Check className="h-4 w-4 mr-1" />
                          Approve
                        </Button>
                        <Button
                          size="sm"
                          variant="danger"
                          onClick={() => handleReject(campaign.id)}
                          disabled={actionLoading === campaign.id}
                        >
                          <X className="h-4 w-4 mr-1" />
                          Reject
                        </Button>
                        <Button
                          size="sm"
                          variant="secondary"
                          onClick={() => handleRequestMoreInfo(campaign.id)}
                          disabled={actionLoading === campaign.id}
                        >
                          <MessageSquare className="h-4 w-4 mr-1" />
                          Request Info
                        </Button>
                      </div>
                    )}

                    {campaign.status === 'active' && (
                      <div className="mt-4 flex gap-2">
                        <Button
                          size="sm"
                          variant="outline"
                          onClick={() => setSelectedCampaign(campaign)}
                        >
                          <Eye className="h-4 w-4 mr-1" />
                          View Details
                        </Button>
                        <Button
                          size="sm"
                          variant="outline"
                          onClick={() => handleFreeze(campaign.id)}
                          disabled={actionLoading === campaign.id}
                        >
                          <Pause className="h-4 w-4 mr-1" />
                          Freeze Campaign
                        </Button>
                      </div>
                    )}
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
        onUpdate={loadCampaigns}
      />
    </div>
  );
}
