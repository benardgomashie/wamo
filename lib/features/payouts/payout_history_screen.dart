import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/payout.dart';
import '../../core/services/payout_service.dart';
import '../../app/theme.dart';
import '../../widgets/wamo_empty_state.dart';

class PayoutHistoryScreen extends StatelessWidget {
  final String creatorId;
  final _payoutService = PayoutService();

  PayoutHistoryScreen({
    super.key,
    required this.creatorId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payout History'),
      ),
      body: StreamBuilder<List<Payout>>(
        stream: _payoutService.getPayoutsForCreator(creatorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final payouts = snapshot.data ?? [];

          if (payouts.isEmpty) {
            return const Center(
              child: WamoEmptyState(
                icon: Icons.account_balance_wallet_outlined,
                title: 'No payouts yet',
                message: 'Your payout history will appear here',
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: payouts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final payout = payouts[index];
              return _buildPayoutCard(context, payout);
            },
          );
        },
      ),
    );
  }

  Widget _buildPayoutCard(BuildContext context, Payout payout) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showPayoutDetails(context, payout),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status and amount row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusChip(payout.status),
                  Text(
                    'GHS ${payout.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Date
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Requested: ${DateFormat('MMM dd, yyyy').format(payout.requestedAt)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),

              if (payout.completedAt != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Completed: ${DateFormat('MMM dd, yyyy').format(payout.completedAt!)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // Mobile Money details
              if (payout.recipientMomoNumber != null) ...[
                Row(
                  children: [
                    Icon(Icons.phone_android, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '${payout.recipientMomoNetwork ?? 'MoMo'}: ${payout.recipientMomoNumber}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],

              // Failure reason if failed
              if (payout.status == 'failed' && payout.failureReason != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, size: 16, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          payout.failureReason!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Retry button for failed payouts
              if (payout.canRetry) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _retryPayout(context, payout.id),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry Payout'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case 'completed':
        backgroundColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        icon = Icons.check_circle;
        break;
      case 'processing':
        backgroundColor = Colors.blue[50]!;
        textColor = Colors.blue[700]!;
        icon = Icons.sync;
        break;
      case 'pending_review':
        backgroundColor = Colors.orange[50]!;
        textColor = Colors.orange[700]!;
        icon = Icons.pending;
        break;
      case 'approved':
        backgroundColor = Colors.teal[50]!;
        textColor = Colors.teal[700]!;
        icon = Icons.thumb_up;
        break;
      case 'failed':
        backgroundColor = Colors.red[50]!;
        textColor = Colors.red[700]!;
        icon = Icons.error;
        break;
      case 'on_hold':
        backgroundColor = Colors.grey[200]!;
        textColor = Colors.grey[700]!;
        icon = Icons.pause_circle;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[600]!;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            _formatStatus(status),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'pending_review':
        return 'Pending Review';
      case 'funds_available':
        return 'Available';
      case 'on_hold':
        return 'On Hold';
      default:
        return status[0].toUpperCase() + status.substring(1);
    }
  }

  void _showPayoutDetails(BuildContext context, Payout payout) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payout Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Amount', 'GHS ${payout.amount.toStringAsFixed(2)}'),
              _buildDetailRow('Platform Fee', 'GHS ${payout.platformFeeDeducted.toStringAsFixed(2)}'),
              const Divider(height: 24),
              _buildDetailRow('Status', payout.statusMessage),
              _buildDetailRow('Requested', DateFormat('MMM dd, yyyy HH:mm').format(payout.requestedAt)),
              if (payout.approvedAt != null)
                _buildDetailRow('Approved', DateFormat('MMM dd, yyyy HH:mm').format(payout.approvedAt!)),
              if (payout.completedAt != null)
                _buildDetailRow('Completed', DateFormat('MMM dd, yyyy HH:mm').format(payout.completedAt!)),
              const Divider(height: 24),
              if (payout.recipientMomoNumber != null)
                _buildDetailRow('Mobile Money', '${payout.recipientMomoNetwork}: ${payout.recipientMomoNumber}'),
              if (payout.paystackTransferCode != null)
                _buildDetailRow('Transfer Code', payout.paystackTransferCode!),
              if (payout.adminNotes != null)
                _buildDetailRow('Admin Notes', payout.adminNotes!),
              if (payout.failureReason != null)
                _buildDetailRow('Failure Reason', payout.failureReason!, isError: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isError ? AppTheme.errorColor : AppTheme.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _retryPayout(BuildContext context, String payoutId) async {
    try {
      await _payoutService.retryPayout(payoutId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payout retry initiated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to retry: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
