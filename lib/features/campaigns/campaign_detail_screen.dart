import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/constants.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/models/campaign.dart';
import '../../core/models/campaign_update.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/firestore_service.dart';
import '../../core/utils/responsive_utils.dart';
import '../../widgets/wamo_toast.dart';

class CampaignDetailScreen extends StatefulWidget {
  final String campaignId;

  const CampaignDetailScreen({super.key, required this.campaignId});

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  Campaign? _campaign;
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  bool _showFullAbout = false;

  @override
  void initState() {
    super.initState();
    _loadCampaign();
  }

  Future<void> _loadCampaign() async {
    setState(() => _isLoading = true);
    try {
      final campaign = await _firestoreService.getCampaign(widget.campaignId);
      final stats = await _firestoreService.getCampaignStats(widget.campaignId);
      if (!mounted) return;
      setState(() {
        _campaign = campaign;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      WamoToast.error(context, 'Error loading campaign: $e');
    }
  }

  String _shareMessage() {
    if (_campaign == null) return '';
    final story = _campaign!.story.trim();
    final preview =
        story.length > 120 ? '${story.substring(0, 120)}...' : story;
    return 'Help support: ${_campaign!.title}\n\n$preview\n\nDonate on Wamo: ${AppConstants.appUrl}/campaigns/${widget.campaignId}';
  }

  Future<void> _shareCampaign() async {
    final message = _shareMessage();
    if (message.isEmpty) return;
    final whatsappUrl =
        Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      return;
    }
    if (!mounted) return;
    Share.share(message, subject: _campaign?.title ?? 'Campaign');
  }

  Future<void> _copyLink() async {
    final link = '${AppConstants.appUrl}/campaigns/${widget.campaignId}';
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;
    WamoToast.success(context, 'Campaign link copied');
  }

  void _donate() {
    if (_campaign == null) return;
    Navigator.pushNamed(
      context,
      AppRoutes.donate,
      arguments: {'campaign': _campaign},
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    final isOwner = user?.id == _campaign?.ownerId;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_campaign == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Campaign not found')),
      );
    }

    return ResponsiveBuilder(
      builder: (context, deviceType, _) {
        if (deviceType == DeviceType.desktop) {
          return _buildDesktopLayout(isOwner);
        }
        return _buildMobileLayout(isOwner);
      },
    );
  }

