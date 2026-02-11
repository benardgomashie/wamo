import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../app/constants.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/firestore_service.dart';
import '../../core/models/campaign.dart';
import '../../widgets/wamo_toast.dart';
import 'widgets/image_picker_widget.dart';

class CreateCampaignScreen extends StatefulWidget {
  final String? campaignId; // For editing existing campaign
  
  const CreateCampaignScreen({
    super.key,
    this.campaignId,
  });

  @override
  State<CreateCampaignScreen> createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends State<CreateCampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _storyController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _payoutDetailsController = TextEditingController();
  
  final FirestoreService _firestoreService = FirestoreService();
  
  String _selectedCause = AppConstants.campaignCauses.first;
  String _selectedPayoutMethod = 'mobile_money';
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  List<String> _proofImageUrls = [];
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.campaignId != null) {
      _isEditMode = true;
      _loadCampaign();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _storyController.dispose();
    _targetAmountController.dispose();
    _payoutDetailsController.dispose();
    super.dispose();
  }

  Future<void> _loadCampaign() async {
    setState(() => _isLoading = true);
    
    try {
      final campaign = await _firestoreService.getCampaign(widget.campaignId!);
      
      if (campaign != null) {
        setState(() {
          _titleController.text = campaign.title;
          _storyController.text = campaign.story;
          _targetAmountController.text = campaign.targetAmount.toString();
          _selectedCause = campaign.cause;
          _endDate = campaign.endDate;
          _selectedPayoutMethod = campaign.payoutMethod;
          _payoutDetailsController.text = campaign.payoutDetails;
          _proofImageUrls = campaign.proofUrls;
        });
      }
    } catch (e) {
      _showError('Failed to load campaign: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      helpText: 'Select Campaign End Date',
    );
    
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _saveCampaign({bool isDraft = true}) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;

    if (user == null) {
      _showError('User not authenticated');
      return;
    }

    // Require at least one proof image for submission
    if (!isDraft && _proofImageUrls.isEmpty) {
      _showError('Please upload at least one proof image');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final campaign = Campaign(
        id: widget.campaignId ?? '',
        ownerId: user.id,
        title: _titleController.text.trim(),
        cause: _selectedCause,
        story: _storyController.text.trim(),
        targetAmount: double.parse(_targetAmountController.text),
        status: isDraft ? 'draft' : 'pending',
        createdAt: DateTime.now(),
        endDate: _endDate,
        payoutMethod: _selectedPayoutMethod,
        payoutDetails: _payoutDetailsController.text.trim(),
        proofUrls: _proofImageUrls,
      );

      if (_isEditMode) {
        await _firestoreService.updateCampaign(
          widget.campaignId!,
          campaign.toMap(),
        );
      } else {
        await _firestoreService.createCampaign(campaign);
      }

      if (!context.mounted) return;

      WamoToast.success(
        context,
        isDraft 
            ? 'Campaign saved as draft' 
            : 'Campaign submitted for review',
      );

      Navigator.pop(context);
    } catch (e) {
      _showError('Failed to save campaign: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    WamoToast.error(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    if (_isLoading && !_isEditMode) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Campaign' : 'Create Campaign'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          children: [
            // Verification warning
            if (user?.verificationStatus != 'verified')
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                margin: const EdgeInsets.only(bottom: AppTheme.spacingL),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: Text(
                        'Your account needs verification before campaigns can go live',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Campaign Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Campaign Title',
                hintText: 'e.g., Help Save My Sister\'s Life',
                helperText: 'Make it clear and compelling',
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLength: 100,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a campaign title';
                }
                if (value.trim().length < 10) {
                  return 'Title must be at least 10 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Campaign Cause
            DropdownButtonFormField<String>(
              initialValue: _selectedCause,
              decoration: const InputDecoration(
                labelText: 'Campaign Cause',
                helperText: 'Select the category that best fits',
              ),
              items: AppConstants.campaignCauses.map((cause) {
                return DropdownMenuItem(
                  value: cause,
                  child: Text(cause),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCause = value);
                }
              },
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Campaign Story
            TextFormField(
              controller: _storyController,
              decoration: const InputDecoration(
                labelText: 'Your Story',
                hintText: 'Explain why you need help and how funds will be used...',
                helperText: 'Be detailed and honest',
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              maxLength: 2000,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please tell your story';
                }
                if (value.trim().length < 100) {
                  return 'Story must be at least 100 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Target Amount
            TextFormField(
              controller: _targetAmountController,
              decoration: const InputDecoration(
                labelText: 'Target Amount (GH₵)',
                hintText: '5000.00',
                helperText: 'Min: GH₵ ${AppConstants.minDonationAmount}, Max: GH₵ ${AppConstants.maxCampaignAmount}',
                prefixText: 'GH₵ ',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter target amount';
                }
                final amount = double.tryParse(value);
                if (amount == null) {
                  return 'Please enter a valid amount';
                }
                if (amount < AppConstants.minDonationAmount) {
                  return 'Minimum amount is GH₵ ${AppConstants.minDonationAmount}';
                }
                if (amount > AppConstants.maxCampaignAmount) {
                  return 'Maximum amount is GH₵ ${AppConstants.maxCampaignAmount}';
                }
                return null;
              },
            ),

            const SizedBox(height: AppTheme.spacingL),

            // End Date
            InkWell(
              onTap: _selectEndDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Campaign End Date',
                  helperText: 'Maximum 90 days from today',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Payout Method
            DropdownButtonFormField<String>(
              initialValue: _selectedPayoutMethod,
              decoration: const InputDecoration(
                labelText: 'Payout Method',
                helperText: 'How you want to receive funds',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'mobile_money',
                  child: Text('Mobile Money'),
                ),
                DropdownMenuItem(
                  value: 'bank',
                  child: Text('Bank Account'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPayoutMethod = value;
                    _payoutDetailsController.clear();
                  });
                }
              },
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Payout Details
            TextFormField(
              controller: _payoutDetailsController,
              decoration: InputDecoration(
                labelText: _selectedPayoutMethod == 'mobile_money'
                    ? 'Mobile Money Number'
                    : 'Bank Account Details',
                hintText: _selectedPayoutMethod == 'mobile_money'
                    ? '0241234567'
                    : 'Account Number and Bank Name',
                helperText: 'Funds will be sent here after campaign ends',
              ),
              keyboardType: _selectedPayoutMethod == 'mobile_money'
                  ? TextInputType.phone
                  : TextInputType.text,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter payout details';
                }
                return null;
              },
            ),

            const SizedBox(height: AppTheme.spacingXL),

            // Image Upload
            ImagePickerWidget(
              initialImages: _proofImageUrls,
              onImagesChanged: (urls) {
                setState(() {
                  _proofImageUrls = urls;
                });
              },
              maxImages: 5,
              uploadPath: 'campaigns/${user?.id ?? 'temp'}',
            ),

            const SizedBox(height: AppTheme.spacingXL),

            // Info box
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      SizedBox(width: AppTheme.spacingS),
                      Text(
                        'Important Information',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    '• Platform fee: ${AppConstants.platformFeePercentage}% (paid by donors)\n'
                    '• Campaigns are reviewed before going live\n'
                    '• Upload proof documents to increase trust\n'
                    '• Be honest and transparent in your story',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingXL),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => _saveCampaign(isDraft: true),
                    child: const Text('Save as Draft'),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _saveCampaign(isDraft: false),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Submit for Review'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingL),
          ],
        ),
      ),
    );
  }
}
