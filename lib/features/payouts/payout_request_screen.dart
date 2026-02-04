import 'package:flutter/material.dart';
import '../../core/services/payout_service.dart';
import '../../app/theme.dart';

class PayoutRequestScreen extends StatefulWidget {
  final String campaignId;
  final double availableAmount;
  final double platformFeeDeducted;

  const PayoutRequestScreen({
    Key? key,
    required this.campaignId,
    required this.availableAmount,
    required this.platformFeeDeducted,
  }) : super(key: key);

  @override
  State<PayoutRequestScreen> createState() => _PayoutRequestScreenState();
}

class _PayoutRequestScreenState extends State<PayoutRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _momoNumberController = TextEditingController();
  final _payoutService = PayoutService();

  String _selectedNetwork = 'MTN';
  bool _isLoading = false;

  final List<String> _networks = ['MTN', 'Vodafone', 'AirtelTigo'];

  @override
  void dispose() {
    _momoNumberController.dispose();
    super.dispose();
  }

  Future<void> _submitPayoutRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _payoutService.requestPayout(
        campaignId: widget.campaignId,
        momoNumber: _momoNumberController.text.trim(),
        momoNetwork: _selectedNetwork,
      );

      if (!mounted) return;

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Payout Requested'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your payout request has been submitted successfully.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.infoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What happens next?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('1. Admin will review your request'),
                    const Text('2. Approval typically takes 1-2 business days'),
                    const Text('3. Once approved, funds transfer to your Mobile Money'),
                    const Text('4. You\'ll receive SMS confirmation'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to dashboard
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to request payout: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Payout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount summary card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payout Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryRow(
                        'Total Raised',
                        'GHS ${(widget.availableAmount + widget.platformFeeDeducted).toStringAsFixed(2)}',
                      ),
                      const Divider(height: 24),
                      _buildSummaryRow(
                        'Platform Fee (4%)',
                        'GHS ${widget.platformFeeDeducted.toStringAsFixed(2)}',
                        isDeduction: true,
                      ),
                      const Divider(height: 24),
                      _buildSummaryRow(
                        'You Receive',
                        'GHS ${widget.availableAmount.toStringAsFixed(2)}',
                        isHighlight: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Important notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.warningColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.warningColor),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Ensure the Mobile Money number belongs to you. Incorrect numbers cannot be reversed.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Mobile Money network selection
              const Text(
                'Select Mobile Money Network',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: _networks.map((network) {
                  final isSelected = _selectedNetwork == network;
                  return ChoiceChip(
                    label: Text(network),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedNetwork = network);
                      }
                    },
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Mobile Money number input
              const Text(
                'Mobile Money Number',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _momoNumberController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: '0XX XXX XXXX',
                  prefixIcon: Icon(Icons.phone_android),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Mobile Money number';
                  }
                  final cleaned = value.replaceAll(RegExp(r'\s'), '');
                  if (cleaned.length != 10) {
                    return 'Mobile Money number must be 10 digits';
                  }
                  if (!cleaned.startsWith('0')) {
                    return 'Number must start with 0';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitPayoutRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          'Request Payout - GHS ${widget.availableAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Terms notice
              Text(
                'By requesting this payout, you confirm that all campaign information is accurate and the Mobile Money number belongs to you.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isDeduction = false, bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isHighlight ? 18 : 14,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            color: isDeduction ? Colors.red[700] : Colors.black87,
          ),
        ),
        Text(
          isDeduction ? '- $value' : value,
          style: TextStyle(
            fontSize: isHighlight ? 20 : 14,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            color: isHighlight ? AppTheme.primaryColor : (isDeduction ? Colors.red[700] : Colors.black87),
          ),
        ),
      ],
    );
  }
}
