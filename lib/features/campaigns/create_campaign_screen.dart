import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../app/constants.dart';
import '../../app/theme.dart';
import '../../core/models/campaign.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/firestore_service.dart';
import '../../widgets/wamo_toast.dart';
import 'widgets/image_picker_widget.dart';

class CreateCampaignScreen extends StatefulWidget {
  final String? campaignId;

  const CreateCampaignScreen({super.key, this.campaignId});

  @override
  State<CreateCampaignScreen> createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends State<CreateCampaignScreen> {
  final _titleController = TextEditingController();
  final _storyController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _payoutDetailsController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  int _currentStep = 0;
  String _selectedCause = AppConstants.campaignCauses.first;
  String _selectedPayoutMethod = 'mobile_money';
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  List<String> _proofImageUrls = [];
  bool _isLoading = false;
  bool _isEditMode = false;
  Timer? _autoSaveTimer;
  String? _lastSavedDraftId;
  bool _hasUnsavedChanges = false;

  static const List<String> _stepTitles = [
    'Cause',
    'Story',
    'Target',
    'Proof',
    'Payout',
    'Review',
  ];

  static const Map<String, ({String emoji, String subtitle})> _causeMeta = {
    'Medical': (emoji: '🩹', subtitle: 'Hospital bills...'),
    'Education': (emoji: '🎓', subtitle: 'School fees...'),
    'Emergency': (emoji: '🚨', subtitle: 'Urgent assistance...'),
    'Funeral': (emoji: '🕊️', subtitle: 'Funeral costs...'),
    'Community': (emoji: '🫶', subtitle: 'Projects & support for communities'),
  };

  @override
  void initState() {
    super.initState();
    if (widget.campaignId != null) {
      _isEditMode = true;
      _lastSavedDraftId = widget.campaignId;
      _loadCampaign();
    }
    
    // Setup auto-save listeners
    _titleController.addListener(_onFieldChanged);
    _storyController.addListener(_onFieldChanged);
    _targetAmountController.addListener(_onFieldChanged);
    _payoutDetailsController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _titleController.removeListener(_onFieldChanged);
    _storyController.removeListener(_onFieldChanged);
    _targetAmountController.removeListener(_onFieldChanged);
    _payoutDetailsController.removeListener(_onFieldChanged);
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
          _targetAmountController.text =
              campaign.targetAmount.toStringAsFixed(2);
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      helpText: 'Select Campaign End Date',
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  bool _validateStep() {
    if (_currentStep == 1) {
      if (_titleController.text.trim().length < 10) {
        _showError('Title must be at least 10 characters');
        return false;
      }
      if (_storyController.text.trim().length <
          AppConstants.minCampaignStoryLength) {
        _showError(
            'Story must be at least ${AppConstants.minCampaignStoryLength} characters');
        return false;
      }
    }

    if (_currentStep == 2) {
      final amount = double.tryParse(_targetAmountController.text.trim());
      if (amount == null) {
        _showError('Please enter a valid target amount');
        return false;
      }
      if (amount < AppConstants.minDonationAmount ||
          amount > AppConstants.maxCampaignAmount) {
        _showError(
            'Target must be between GH₵ ${AppConstants.minDonationAmount} and GH₵ ${AppConstants.maxCampaignAmount}');
        return false;
      }
    }

    if (_currentStep == 3 && _proofImageUrls.isEmpty) {
      _showError('Please upload at least one proof image');
      return false;
    }

    if (_currentStep == 4 && _payoutDetailsController.text.trim().isEmpty) {
      _showError('Please enter payout details');
      return false;
    }

    return true;
  }

  void _nextStep() {
    if (!_validateStep()) return;
    if (_currentStep < _stepTitles.length - 1) {
      setState(() => _currentStep++);
    }
  }

  void _onCauseSelected(String cause) {
    setState(() => _selectedCause = cause);
    if (_currentStep == 0) {
      _nextStep();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _onFieldChanged() {
    _hasUnsavedChanges = true;
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 3), () {
      _saveDraftSilently();
    });
  }

  Future<void> _saveDraftSilently() async {
    if (!mounted) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;
    if (user == null) return;

    // Basic validation - at least have title or story
    if (_titleController.text.trim().isEmpty && 
        _storyController.text.trim().isEmpty) {
      return;
    }

    try {
      final campaign = Campaign(
        id: _lastSavedDraftId ?? '',
        ownerId: user.id,
        title: _titleController.text.trim().isEmpty 
            ? 'Untitled Campaign' 
            : _titleController.text.trim(),
        cause: _selectedCause,
        story: _storyController.text.trim(),
        targetAmount: double.tryParse(_targetAmountController.text.trim()) ?? 0,
        status: AppConstants.statusDraft,
        createdAt: DateTime.now(),
        endDate: _endDate,
        payoutMethod: _selectedPayoutMethod,
        payoutDetails: _payoutDetailsController.text.trim(),
        proofUrls: _proofImageUrls,
      );

      if (_lastSavedDraftId != null && _lastSavedDraftId!.isNotEmpty) {
        await _firestoreService.updateCampaign(
            _lastSavedDraftId!, campaign.toMap());
      } else {
        final docId = await _firestoreService.createCampaign(campaign);
        _lastSavedDraftId = docId;
      }
      _hasUnsavedChanges = false;
    } catch (e) {
      // Silent fail for auto-save
    }
  }

  Future<void> _saveDraft() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;
    if (user == null) {
      _showError('User not authenticated');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final campaign = Campaign(
        id: _lastSavedDraftId ?? widget.campaignId ?? '',
        ownerId: user.id,
        title: _titleController.text.trim().isEmpty 
            ? 'Untitled Campaign' 
            : _titleController.text.trim(),
        cause: _selectedCause,
        story: _storyController.text.trim(),
        targetAmount: double.tryParse(_targetAmountController.text.trim()) ?? 0,
        status: AppConstants.statusDraft,
        createdAt: DateTime.now(),
        endDate: _endDate,
        payoutMethod: _selectedPayoutMethod,
        payoutDetails: _payoutDetailsController.text.trim(),
        proofUrls: _proofImageUrls,
      );

      if (_lastSavedDraftId != null && _lastSavedDraftId!.isNotEmpty) {
        await _firestoreService.updateCampaign(
            _lastSavedDraftId!, campaign.toMap());
      } else if (_isEditMode && widget.campaignId != null) {
        await _firestoreService.updateCampaign(
            widget.campaignId!, campaign.toMap());
        _lastSavedDraftId = widget.campaignId;
      } else {
        final docId = await _firestoreService.createCampaign(campaign);
        _lastSavedDraftId = docId;
      }

      if (!mounted) return;
      _hasUnsavedChanges = false;
      WamoToast.success(context, 'Draft saved successfully');
    } catch (e) {
      _showError('Failed to save draft: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveCampaign({required bool isDraft}) async {
    if (!isDraft && !_validateStep()) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;
    if (user == null) {
      _showError('User not authenticated');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final campaign = Campaign(
        id: _lastSavedDraftId ?? widget.campaignId ?? '',
        ownerId: user.id,
        title: _titleController.text.trim().isEmpty 
            ? 'Untitled Campaign' 
            : _titleController.text.trim(),
        cause: _selectedCause,
        story: _storyController.text.trim(),
        targetAmount: double.tryParse(_targetAmountController.text.trim()) ?? 0,
        status: isDraft ? AppConstants.statusDraft : AppConstants.statusPending,
        createdAt: DateTime.now(),
        endDate: _endDate,
        payoutMethod: _selectedPayoutMethod,
        payoutDetails: _payoutDetailsController.text.trim(),
        proofUrls: _proofImageUrls,
      );

      if (_lastSavedDraftId != null && _lastSavedDraftId!.isNotEmpty) {
        await _firestoreService.updateCampaign(
            _lastSavedDraftId!, campaign.toMap());
      } else if (_isEditMode && widget.campaignId != null) {
        await _firestoreService.updateCampaign(
            widget.campaignId!, campaign.toMap());
      } else {
        await _firestoreService.createCampaign(campaign);
      }

      if (!mounted) return;
      _hasUnsavedChanges = false;
      WamoToast.success(
        context,
        isDraft ? 'Campaign saved as draft' : 'Campaign submitted for review',
      );
      Navigator.pop(context);
    } catch (e) {
      _showError('Failed to save campaign: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    WamoToast.error(context, message);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _isEditMode) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1200;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Campaign' : 'Create Campaign'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: isDesktop
            ? Row(
                children: [
                  _buildStepSidebar(),
                  Expanded(child: _buildMainContent(maxWidth: 980)),
                ],
              )
            : _buildMainContent(maxWidth: 720),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: AppTheme.surfaceColor,
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacingM,
            AppTheme.spacingS,
            AppTheme.spacingM,
            AppTheme.spacingM,
          ),
          child: _buildActions(),
        ),
      ),
    );
  }

  Widget _buildStepSidebar() {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          right:
              BorderSide(color: AppTheme.dividerColor.withValues(alpha: 0.9)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create Campaign',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppTheme.spacingL),
            for (int i = 0; i < _stepTitles.length; i++) _buildSidebarStep(i),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarStep(int index) {
    final isActive = _currentStep == index;
    final isCompleted = _currentStep > index;
    final bg = isActive
        ? AppTheme.accentColor.withValues(alpha: 0.12)
        : Colors.transparent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: isActive || isCompleted
                ? AppTheme.accentColor
                : AppTheme.dividerColor,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _stepTitles[index],
            style: TextStyle(
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: AppTheme.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent({required double maxWidth}) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          children: [
            Text(
              _isEditMode ? 'Edit Campaign' : 'Create Campaign',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: AppTheme.spacingM),
            _buildProgressHeader(),
            const SizedBox(height: AppTheme.spacingL),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final offsetTween = Tween<Offset>(
                  begin: const Offset(0.0, 0.04),
                  end: Offset.zero,
                );
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: offsetTween.animate(animation),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey<int>(_currentStep),
                child: _buildCurrentStep(),
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Step ${_currentStep + 1} of ${_stepTitles.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / _stepTitles.length,
                minHeight: 5,
                borderRadius: BorderRadius.circular(12),
                backgroundColor: AppTheme.dividerColor,
                color: AppTheme.accentColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildCauseStep();
      case 1:
        return _buildStoryStep();
      case 2:
        return _buildTargetStep();
      case 3:
        return _buildProofStep();
      case 4:
        return _buildPayoutStep();
      default:
        return _buildReviewStep();
    }
  }

  Widget _buildCauseStep() {
    final screenWidth = MediaQuery.of(context).size.width;
    final desktop = screenWidth >= 1200;
    final contentWidth =
        desktop ? 980.0 : (screenWidth - (AppTheme.spacingL * 2));
    const cardGap = AppTheme.spacingM;
    final columns = desktop ? 3 : 2;
    final cardWidth = (contentWidth - (cardGap * (columns - 1))) / columns;

    const causes = AppConstants.campaignCauses;
    final mainCauses = causes.where((c) => c != 'Community').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What is your campaign for?',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppTheme.spacingL),
        Wrap(
          spacing: cardGap,
          runSpacing: cardGap,
          children: [
            for (final cause in mainCauses)
              _buildCauseCard(
                cause: cause,
                width: cardWidth,
                selected: _selectedCause == cause,
              ),
            _buildCauseCard(
              cause: 'Community',
              width: desktop ? (cardWidth * 2) + cardGap : contentWidth,
              selected: _selectedCause == 'Community',
              horizontal: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCauseCard({
    required String cause,
    required double width,
    required bool selected,
    bool horizontal = false,
  }) {
    final meta =
        _causeMeta[cause] ?? (emoji: '📌', subtitle: 'Support campaign...');
    const baseBg = AppTheme.surfaceColor;
    final selectedBorder =
        selected ? AppTheme.accentColor : AppTheme.dividerColor;

    return InkWell(
      onTap: () => _onCauseSelected(cause),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: width,
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: baseBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selectedBorder, width: selected ? 2 : 1),
        ),
        child: horizontal
            ? Row(
                children: [
                  Text(meta.emoji, style: const TextStyle(fontSize: 48)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cause,
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(meta.subtitle,
                            style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meta.emoji, style: const TextStyle(fontSize: 44)),
                  const SizedBox(height: 12),
                  Text(cause, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(meta.subtitle,
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
      ),
    );
  }

  Widget _buildStoryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tell your story', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppTheme.spacingL),
        TextFormField(
          controller: _titleController,
          maxLength: AppConstants.maxCampaignTitleLength,
          decoration: const InputDecoration(
            labelText: 'Campaign Title',
            hintText: 'e.g., Help Save My Sister\'s Life',
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        TextFormField(
          controller: _storyController,
          maxLines: 8,
          maxLength: AppConstants.maxCampaignStoryLength,
          decoration: const InputDecoration(
            labelText: 'Your Story',
            hintText: 'Explain why you need help and how funds will be used...',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildTargetStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Set target and timeline',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppTheme.spacingL),
        TextFormField(
          controller: _targetAmountController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
          ],
          decoration: const InputDecoration(
            labelText: 'Target Amount (GH₵)',
            hintText: '5000.00',
            prefixText: 'GH₵ ',
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        InkWell(
          onTap: _selectEndDate,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Campaign End Date',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(
              '${_endDate.day}/${_endDate.month}/${_endDate.year}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProofStep() {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Add proof images', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppTheme.spacingL),
        ImagePickerWidget(
          initialImages: _proofImageUrls,
          onImagesChanged: (urls) => setState(() => _proofImageUrls = urls),
          maxImages: AppConstants.maxImagesPerCampaign,
          uploadPath: 'campaigns/${user?.id ?? 'temp'}',
        ),
      ],
    );
  }

  Widget _buildPayoutStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How should payouts work?',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppTheme.spacingL),
        DropdownButtonFormField<String>(
          initialValue: _selectedPayoutMethod,
          decoration: const InputDecoration(labelText: 'Payout Method'),
          items: const [
            DropdownMenuItem(
                value: 'mobile_money', child: Text('Mobile Money')),
            DropdownMenuItem(value: 'bank', child: Text('Bank Account')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedPayoutMethod = value);
            }
          },
        ),
        const SizedBox(height: AppTheme.spacingM),
        TextFormField(
          controller: _payoutDetailsController,
          keyboardType: _selectedPayoutMethod == 'mobile_money'
              ? TextInputType.phone
              : TextInputType.text,
          decoration: InputDecoration(
            labelText: _selectedPayoutMethod == 'mobile_money'
                ? 'Mobile Money Number'
                : 'Bank Account Details',
            hintText: _selectedPayoutMethod == 'mobile_money'
                ? '0241234567'
                : 'Account Number and Bank Name',
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    final amount = _targetAmountController.text.trim().isEmpty
        ? '0.00'
        : _targetAmountController.text.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review your campaign',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppTheme.spacingL),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _reviewRow('Cause', _selectedCause),
                _reviewRow('Title', _titleController.text.trim()),
                _reviewRow('Target', 'GH₵ $amount'),
                _reviewRow(
                    'Payout',
                    _selectedPayoutMethod == 'mobile_money'
                        ? 'Mobile Money'
                        : 'Bank'),
                _reviewRow(
                    'Proof Images', '${_proofImageUrls.length} uploaded'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final isFinal = _currentStep == _stepTitles.length - 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - Back button
          SizedBox(
            width: 80,
            child: _currentStep > 0
                ? TextButton(
                    onPressed: _isLoading ? null : _previousStep,
                    child: const Text('Back'),
                  )
                : const SizedBox.shrink(),
          ),
          
          // Center - Save Draft button (on intermediate steps)
          if (_currentStep > 0 && !isFinal)
            TextButton.icon(
              onPressed: _isLoading ? null : _saveDraft,
              icon: const Icon(Icons.save_outlined, size: 18),
              label: Text(
                _hasUnsavedChanges ? 'Save Draft *' : 'Save Draft',
                style: TextStyle(
                  color: _hasUnsavedChanges ? Colors.orange : null,
                ),
              ),
            ),
          
          const Spacer(),
          
          // Right side - Continue or Submit buttons
          if (!isFinal)
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _nextStep,
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.arrow_forward, size: 20),
              label: const Text('Continue'),
            ),
          if (isFinal) ...[
            OutlinedButton(
              onPressed: _isLoading ? null : () => _saveCampaign(isDraft: true),
              child: const Text('Save Draft'),
            ),
            const SizedBox(width: AppTheme.spacingM),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _saveCampaign(isDraft: false),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit for Review'),
            ),
          ],
        ],
      ),
    );
  }
}
