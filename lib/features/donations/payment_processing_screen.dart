import 'package:flutter/material.dart';
import 'dart:async';
import '../../app/theme.dart';
import '../../core/models/campaign.dart';
import '../../core/services/donation_service.dart';
import 'donation_success_screen.dart';
import 'donation_failure_screen.dart';

class PaymentProcessingScreen extends StatefulWidget {
  final String reference;
  final double amount;
  final Campaign campaign;

  const PaymentProcessingScreen({
    super.key,
    required this.reference,
    required this.amount,
    required this.campaign,
  });

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  final _donationService = DonationService();
  Timer? _verificationTimer;
  int _attempts = 0;
  static const int _maxAttempts = 30; // 30 seconds (checking every 1 second)
  
  @override
  void initState() {
    super.initState();
    _startVerification();
  }

  void _startVerification() {
    _verificationTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) async {
        _attempts++;
        
        try {
          final isVerified = await _donationService.verifyTransaction(widget.reference);
          
          if (isVerified) {
            timer.cancel();
            if (!mounted) return;
            
            // Navigate to success screen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => DonationSuccessScreen(
                  reference: widget.reference,
                  amount: widget.amount,
                  campaign: widget.campaign,
                ),
              ),
            );
          } else if (_attempts >= _maxAttempts) {
            // Timeout - payment may still be processing
            timer.cancel();
            if (!mounted) return;
            
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => DonationFailureScreen(
                  reference: widget.reference,
                  amount: widget.amount,
                  campaign: widget.campaign,
                  reason: 'Payment verification timed out. Please check your email for confirmation.',
                  canRetry: false,
                ),
              ),
            );
          }
        } catch (e) {
          // Continue checking on error
          debugPrint('Verification error: $e');
        }
      },
    );
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    super.dispose();
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
              const CircularProgressIndicator(
                strokeWidth: 3,
                color: AppTheme.primaryColor,
              ),
              
              const SizedBox(height: AppTheme.spacingXL),
              
              const Text(
                'Processing Payment',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppTheme.spacingM),
              
              Text(
                'Please wait while we confirm your donation of GH₵${widget.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppTheme.spacingXL),
              
              Card(
                color: AppTheme.infoColor.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingM),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppTheme.infoColor,
                        size: 32,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      const Text(
                        'This may take a few moments',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      const Text(
                        'Do not close this screen or press the back button',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      Text(
                        'Reference: ${widget.reference}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: AppTheme.textSecondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingXL),
              
              LinearProgressIndicator(
                value: _attempts / _maxAttempts,
                backgroundColor: AppTheme.dividerColor,
                color: AppTheme.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
