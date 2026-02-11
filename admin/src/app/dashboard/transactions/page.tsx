'use client';

import { useState, useEffect } from 'react';
import { collection, query, orderBy, limit, getDocs, where } from 'firebase/firestore';
import { db } from '@/lib/firebase/config';
import { Card, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { formatCurrency, formatDateTime } from '@/lib/utils';
import { CheckCircle, XCircle, Clock, Search } from 'lucide-react';

interface Transaction {
  id: string;
  campaignId: string;
  campaignTitle?: string;
  donorId: string;
  donorName?: string;
  donorEmail?: string;
  amount: number;
  fee: number;
  netAmount: number;
  paymentMethod: 'momo' | 'card';
  provider?: string;
  reference: string;
  status: 'success' | 'failed' | 'pending';
  createdAt: string;
  metadata?: Record<string, any>;
}

export default function TransactionsPage() {
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>('all');

  useEffect(() => {
    loadTransactions();
  }, [statusFilter]);

  const loadTransactions = async () => {
    setLoading(true);
    try {
      let q = query(
        collection(db, 'donations'),
        orderBy('createdAt', 'desc'),
        limit(100)
      );

      if (statusFilter !== 'all') {
        q = query(
          collection(db, 'donations'),
          where('status', '==', statusFilter),
          orderBy('createdAt', 'desc'),
          limit(100)
        );
      }

      const snapshot = await getDocs(q);
      const txData = await Promise.all(
        snapshot.docs.map(async (doc) => {
          const data = doc.data();
          
          // Fetch campaign title
          let campaignTitle = 'Unknown Campaign';
          if (data.campaignId) {
            const campaignDoc = await getDocs(
              query(collection(db, 'campaigns'), where('__name__', '==', data.campaignId))
            );
            if (!campaignDoc.empty) {
              campaignTitle = campaignDoc.docs[0].data().title;
            }
          }

          return {
            id: doc.id,
            campaignTitle,
            ...data,
          } as Transaction;
        })
      );

      setTransactions(txData);
    } catch (error) {
      console.error('Error loading transactions:', error);
    } finally {
      setLoading(false);
    }
  };

  const filteredTransactions = transactions.filter((tx) => {
    if (!searchTerm) return true;
    const term = searchTerm.toLowerCase();
    return (
      tx.reference?.toLowerCase().includes(term) ||
      tx.campaignTitle?.toLowerCase().includes(term) ||
      tx.donorEmail?.toLowerCase().includes(term) ||
      tx.id.toLowerCase().includes(term)
    );
  });

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'success':
        return <CheckCircle className="h-5 w-5 text-green-500" />;
      case 'failed':
        return <XCircle className="h-5 w-5 text-red-500" />;
      case 'pending':
        return <Clock className="h-5 w-5 text-orange-500" />;
      default:
        return null;
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'success':
        return 'bg-green-100 text-green-700';
      case 'failed':
        return 'bg-red-100 text-red-700';
      case 'pending':
        return 'bg-orange-100 text-orange-700';
      default:
        return 'bg-gray-100 text-gray-700';
    }
  };

  const totalVolume = filteredTransactions.reduce((sum, tx) => sum + tx.amount, 0);
  const totalFees = filteredTransactions.reduce((sum, tx) => sum + (tx.fee || 0), 0);
  const successCount = filteredTransactions.filter((tx) => tx.status === 'success').length;
  const successRate = filteredTransactions.length > 0 
    ? ((successCount / filteredTransactions.length) * 100).toFixed(1) 
    : '0';

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Transactions</h1>
        <p className="mt-2 text-gray-600">Monitor all donation transactions and payment activity</p>
      </div>

      {/* Stats Summary */}
      <div className="grid grid-cols-4 gap-4">
        <Card>
          <CardContent className="p-4">
            <div className="text-sm text-gray-600">Total Volume</div>
            <div className="text-2xl font-bold text-gray-900 mt-1">
              {formatCurrency(totalVolume)}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="text-sm text-gray-600">Total Fees</div>
            <div className="text-2xl font-bold text-[#F39C3D] mt-1">
              {formatCurrency(totalFees)}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="text-sm text-gray-600">Transactions</div>
            <div className="text-2xl font-bold text-gray-900 mt-1">
              {filteredTransactions.length}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="text-sm text-gray-600">Success Rate</div>
            <div className="text-2xl font-bold text-green-600 mt-1">
              {successRate}%
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Filters */}
      <div className="flex gap-4">
        <div className="flex-1 relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400" />
          <input
            type="text"
            placeholder="Search by reference, campaign, email, or ID..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg text-sm"
          />
        </div>

        <select
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
          className="border border-gray-300 rounded-lg px-4 py-2 text-sm"
        >
          <option value="all">All Status</option>
          <option value="success">Success</option>
          <option value="failed">Failed</option>
          <option value="pending">Pending</option>
        </select>
      </div>

      {/* Transactions Table */}
      {loading ? (
        <div className="text-center py-12">
          <div className="h-8 w-8 animate-spin rounded-full border-4 border-[#2FA4A9] border-t-transparent mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading transactions...</p>
        </div>
      ) : filteredTransactions.length === 0 ? (
        <Card>
          <CardContent className="py-12 text-center">
            <p className="text-gray-600">No transactions found</p>
          </CardContent>
        </Card>
      ) : (
        <Card>
          <CardContent className="p-0">
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="bg-gray-50 border-b border-gray-200">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      Transaction ID
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      Campaign
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      Amount
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      Fee
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      Method
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      Status
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      Date
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {filteredTransactions.map((tx) => (
                    <tr key={tx.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 text-sm">
                        <div className="font-mono text-gray-900">{tx.reference || tx.id.slice(0, 12)}</div>
                        <div className="text-xs text-gray-500">{tx.donorEmail || 'Anonymous'}</div>
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-900">
                        {tx.campaignTitle}
                      </td>
                      <td className="px-6 py-4 text-sm font-semibold text-gray-900">
                        {formatCurrency(tx.amount)}
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-600">
                        {formatCurrency(tx.fee || 0)}
                      </td>
                      <td className="px-6 py-4 text-sm">
                        <div className="capitalize">{tx.paymentMethod}</div>
                        {tx.provider && (
                          <div className="text-xs text-gray-500">{tx.provider}</div>
                        )}
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-2">
                          {getStatusIcon(tx.status)}
                          <Badge className={getStatusColor(tx.status)}>
                            {tx.status}
                          </Badge>
                        </div>
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-600 whitespace-nowrap">
                        {formatDateTime(tx.createdAt)}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
