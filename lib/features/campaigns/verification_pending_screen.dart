import 'package:flutter/material.dart';
import '../../core/models/campaign.dart';

class VerificationPendingScreen extends StatelessWidget {
  final Campaign campaign;

  const VerificationPendingScreen({
    super.key,
    required this.campaign,
  });

  String _getStatusMessage() {
    switch (campaign.status) {
      case 'pending':
        return 'Your campaign is under review';
      case 'rejected':
        return 'Campaign needs revision';
      case 'active':
        return 'Campaign is live!';
      default:
        return 'Campaign status: ${campaign.status}';
    }
  }

  Color _getStatusColor() {
    switch (campaign.status) {
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'active':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (campaign.status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'active':
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildTimeline(BuildContext context) {
    final bool isSubmitted = campaign.createdAt != null;
    final bool isReviewed = campaign.status != 'pending';
    final bool isApproved = campaign.status == 'active';

    return Column(
      children: [
        _buildTimelineItem(
          context,
          icon: Icons.upload_file,
          title: 'Campaign Submitted',
          subtitle: isSubmitted
              ? 'Submitted ${_formatDate(campaign.createdAt)}'
              : 'Not submitted',
          isCompleted: isSubmitted,
          isActive: !isSubmitted,
        ),
        _buildTimelineLine(isSubmitted),
        _buildTimelineItem(
          context,
          icon: Icons.search,
          title: 'Under Review',
          subtitle: isReviewed
              ? 'Reviewed'
              : 'Typically takes 12-24 hours',
          isCompleted: isReviewed,
          isActive: isSubmitted && !isReviewed,
        ),
        _buildTimelineLine(isReviewed),
        _buildTimelineItem(
          context,
          icon: Icons.check_circle,
          title: 'Campaign Live',
          subtitle: isApproved
              ? 'Approved ${_formatDate(campaign.verifiedAt!)}'
              : 'Pending approval',
          isCompleted: isApproved,
          isActive: false,
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isActive,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: isCompleted
                  ? Colors.green
                  : isActive
                      ? Colors.orange
                      : Colors.grey[300],
              child: Icon(
                icon,
                color: isCompleted || isActive ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isCompleted || isActive ? Colors.black : Colors.grey,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineLine(bool isCompleted) {
    return Row(
      children: [
        const SizedBox(width: 19),
        Container(
          width: 2,
          height: 24,
          color: isCompleted ? Colors.green : Colors.grey[300],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildRejectionReason(BuildContext context) {
    if (campaign.status != 'rejected') return const SizedBox.shrink();

    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.red[700]),
                const SizedBox(width: 8),
                Text(
                  'Revision Needed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[900],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              campaign.rejectionReason ?? 'Please revise your campaign and resubmit.',
              style: TextStyle(color: Colors.red[900]),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to edit campaign
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                ),
                child: const Text('Revise Campaign'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextSteps(BuildContext context) {
    if (campaign.status != 'pending') return const SizedBox.shrink();

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'What Happens Next?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCheckItem('Our team reviews your campaign details'),
            _buildCheckItem('We verify your proof documents'),
            _buildCheckItem('We check for policy compliance'),
            _buildCheckItem('You\'ll receive a notification with our decision'),
            const SizedBox(height: 12),
            Text(
              '⏱️ Average review time: 12-24 hours',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.blue[900]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaign Status'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status header
          Card(
            color: _getStatusColor().withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    _getStatusIcon(),
                    size: 64,
                    color: _getStatusColor(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getStatusMessage(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Campaign info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campaign.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    campaign.cause,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Target: GHS ${campaign.targetAmount.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Rejection reason (if rejected)
          _buildRejectionReason(context),
          if (campaign.status == 'rejected') const SizedBox(height: 24),

          // Next steps (if pending)
          _buildNextSteps(context),
          if (campaign.status == 'pending') const SizedBox(height: 24),

          // Timeline
          const Text(
            'Review Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTimeline(context),
          const SizedBox(height: 24),

          // Contact support
          Card(
            child: ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Need Help?'),
              subtitle: const Text('Contact our support team'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to support screen
              },
            ),
          ),
        ],
      ),
    );
  }
}