  Widget _buildDesktopLayout(bool isOwner) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Text('🧡', style: TextStyle(fontSize: 28)),
            SizedBox(width: 8),
            Text('wamo'),
          ],
        ),
        centerTitle: false,
        actions: [
          TextButton(onPressed: () {}, child: const Text('Start Fundraiser')),
          TextButton(onPressed: () {}, child: const Text('Login')),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Login'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: MaxWidthContainer(
        maxWidth: 1280,
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroImage(height: 260),
                  const SizedBox(height: 20),
                  Text(_campaign!.title,
                      style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: 8),
                  _buildCreatorMeta(),
                  const SizedBox(height: 20),
                  Divider(color: AppTheme.dividerColor.withValues(alpha: 0.7)),
                  const SizedBox(height: 20),
                  _buildAboutSection(),
                  const SizedBox(height: 20),
                  Divider(color: AppTheme.dividerColor.withValues(alpha: 0.7)),
                  const SizedBox(height: 20),
                  _buildDesktopUpdatesAndDocs(),
                ],
              ),
            ),
            const SizedBox(width: 24),
            SizedBox(
              width: 340,
              child: Column(
                children: [
                  _buildDonationPanel(compact: false),
                  const SizedBox(height: 20),
                  _buildDesktopShareBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(bool isOwner) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('🧡', style: TextStyle(fontSize: 26)),
            SizedBox(width: 6),
            Text('wamo'),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: _shareCampaign),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroImage(height: 290),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_campaign!.title,
                      style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: 10),
                  _buildCreatorMeta(),
                  const SizedBox(height: 16),
                  _buildDonationPanel(compact: true),
                ],
              ),
            ),
            Divider(color: AppTheme.dividerColor.withValues(alpha: 0.8)),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: _buildAboutSection(),
            ),
            Divider(color: AppTheme.dividerColor.withValues(alpha: 0.8)),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              child: _buildUpdatesSection(mobile: true),
            ),
            Divider(color: AppTheme.dividerColor.withValues(alpha: 0.8)),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              child: _buildDocumentsSection(),
            ),
            Divider(color: AppTheme.dividerColor.withValues(alpha: 0.8)),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingM,
                AppTheme.spacingS,
                AppTheme.spacingM,
                AppTheme.spacingM,
              ),
              child: _buildShareRow(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: ElevatedButton(
            onPressed:
                _campaign!.status == AppConstants.statusActive ? _donate : null,
            child: const Text('Donate Now'),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage({required double height}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: _campaign!.proofUrls.isNotEmpty
          ? Image.network(
              _campaign!.proofUrls.first,
              width: double.infinity,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _heroFallback(height),
            )
          : _heroFallback(height),
    );
  }

  Widget _heroFallback(double height) {
    return Container(
      height: height,
      color: AppTheme.backgroundColor,
      child: const Center(
        child: Icon(Icons.campaign, size: 72, color: AppTheme.textMutedColor),
      ),
    );
  }

  Widget _buildCreatorMeta() {
    final daysAgo = DateTime.now().difference(_campaign!.createdAt).inDays;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 8,
      children: [
        const CircleAvatar(
          radius: 15,
          child: Icon(Icons.person, size: 16),
        ),
        Text(
          'Campaign Owner',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Icon(Icons.verified, size: 18, color: AppTheme.accentColor),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: Text(_campaign!.cause,
              style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text('· $daysAgo days ago',
            style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildDonationPanel({required bool compact}) {
    final raised = _campaign!.raisedAmount;
    final target = _campaign!.targetAmount;
    final percent = _campaign!.progressPercentage;
    final donorCount = _stats?['unique_donors'] ?? _campaign!.donationCount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyLarge,
                children: [
                  TextSpan(
                    text: 'GH₵ ${raised.toStringAsFixed(0)} ',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 22),
                  ),
                  TextSpan(text: 'raised of GH₵ ${target.toStringAsFixed(0)}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percent / 100,
              minHeight: 10,
              borderRadius: BorderRadius.circular(12),
              backgroundColor: AppTheme.dividerColor,
            ),
            const SizedBox(height: 10),
            Text('$donorCount donors',
                style: Theme.of(context).textTheme.bodyLarge),
            if (!compact) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: const [
                  _AmountChip(label: 'GHS 50'),
                  _AmountChip(label: 'GHS 100'),
                  _AmountChip(label: 'Other'),
                ],
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _campaign!.status == AppConstants.statusActive
                    ? _donate
                    : null,
                child: const Text('Donate Now'),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Platform fee: ${AppConstants.platformFeePercentage}% · Secure payments powered by Paystack',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    final full = _campaign!.story.trim();
    final short = full.length > 220 ? '${full.substring(0, 220)}...' : full;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About this campaign',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        Text(_showFullAbout ? full : short,
            style: Theme.of(context).textTheme.bodyLarge),
        if (full.length > 220)
          TextButton(
            onPressed: () => setState(() => _showFullAbout = !_showFullAbout),
            child: Text(_showFullAbout ? 'Show less' : 'Read more'),
          ),
      ],
    );
  }

  Widget _buildUpdatesSection({required bool mobile}) {
    return StreamBuilder<List<CampaignUpdate>>(
      stream: _firestoreService.getCampaignUpdatesStream(widget.campaignId),
      builder: (context, snapshot) {
        final updates = snapshot.data ?? const <CampaignUpdate>[];
        if (updates.isEmpty) {
          return _sectionShell(
            title: 'Updates (0)',
            child: Text('No updates yet.',
                style: Theme.of(context).textTheme.bodyLarge),
          );
        }
        return _sectionShell(
          title: 'Updates (${updates.length})',
          child: Column(
            children: updates.take(mobile ? 2 : 3).map((u) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_formatDate(u.createdAt)),
                subtitle: Text(
                  u.text,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildDocumentsSection() {
    if (_campaign!.proofUrls.isEmpty) {
      return _sectionShell(
        title: 'Supporting Documents',
        child: Text('No supporting documents uploaded.',
            style: Theme.of(context).textTheme.bodyLarge),
      );
    }

    return _sectionShell(
      title: 'Supporting Documents',
      trailing: TextButton(onPressed: () {}, child: const Text('Download all')),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _campaign!.proofUrls.take(6).map((url) {
          return InkWell(
            onTap: () async {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: Container(
              width: 96,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.dividerColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  const Icon(Icons.insert_drive_file_outlined, size: 36),
                  const SizedBox(height: 6),
                  Text(
                    'document.pdf',
                    style: Theme.of(context).textTheme.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _sectionShell({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            if (trailing != null) trailing,
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _buildDesktopUpdatesAndDocs() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildUpdatesSection(mobile: false)),
        const SizedBox(width: 18),
        Expanded(child: _buildDocumentsSection()),
      ],
    );
  }

  Widget _buildDesktopShareBar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: _buildShareRow(),
      ),
    );
  }

  Widget _buildShareRow() {
    return Row(
      children: [
        Text('Share', style: Theme.of(context).textTheme.titleLarge),
        const Spacer(),
        IconButton(
          onPressed: _shareCampaign,
          icon: const Icon(Icons.chat_bubble_outline),
          tooltip: 'WhatsApp',
        ),
        IconButton(
          onPressed: _copyLink,
          icon: const Icon(Icons.link_outlined),
          tooltip: 'Copy Link',
        ),
        IconButton(
          onPressed: () => Share.share(_shareMessage(),
              subject: _campaign?.title ?? 'Campaign'),
          icon: const Icon(Icons.share_outlined),
          tooltip: 'Share',
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}

class _AmountChip extends StatelessWidget {
  final String label;
  const _AmountChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}
