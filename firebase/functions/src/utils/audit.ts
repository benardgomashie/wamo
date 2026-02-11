import * as admin from 'firebase-admin';

const db = admin.firestore();

export interface AuditLogData {
  action: 'approve_campaign' | 'reject_campaign' | 'freeze_campaign' | 'approve_payout' | 'reject_payout' | 'hold_payout' | 'request_info';
  adminId: string;
  adminEmail: string;
  campaignId?: string;
  campaignTitle?: string;
  payoutId?: string;
  reason?: string;
  notes?: string;
  metadata?: Record<string, any>;
}

/**
 * Create audit log entry
 * Call this from every admin action Cloud Function
 */
export async function createAuditLog(data: AuditLogData): Promise<void> {
  try {
    await db.collection('auditLogs').add({
      ...data,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  } catch (error) {
    console.error('Failed to create audit log:', error);
    // Don't throw - audit log failure shouldn't block the main action
  }
}
