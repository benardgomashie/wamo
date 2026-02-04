import 'package:flutter/material.dart';
import '../core/utils/platform_utils.dart';
import '../core/models/campaign.dart';

/// Payment service wrapper that uses different implementations for web and mobile
class PaymentService {
  static Future<bool> processDonation({
    required BuildContext context,
    required Campaign campaign,
    required double amount,
    required String email,
    required String name,
    bool isAnonymous = false,
  }) async {
    if (PlatformUtils.isWeb) {
      // Web: Show payment info dialog (no Paystack SDK on web)
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Payment Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Web payments are coming soon!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'For now, please use the Wamo mobile app to make donations with:',
              ),
              const SizedBox(height: 8),
              const Text('• Mobile Money (MTN, Vodafone, AirtelTigo)'),
              const Text('• Credit/Debit Cards'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Download the mobile app for full payment functionality',
                        style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Campaign Details:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text('Campaign: ${campaign.title}'),
              Text('Amount: GHS ${amount.toStringAsFixed(2)}'),
              if (!isAnonymous) Text('Your name: $name'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return false; // Payment not completed on web
    } else {
      // Mobile: Use flutter_paystack (will handle in mobile-specific code)
      // This is a placeholder - actual implementation would use flutter_paystack
      throw UnimplementedError('Mobile payment should use flutter_paystack directly');
    }
  }
}
