'use client';

import { useState, useEffect } from 'react';
import { collection, getDocs, query, where } from 'firebase/firestore';
import { db } from '@/lib/firebase/config';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { formatCurrency } from '@/lib/utils';
import { TrendingUp, Users, DollarSign, Target } from 'lucide-react';

interface AnalyticsData {
  totalCampaigns: number;
  activeCampaigns: number;
  totalDonations: number;
  totalRevenue: number;
  totalDonors: number;
  averageDonation: number;
  successRate: number;
}

export default function AnalyticsPage() {
  const [analytics, setAnalytics] = useState<AnalyticsData | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadAnalytics();
  }, []);

  const loadAnalytics = async () => {
    setLoading(true);
    try {
      // Get all campaigns
      const campaignsSnapshot = await getDocs(collection(db, 'campaigns'));
      const campaigns = campaignsSnapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));

      // Get active campaigns
      const activeSnapshot = await getDocs(
        query(collection(db, 'campaigns'), where('status', '==', 'active'))
      );

      // Get all donations
      const donationsSnapshot = await getDocs(collection(db, 'donations'));
      const donations = donationsSnapshot.docs.map((doc) => doc.data());

      // Get unique donors
      const uniqueDonors = new Set(donations.map((d: any) => d.donorId));

      // Calculate total revenue
      const totalRevenue = campaigns.reduce((sum: number, c: any) => sum + (c.currentAmount || 0), 0);

      // Calculate total donations count
      const totalDonations = donations.length;

      // Calculate average donation
      const averageDonation = totalDonations > 0 ? totalRevenue / totalDonations : 0;

      // Calculate success rate (campaigns that reached goal)
      const successfulCampaigns = campaigns.filter(
        (c: any) => c.currentAmount >= c.targetAmount
      ).length;
      const successRate = campaigns.length > 0 ? (successfulCampaigns / campaigns.length) * 100 : 0;

      setAnalytics({
        totalCampaigns: campaigns.length,
        activeCampaigns: activeSnapshot.size,
        totalDonations,
        totalRevenue,
        totalDonors: uniqueDonors.size,
        averageDonation,
        successRate,
      });
    } catch (error) {
      console.error('Error loading analytics:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="text-center py-12">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-[#2FA4A9] border-t-transparent mx-auto"></div>
        <p className="mt-4 text-gray-600">Loading analytics...</p>
      </div>
    );
  }

  if (!analytics) {
    return (
      <div className="text-center py-12">
        <p className="text-gray-600">Failed to load analytics</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Analytics</h1>
        <p className="mt-2 text-gray-600">Platform metrics and insights</p>
      </div>

      {/* Key Metrics */}
      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-gray-600">Total Campaigns</CardTitle>
            <Target className="h-5 w-5 text-[#2FA4A9]" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-gray-900">{analytics.totalCampaigns}</div>
            <p className="mt-1 text-sm text-gray-500">
              {analytics.activeCampaigns} active
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-gray-600">Total Revenue</CardTitle>
            <DollarSign className="h-5 w-5 text-[#F39C3D]" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-gray-900">
              {formatCurrency(analytics.totalRevenue)}
            </div>
            <p className="mt-1 text-sm text-gray-500">
              {analytics.totalDonations} donations
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-gray-600">Total Donors</CardTitle>
            <Users className="h-5 w-5 text-[#2FA4A9]" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-gray-900">{analytics.totalDonors}</div>
            <p className="mt-1 text-sm text-gray-500">
              Avg: {formatCurrency(analytics.averageDonation)}/donation
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-gray-600">Success Rate</CardTitle>
            <TrendingUp className="h-5 w-5 text-green-500" />
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-gray-900">
              {analytics.successRate.toFixed(1)}%
            </div>
            <p className="mt-1 text-sm text-gray-500">Campaigns reached goal</p>
          </CardContent>
        </Card>
      </div>

      {/* Performance Overview */}
      <Card>
        <CardHeader>
          <CardTitle>Platform Performance</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <span className="text-sm font-medium text-gray-700">Campaign Success Rate</span>
              <div className="flex items-center gap-2">
                <div className="w-48 h-2 bg-gray-200 rounded-full overflow-hidden">
                  <div
                    className="h-full bg-green-500"
                    style={{ width: `${analytics.successRate}%` }}
                  />
                </div>
                <span className="text-sm font-semibold text-gray-900">
                  {analytics.successRate.toFixed(1)}%
                </span>
              </div>
            </div>

            <div className="flex items-center justify-between">
              <span className="text-sm font-medium text-gray-700">Active vs Total Campaigns</span>
              <div className="flex items-center gap-2">
                <div className="w-48 h-2 bg-gray-200 rounded-full overflow-hidden">
                  <div
                    className="h-full bg-[#2FA4A9]"
                    style={{
                      width: `${(analytics.activeCampaigns / analytics.totalCampaigns) * 100}%`,
                    }}
                  />
                </div>
                <span className="text-sm font-semibold text-gray-900">
                  {((analytics.activeCampaigns / analytics.totalCampaigns) * 100).toFixed(1)}%
                </span>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
