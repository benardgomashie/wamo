import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../app/theme.dart';
import '../../app/constants.dart';
import '../../core/models/campaign.dart';

class DonationSuccessScreen extends StatelessWidget {
  final String reference;
  final double amount;
  final Campaign campaign;

  const DonationSuccessScreen({
    super.key,
    required this.reference,
    required this.amount,
    required this.campaign,
  });

  void _shareDonation() {
    final message = '''
I just donated GH₵${amount.toStringAsFixed(0)} to "${campaign.title}" on Wamo! 

Join me in supporting this cause: ${AppConstants.appUrl}/campaigns/${campaign.id}

#GiveHelpReach #Wamo
''';
    
    Share.share(message);
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
              // Success icon
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppTheme.successColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingXL),
              
              const Text(
                'Thank You!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppTheme.spacingM),
              
              Text(
                'Your donation of GH₵${amount.toStringAsFixed(2)} was successful',
                style: const TextStyle(
                  fontSize: 18,
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppTheme.spacingXL),
              
              // Campaign card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingM),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.campaign,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: AppTheme.spacingS),
                          Expanded(
                            child: Text(
                              campaign.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      const Divider(),
                      const SizedBox(height: AppTheme.spacingM),
                      _buildDetailRow(
                        'Transaction Reference',
                        reference,
                        isMonospace: true,
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      _buildDetailRow(
                        'Amount',
                        'GH₵${amount.toStringAsFixed(2)}',
                      ),
                      _buildDetailRow(
                        'Status',
                        'Successful',
                        valueColor: AppTheme.successColor,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingL),
              
              // Info card
              Card(
                color: AppTheme.infoColor.withValues(alpha: 0.1),
                child: const Padding(
                  padding: EdgeInsets.all(AppTheme.paddingM),
                  child: Row(
                    children: [
                      Icon(Icons.email_outlined, color: AppTheme.infoColor),
                      SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: Text(
                          'A receipt has been sent to your email',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Share button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _shareDonation,
                  icon: const Icon(Icons.share),
                  label: const Text(
                    'Share Your Support',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingM),
              
              // Done button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to home or campaign detail
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(
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
            ),
          ),
        ],
      ),
    );
  }
}
