import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../app/constants.dart';
import '../../core/models/campaign.dart';
import '../../core/services/donation_service.dart';
import '../../core/providers/user_provider.dart';
import '../../core/utils/responsive_utils.dart';
import '../../widgets/wamo_toast.dart';
import 'payment_processing_screen.dart';

class DonateScreen extends StatefulWidget {
  final Campaign campaign;

  const DonateScreen({
    super.key,
    required this.campaign,
  });

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _donationService = DonationService();
  
  // Form fields
  double? _selectedAmount;
  final _customAmountController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  
  bool _isAnonymous = false;
  bool _isLoading = false;
  
  List<double> _suggestedAmounts = [];
  Map<String, double>? _feeBreakdown;

  @override
  void initState() {
    super.initState();
    _initializeDonationService();
    _loadUserInfo();
    _suggestedAmounts = _donationService.getSuggestedAmounts(widget.campaign);
  }

  Future<void> _initializeDonationService() async {
    await _donationService.initialize();
  }

  void _loadUserInfo() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user != null) {
      // Pre-fill if user is logged in (optional optimization)
      _nameController.text = userProvider.user!.name;
      _emailController.text = userProvider.user!.email ?? '';
      _phoneController.text = userProvider.user!.phone;
    }
    // If not logged in, user can still donate as guest
  }

  void _selectAmount(double amount) {
    setState(() {
      _selectedAmount = amount;
      _customAmountController.clear();
      _calculateFees();
    });
  }

  void _onCustomAmountChanged(String value) {
    final amount = double.tryParse(value);
    if (amount != null) {
      setState(() {
        _selectedAmount = amount;
        _calculateFees();
      });
    } else {
      setState(() {
        _selectedAmount = null;
        _feeBreakdown = null;
      });
    }
  }

  void _calculateFees() {
    if (_selectedAmount != null) {
      setState(() {
        _feeBreakdown = _donationService.calculateFees(_selectedAmount!);
      });
    }
  }

  Future<void> _processDonation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedAmount == null) {
      WamoToast.warning(context, 'Please select or enter a donation amount');
      return;
    }

    final validationError = _donationService.validateAmount(_selectedAmount);
    if (validationError != null) {
      WamoToast.warning(context, validationError);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final reference = await _donationService.initiateDonation(
        context: context,
        campaignId: widget.campaign.id,
        amount: _selectedAmount!,
        email: _emailController.text.trim(),
        donorName: _isAnonymous ? null : _nameController.text.trim(),
        donorContact: _isAnonymous ? null : _phoneController.text.trim(),
        message: _messageController.text.trim(),
        isAnonymous: _isAnonymous,
      );

      if (!context.mounted) return;

      // Navigate to processing screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PaymentProcessingScreen(
            reference: reference,
            amount: _selectedAmount!,
            campaign: widget.campaign,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      setState(() => _isLoading = false);
      
      WamoToast.error(context, e.toString());
    }
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, screenWidth) {
        final isDesktop = deviceType == DeviceType.desktop;
        
        if (isDesktop) {
          return _buildDesktopLayout();
        } else {
          return _buildMobileLayout();
        }
      },
    );
  }

  /// Desktop layout - centered card modal style
  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor.withOpacity(0.95),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Container(
            width: 520,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.05),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.surfaceColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Donate to Campaign',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.campaign.title,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Form content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Amount selection
                        _buildAmountSelection(),
                        
                        const SizedBox(height: 24),
                        
                        // Fee breakdown
                        if (_feeBreakdown != null) ...[
                          _buildFeeBreakdown(),
                          const SizedBox(height: 24),
                        ],
                        
                        // Donor information
                        _buildDonorInformation(),
                        
                        const SizedBox(height: 24),
                        
                        // Message (optional)
                        _buildMessageField(),
                        
                        const SizedBox(height: 32),
                        
                        // Donate button
                        _buildDonateButton(),
                        
                        const SizedBox(height: 16),
                        
                        // Security notice
                        _buildSecurityNotice(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Mobile layout - full screen
  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Campaign'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.paddingM),
          children: [
            // Campaign info card
            _buildCampaignCard(),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Amount selection
            _buildAmountSelection(),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Fee breakdown
            if (_feeBreakdown != null) _buildFeeBreakdown(),
            
            if (_feeBreakdown != null) const SizedBox(height: AppTheme.spacingL),
            
            // Donor information
            _buildDonorInformation(),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Message (optional)
            _buildMessageField(),
            
            const SizedBox(height: AppTheme.spacingXL),
            
            // Donate button
            _buildDonateButton(),
            
            const SizedBox(height: AppTheme.spacingM),
            
            // Security notice
            _buildSecurityNotice(),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignCard() {
    final progress = (widget.campaign.raisedAmount / widget.campaign.targetAmount * 100).clamp(0, 100);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.campaign.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: AppTheme.dividerColor,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GH₵${widget.campaign.raisedAmount.toStringAsFixed(0)} raised',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Text(
                  'of GH₵${widget.campaign.targetAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Amount',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        
        // Suggested amounts
        Wrap(
          spacing: AppTheme.spacingS,
          runSpacing: AppTheme.spacingS,
          children: _suggestedAmounts.map((amount) {
            final isSelected = _selectedAmount == amount;
            return ChoiceChip(
              label: Text(_donationService.formatCurrency(amount)),
              selected: isSelected,
              onSelected: (_) => _selectAmount(amount),
              selectedColor: AppTheme.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
        
        const SizedBox(height: AppTheme.spacingM),
        
        // Custom amount
        TextFormField(
          controller: _customAmountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Or enter custom amount',
            prefixText: 'GH₵ ',
            hintText: '0.00',
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          onChanged: _onCustomAmountChanged,
          validator: (value) {
            if (_selectedAmount == null) {
              return 'Please select or enter an amount';
            }
            return _donationService.validateAmount(_selectedAmount);
          },
        ),
      ],
    );
  }

  Widget _buildFeeBreakdown() {
    return Card(
      color: AppTheme.infoColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: AppTheme.infoColor),
                SizedBox(width: AppTheme.spacingS),
                Text(
                  'Fee Breakdown',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            _buildFeeRow('Your donation', _feeBreakdown!['donation']!),
            _buildFeeRow(
              'Platform fee (${AppConstants.platformFeePercentage}%)',
              _feeBreakdown!['platformFee']!,
            ),
            _buildFeeRow('Payment processing', _feeBreakdown!['paystackFee']!),
            const Divider(),
            _buildFeeRow(
              'Total',
              _feeBreakdown!['total']!,
              isBold: true,
            ),
            const SizedBox(height: AppTheme.spacingS),
            const Text(
              'Campaign creator receives the full donation amount. Fees support platform operations.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 15 : 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            'GH₵${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isBold ? 15 : 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonorInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                Checkbox(
                  value: _isAnonymous,
                  onChanged: (value) {
                    setState(() => _isAnonymous = value ?? false);
                  },
                ),
                const Text('Donate anonymously'),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),
        
        if (!_isAnonymous) ...[
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your name',
            ),
            validator: (value) {
              if (!_isAnonymous && (value == null || value.trim().isEmpty)) {
                return 'Name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: '0XX XXX XXXX',
            ),
            validator: (value) {
              if (!_isAnonymous && (value == null || value.trim().isEmpty)) {
                return 'Phone number is required';
              }
              return null;
            },
          ),
          const SizedBox(height: AppTheme.spacingM),
        ],
        
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'your@email.com',
            helperText: 'For payment receipt only',
          ),
          validator: (value) {
            // Email is now optional - phone can be used for receipt
            if (value != null && value.trim().isNotEmpty && !value.contains('@')) {
              return 'Please enter a valid email';
            }
            // At least one contact method required (email or phone)
            if ((value == null || value.trim().isEmpty) && 
                (_phoneController.text.trim().isEmpty || _isAnonymous)) {
              return 'Email or phone number required for receipt';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMessageField() {
    return TextFormField(
      controller: _messageController,
      maxLines: 3,
      maxLength: 200,
      decoration: const InputDecoration(
        labelText: 'Message (Optional)',
        hintText: 'Leave a message of support...',
      ),
    );
  }

  Widget _buildDonateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _processDonation,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                _feeBreakdown != null
                    ? 'Donate GH₵${_feeBreakdown!['total']!.toStringAsFixed(2)}'
                    : 'Continue to Payment',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildSecurityNotice() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline, size: 16, color: AppTheme.textSecondaryColor),
        SizedBox(width: AppTheme.spacingS),
        Text(
          'Secure payment powered by Paystack',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}

