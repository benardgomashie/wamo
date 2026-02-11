'use client';

import { useState, useEffect } from 'react';
import { collection, query, where, getDocs, Timestamp } from 'firebase/firestore';
import { db } from '@/lib/firebase/config';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { formatCurrency } from '@/lib/utils';
import { FileText, DollarSign, Users, TrendingUp } from 'lucide-react';

export default function DashboardPage() {
  const [stats, setStats] = useState({
    pendingCampaigns: 0,
    activeCampaigns: 0,
    pendingPayouts: 0,
    totalRevenue: 0,
    todayRevenue: 0,
    todayDonations: 0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadStats();
  }, []);

  const loadStats = async () => {
    try {
      // Get pending campaigns
      const pendingCampaigns = await getDocs(
        query(collection(db, 'campaigns'), where('status', '==', 'pending'))
      );

      // Get active campaigns
      const activeCampaigns = await getDocs(
        query(collection(db, 'campaigns'), where('status', '==', 'active'))
      );

      // Get pending payouts
      const pendingPayouts = await getDocs(
        query(collection(db, 'payouts'), where('status', '==', 'pending_review'))
      );

      // Get all campaigns to calculate total revenue
      const allCampaigns = await getDocs(collection(db, 'campaigns'));
      const totalRevenue = allCampaigns.docs.reduce((sum, doc) => {
        return sum + (doc.data().raisedAmount || 0);
      }, 0);

      // Get today's donations
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const todayStart = Timestamp.fromDate(today);

      const todayDonations = await getDocs(
        query(
          collection(db, 'donations'),
          where('createdAt', '>=', todayStart),
          where('status', '==', 'success')
        )
      );

      const todayRevenue = todayDonations.docs.reduce((sum, doc) => {
        return sum + (doc.data().amount || 0);
      }, 0);

      setStats({
        pendingCampaigns: pendingCampaigns.size,
        activeCampaigns: activeCampaigns.size,
        pendingPayouts: pendingPayouts.size,
        totalRevenue,
        todayRevenue,
        todayDonations: todayDonations.size,
      });
    } catch (error) {
      console.error('Error loading stats:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="text-center py-12">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-[#2FA4A9] border-t-transparent mx-auto"></div>
        <p className="mt-4 text-gray-600">Loading dashboard...</p>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
        <p className="mt-2 text-gray-600">
          Welcome to Wamo Admin Panel
        </p>
      </div>

      {/* Today's Stats */}
      <div className="bg-gradient-to-r from-[#2FA4A9] to-[#F39C3D] rounded-lg p-6 text-white">
        <h2 className="text-lg font-semibold mb-4">Today's Activity</h2>
        <div className="grid grid-cols-2 gap-4">
          <div>
            <div className="text-sm opacity-90">Donations Today</div>
            <div className="text-3xl font-bold">{stats.todayDonations}</div>
          </div>
          <div>
            <div className="text-sm opacity-90">Revenue Today</div>
            <div className="text-3xl font-bold">{formatCurrency(stats.todayRevenue)}</div>
          </div>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-gray-600">
              Pending Campaigns
            </CardTitle>
            <FileText className="h-5 w-5 text-orange-600" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-gray-900">{stats.pendingCampaigns}</div>
            <p className="text-xs text-gray-500 mt-1">Awaiting review</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-gray-600">
              Active Campaigns
            </CardTitle>
            <TrendingUp className="h-5 w-5 text-green-600" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-gray-900">{stats.activeCampaigns}</div>
            <p className="text-xs text-gray-500 mt-1">Currently running</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-gray-600">
              Pending Payouts
            </CardTitle>
            <DollarSign className="h-5 w-5 text-[#2FA4A9]" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-gray-900">{stats.pendingPayouts}</div>
            <p className="text-xs text-gray-500 mt-1">Need approval</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-gray-600">
              Total Revenue
            </CardTitle>
            <Users className="h-5 w-5 text-[#F39C3D]" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-gray-900">
              GHS {stats.totalRevenue.toLocaleString()}
            </div>
            <p className="text-xs text-gray-500 mt-1">Platform fees collected</p>
          </CardContent>
        </Card>
      </div>

      {/* Quick Actions */}
      <Card>
        <CardHeader>
          <CardTitle>Quick Actions</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid gap-4 md:grid-cols-3">
            <a
              href="/dashboard/campaigns"
              className="flex items-center gap-3 rounded-lg border border-gray-200 p-4 transition-colors hover:bg-gray-50"
            >
              <FileText className="h-6 w-6 text-[#2FA4A9]" />
              <div>
                <p className="font-medium text-gray-900">Review Campaigns</p>
                <p className="text-sm text-gray-500">Approve or reject campaigns</p>
              </div>
            </a>

            <a
              href="/dashboard/payouts"
              className="flex items-center gap-3 rounded-lg border border-gray-200 p-4 transition-colors hover:bg-gray-50"
            >
              <DollarSign className="h-6 w-6 text-[#2FA4A9]" />
              <div>
                <p className="font-medium text-gray-900">Process Payouts</p>
                <p className="text-sm text-gray-500">Approve pending payouts</p>
              </div>
            </a>

            <a
              href="/dashboard/analytics"
              className="flex items-center gap-3 rounded-lg border border-gray-200 p-4 transition-colors hover:bg-gray-50"
            >
              <TrendingUp className="h-6 w-6 text-[#2FA4A9]" />
              <div>
                <p className="font-medium text-gray-900">View Analytics</p>
                <p className="text-sm text-gray-500">Platform metrics</p>
              </div>
            </a>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
