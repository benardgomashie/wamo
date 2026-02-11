'use client';

import { useState, useEffect } from 'react';
import { collection, query, where, getDocs } from 'firebase/firestore';
import { db } from '@/lib/firebase/config';
import { approvePayout } from '@/lib/firebase/functions';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { formatCurrency, formatDateTime, getStatusColor } from '@/lib/utils';
import { Check } from 'lucide-react';
import type { PayoutWithCampaign } from '@/types/payout';

export default function PayoutsPage() {
  const [payouts, setPayouts] = useState<PayoutWithCampaign[]>([]);
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState<string | null>(null);

  useEffect(() => {
    loadPayouts();
  }, []);

  const loadPayouts = async () => {
    setLoading(true);
    try {
      const q = query(
        collection(db, 'payouts'),
        where('status', '==', 'pending_review')
      );
      const snapshot = await getDocs(q);
      
      const payoutsData = await Promise.all(
        snapshot.docs.map(async (doc) => {
          const payoutData = { id: doc.id, ...doc.data() } as PayoutWithCampaign;
          
          // Fetch campaign title
          const campaignDoc = await getDocs(
            query(collection(db, 'campaigns'), where('__name__', '==', payoutData.campaignId))
          );
          if (!campaignDoc.empty) {
            payoutData.campaignTitle = campaignDoc.docs[0].data().title;
          }
          
          return payoutData;
        })
      );
      
      setPayouts(payoutsData);
    } catch (error) {
      console.error('Error loading payouts:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = async (payoutId: string) => {
    setActionLoading(payoutId);
    try {
      await approvePayout({ payoutId });
      await loadPayouts();
      alert('Payout approved successfully');
    } catch (error: any) {
      alert(error.message || 'Failed to approve payout');
    } finally {
      setActionLoading(null);
    }
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Payouts</h1>
        <p className="mt-2 text-gray-600">Review and approve payout requests</p>
      </div>

      {loading ? (
        <div className="text-center py-12">
          <div className="h-8 w-8 animate-spin rounded-full border-4 border-[#2FA4A9] border-t-transparent mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading payouts...</p>
        </div>
      ) : payouts.length === 0 ? (
        <Card>
          <CardContent className="py-12 text-center">
            <p className="text-gray-600">No pending payouts</p>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-6">
          {payouts.map((payout) => (
            <Card key={payout.id}>
              <CardContent className="p-6">
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <div className="flex items-center gap-3">
                      <h3 className="text-lg font-semibold text-gray-900">
                        {payout.campaignTitle || `Campaign ${payout.campaignId.slice(0, 8)}`}
                      </h3>
                      <Badge className={getStatusColor(payout.status)}>
                        {payout.status.replace('_', ' ')}
                      </Badge>
                    </div>

                    <div className="mt-4 grid grid-cols-3 gap-6">
                      <div>
                        <p className="text-sm text-gray-500">Amount</p>
                        <p className="text-xl font-bold text-gray-900">
                          {formatCurrency(payout.amount)}
                        </p>
                      </div>
                      <div>
                        <p className="text-sm text-gray-500">Mobile Money</p>
                        <p className="font-semibold text-gray-900">
                          {payout.momoNetwork}
                        </p>
                        <p className="text-sm text-gray-600">{payout.momoNumber}</p>
                      </div>
                      <div>
                        <p className="text-sm text-gray-500">Requested</p>
                        <p className="font-semibold text-gray-900">
                          {formatDateTime(payout.requestedAt)}
                        </p>
                      </div>
                    </div>

                    {payout.status === 'pending_review' && (
                      <div className="mt-6">
                        <Button
                          variant="primary"
                          onClick={() => handleApprove(payout.id)}
                          disabled={actionLoading === payout.id}
                        >
                          <Check className="h-4 w-4 mr-2" />
                          Approve Payout
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
    </div>
  );
}
