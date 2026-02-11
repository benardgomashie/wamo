'use client';

import { useState, useEffect } from 'react';
import { collection, query, orderBy, limit, getDocs, where, Timestamp } from 'firebase/firestore';
import { db } from '@/lib/firebase/config';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { formatDateTime } from '@/lib/utils';
import { FileText, CheckCircle, XCircle, Pause, DollarSign, AlertTriangle, MessageSquare } from 'lucide-react';

interface AuditLog {
  id: string;
  action: 'approve_campaign' | 'reject_campaign' | 'freeze_campaign' | 'approve_payout' | 'reject_payout' | 'hold_payout' | 'request_info';
  adminId: string;
  adminEmail: string;
  campaignId?: string;
  campaignTitle?: string;
  payoutId?: string;
  reason?: string;
  notes?: string;
  timestamp: Timestamp | string;
  metadata?: Record<string, any>;
}

export default function AuditLogsPage() {
  const [logs, setLogs] = useState<AuditLog[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<string>('all');
  const [dateFilter, setDateFilter] = useState<'today' | 'week' | 'month' | 'all'>('week');

  useEffect(() => {
    loadLogs();
  }, [filter, dateFilter]);

  const loadLogs = async () => {
    setLoading(true);
    try {
      let q = query(
        collection(db, 'auditLogs'),
        orderBy('timestamp', 'desc'),
        limit(100)
      );

      // Add action filter
      if (filter !== 'all') {
        q = query(
          collection(db, 'auditLogs'),
          where('action', '==', filter),
          orderBy('timestamp', 'desc'),
          limit(100)
        );
      }

      // Add date filter
      if (dateFilter !== 'all') {
        const now = new Date();
        let startDate: Date;
        
        switch (dateFilter) {
          case 'today':
            startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
            break;
          case 'week':
            startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
            break;
          case 'month':
            startDate = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
            break;
          default:
            startDate = new Date(0);
        }

        q = query(q, where('timestamp', '>=', Timestamp.fromDate(startDate)));
      }

      const snapshot = await getDocs(q);
      const logsData = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      })) as AuditLog[];
      
      setLogs(logsData);
    } catch (error) {
      console.error('Error loading audit logs:', error);
    } finally {
      setLoading(false);
    }
  };

  const getActionIcon = (action: string) => {
    switch (action) {
      case 'approve_campaign':
      case 'approve_payout':
        return <CheckCircle className="h-5 w-5 text-green-500" />;
      case 'reject_campaign':
      case 'reject_payout':
        return <XCircle className="h-5 w-5 text-red-500" />;
      case 'freeze_campaign':
      case 'hold_payout':
        return <Pause className="h-5 w-5 text-orange-500" />;
      case 'request_info':
        return <MessageSquare className="h-5 w-5 text-blue-500" />;
      default:
        return <FileText className="h-5 w-5 text-gray-500" />;
    }
  };

  const getActionLabel = (action: string) => {
    return action.replace(/_/g, ' ').replace(/\b\w/g, (l) => l.toUpperCase());
  };

  const getActionColor = (action: string) => {
    if (action.includes('approve')) return 'bg-green-100 text-green-700';
    if (action.includes('reject')) return 'bg-red-100 text-red-700';
    if (action.includes('freeze') || action.includes('hold')) return 'bg-orange-100 text-orange-700';
    if (action.includes('request')) return 'bg-blue-100 text-blue-700';
    return 'bg-gray-100 text-gray-700';
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Audit Logs</h1>
        <p className="mt-2 text-gray-600">Complete history of all admin actions</p>
      </div>

      {/* Filters */}
      <div className="flex gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Action Type</label>
          <select
            value={filter}
            onChange={(e) => setFilter(e.target.value)}
            className="border border-gray-300 rounded-lg px-4 py-2 text-sm"
          >
            <option value="all">All Actions</option>
            <option value="approve_campaign">Approve Campaign</option>
            <option value="reject_campaign">Reject Campaign</option>
            <option value="freeze_campaign">Freeze Campaign</option>
            <option value="approve_payout">Approve Payout</option>
            <option value="reject_payout">Reject Payout</option>
            <option value="hold_payout">Hold Payout</option>
            <option value="request_info">Request Info</option>
          </select>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Time Period</label>
          <select
            value={dateFilter}
            onChange={(e) => setDateFilter(e.target.value as any)}
            className="border border-gray-300 rounded-lg px-4 py-2 text-sm"
          >
            <option value="today">Today</option>
            <option value="week">Last 7 Days</option>
            <option value="month">Last 30 Days</option>
            <option value="all">All Time</option>
          </select>
        </div>
      </div>

      {/* Logs Table */}
      {loading ? (
        <div className="text-center py-12">
          <div className="h-8 w-8 animate-spin rounded-full border-4 border-[#2FA4A9] border-t-transparent mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading audit logs...</p>
        </div>
      ) : logs.length === 0 ? (
        <Card>
          <CardContent className="py-12 text-center">
            <p className="text-gray-600">No audit logs found</p>
          </CardContent>
        </Card>
      ) : (
        <Card>
          <CardContent className="p-0">
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="bg-gray-50 border-b border-gray-200">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Timestamp
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Action
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Admin
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Target
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Details
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {logs.map((log) => (
                    <tr key={log.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {formatDateTime(log.timestamp)}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center gap-2">
                          {getActionIcon(log.action)}
                          <Badge className={getActionColor(log.action)}>
                            {getActionLabel(log.action)}
                          </Badge>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {log.adminEmail}
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-900">
                        {log.campaignTitle && (
                          <div>
                            <span className="font-medium">{log.campaignTitle}</span>
                            <br />
                            <span className="text-xs text-gray-500">ID: {log.campaignId?.slice(0, 8)}</span>
                          </div>
                        )}
                        {log.payoutId && (
                          <div>
                            <span className="font-medium">Payout</span>
                            <br />
                            <span className="text-xs text-gray-500">ID: {log.payoutId.slice(0, 8)}</span>
                          </div>
                        )}
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-600">
                        {log.reason && (
                          <div>
                            <span className="font-medium">Reason: </span>
                            {log.reason}
                          </div>
                        )}
                        {log.notes && (
                          <div>
                            <span className="font-medium">Notes: </span>
                            {log.notes}
                          </div>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Stats Summary */}
      <div className="grid grid-cols-4 gap-4">
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-gray-600">Total Actions</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-gray-900">{logs.length}</div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-gray-600">Approvals</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">
              {logs.filter((l) => l.action.includes('approve')).length}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-gray-600">Rejections</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-red-600">
              {logs.filter((l) => l.action.includes('reject')).length}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-gray-600">Holds/Freezes</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-orange-600">
              {logs.filter((l) => l.action.includes('freeze') || l.action.includes('hold')).length}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
