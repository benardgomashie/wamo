import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/models/campaign.dart';
import 'donate_screen.dart';

class DonationFailureScreen extends StatelessWidget {
  final String reference;
  final double amount;
  final Campaign campaign;
  final String reason;
  final bool canRetry;

  const DonationFailureScreen({
    super.key,
    required this.reference,
    required this.amount,
    required this.campaign,
    required this.reason,
    this.canRetry = true,
  });

  void _retry(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => DonateScreen(campaign: campaign),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: AppTheme.errorColor,
                  size: 60,
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingXL),
              
              const Text(
                'Payment Failed',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppTheme.spacingM),
              
              Text(
                reason,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppTheme.spacingXL),
              
              // Details card
              Card(
                color: AppTheme.errorColor.withValues(alpha: 0.05),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingM),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        'Campaign',
                        campaign.title,
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      _buildDetailRow(
                        'Amount',
                        'GH₵${amount.toStringAsFixed(2)}',
                      ),
                      _buildDetailRow(
                        'Reference',
                        reference,
                        isMonospace: true,
                      ),
                      _buildDetailRow(
                        'Status',
                        'Failed',
                        valueColor: AppTheme.errorColor,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingL),
              
              // Help card
              Card(
                color: AppTheme.infoColor.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.help_outline, color: AppTheme.infoColor),
                          SizedBox(width: AppTheme.spacingS),
                          Text(
                            'Common reasons for failure:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      _buildHelpPoint('Insufficient funds in account'),
                      _buildHelpPoint('Incorrect payment details'),
                      _buildHelpPoint('Network connectivity issues'),
                      _buildHelpPoint('Payment provider timeout'),
                      const SizedBox(height: AppTheme.spacingM),
                      const Text(
                        'No charges were made to your account.',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Action buttons
              if (canRetry) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _retry(context),
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
              ],
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text(
                    canRetry ? 'Cancel' : 'Go Home',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isMonospace = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: isMonospace ? 'monospace' : null,
                color: valueColor ?? AppTheme.textPrimaryColor,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
