import 'package:flutter/material.dart';
import '../../core/utils/platform_utils.dart';
import '../../core/models/campaign.dart';

/// Web-compatible donation screen (without flutter_paystack)
class WebDonationScreen extends StatefulWidget {
  final Campaign campaign;

  const WebDonationScreen({
    super.key,
    required this.campaign,
  });

  @override
  State<WebDonationScreen> createState() => _WebDonationScreenState();
}

class _WebDonationScreenState extends State<WebDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isAnonymous = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _processDonation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Show payment info modal
      if (!mounted) return;
      
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
              Text('Campaign: ${widget.campaign.title}'),
              Text('Amount: GHS ${_amountController.text}'),
              if (!_isAnonymous) Text('Your name: ${_nameController.text}'),
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
        title: const Text('Donate'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campaign info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.campaign.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: widget.campaign.raisedAmount / widget.campaign.targetAmount,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'GHS ${widget.campaign.raisedAmount.toStringAsFixed(2)} raised of GHS ${widget.campaign.targetAmount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Amount field
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Donation Amount (GHS)',
                  border: OutlineInputBorder(),
                  prefixText: 'GHS ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  if (amount < 1) {
                    return 'Minimum donation is GHS 1';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Anonymous checkbox
              CheckboxListTile(
                value: _isAnonymous,
                onChanged: (value) {
                  setState(() => _isAnonymous = value ?? false);
                },
                title: const Text('Donate anonymously'),
                contentPadding: EdgeInsets.zero,
              ),

              // Name field (if not anonymous)
              if (!_isAnonymous) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Your Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (!_isAnonymous && (value == null || value.isEmpty)) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 24),

              // Donate button
              ElevatedButton(
                onPressed: _isLoading ? null : _processDonation,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Continue to Payment'),
              ),

              const SizedBox(height: 16),

              // Web notice
              if (PlatformUtils.isWeb)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.amber[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Full payment processing is available on mobile. Download the app for complete donation functionality.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
