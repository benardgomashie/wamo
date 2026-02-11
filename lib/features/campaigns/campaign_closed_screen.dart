import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/models/campaign.dart';

class CampaignClosedScreen extends StatelessWidget {
  final Campaign campaign;

  const CampaignClosedScreen({
    super.key,
    required this.campaign,
  });

  String _getClosedReason() {
    if (campaign.status == 'completed') {
      return 'Goal Reached! 🎉';
    } else if (campaign.status == 'expired') {
      return 'Campaign Ended';
    } else if (campaign.status == 'frozen') {
      return 'Campaign Suspended';
    }
    return 'Campaign Closed';
  }

  String _getClosedMessage() {
    if (campaign.status == 'completed') {
      return 'This campaign has successfully reached its funding goal. Thank you to all supporters!';
    } else if (campaign.status == 'expired') {
      return 'This campaign has ended. The deadline has passed and it is no longer accepting donations.';
    } else if (campaign.status == 'frozen') {
      return 'This campaign has been temporarily suspended for review. Donations are currently disabled.';
    }
    return 'This campaign is no longer accepting donations.';
  }

  Color _getStatusColor() {
    if (campaign.status == 'completed') {
      return Colors.green;
    } else if (campaign.status == 'expired') {
      return Colors.orange;
    } else if (campaign.status == 'frozen') {
      return Colors.red;
    }
    return Colors.grey;
  }

  IconData _getStatusIcon() {
    if (campaign.status == 'completed') {
      return Icons.check_circle_outline;
    } else if (campaign.status == 'expired') {
      return Icons.access_time;
    } else if (campaign.status == 'frozen') {
      return Icons.pause_circle_outline;
    }
    return Icons.info_outline;
  }

  void _shareCampaign(BuildContext context) {
    final String text = campaign.status == 'completed'
        ? '${campaign.title} has reached its goal! Thank you to everyone who contributed. #Wamo'
        : 'Check out this campaign: ${campaign.title} #Wamo';

    Share.share(
      text,
      subject: campaign.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double progress = campaign.targetAmount > 0
        ? (campaign.raisedAmount / campaign.targetAmount).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaign Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareCampaign(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status banner
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor(),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _getStatusIcon(),
                  size: 72,
                  color: _getStatusColor(),
                ),
                const SizedBox(height: 16),
                Text(
                  _getClosedReason(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _getClosedMessage(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Campaign summary
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
                  const SizedBox(height: 16),

                  // Progress bar
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
                  ),
                  const SizedBox(height: 12),

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GHS ${campaign.raisedAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'raised of GHS ${campaign.targetAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(),
                            ),
                          ),
                          Text(
                            'of goal',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Additional info based on status
          if (campaign.status == 'completed') ...[
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.celebration, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Success Story',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This campaign successfully reached its funding goal! The creator is now working on fulfilling the campaign objectives.',
                      style: TextStyle(color: Colors.green[900]),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Thank you to all ${campaign.donorCount ?? 0} donors who made this possible!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (campaign.status == 'expired') ...[
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Campaign Ended',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.orange[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This campaign has reached its deadline and is no longer accepting donations.',
                      style: TextStyle(color: Colors.orange[900]),
                    ),
                    if (progress > 0) ...[
                      const SizedBox(height: 12),
                      Text(
                        'The campaign raised ${(progress * 100).toStringAsFixed(0)}% of its goal with help from ${campaign.donorCount ?? 0} donors.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[900],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],

          if (campaign.status == 'frozen') ...[
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Campaign Suspended',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.red[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This campaign has been temporarily suspended while we review it. If you have concerns, please contact our support team.',
                      style: TextStyle(color: Colors.red[900]),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Browse similar campaigns
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to browse campaigns
              },
              icon: const Icon(Icons.explore),
              label: const Text('Browse Active Campaigns'),
            ),
          ),

          const SizedBox(height: 8),

          // Share campaign
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _shareCampaign(context),
              icon: const Icon(Icons.share),
              label: const Text('Share This Campaign'),
            ),
          ),

          const SizedBox(height: 16),

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
