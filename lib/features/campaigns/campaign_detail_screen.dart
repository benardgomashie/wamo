import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../app/theme.dart';
import '../../app/constants.dart';
import '../../app/routes.dart';
import '../../core/models/campaign.dart';
import '../../core/models/donation.dart';
import '../../core/models/campaign_update.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/firestore_service.dart';

class CampaignDetailScreen extends StatefulWidget {
  final String campaignId;

  const CampaignDetailScreen({
    super.key,
    required this.campaignId,
  });

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late TabController _tabController;
  
  Campaign? _campaign;
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCampaign();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCampaign() async {
    setState(() => _isLoading = true);

    try {
      final campaign = await _firestoreService.getCampaign(widget.campaignId);
      final stats = await _firestoreService.getCampaignStats(widget.campaignId);

      setState(() {
        _campaign = campaign;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading campaign: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _shareCampaign() {
    if (_campaign != null) {
      Share.share(
        'Help support: ${_campaign!.title}\n\n'
        '${_campaign!.story.substring(0, _campaign!.story.length > 100 ? 100 : _campaign!.story.length)}...\n\n'
        'Donate on Wamo: ${AppConstants.appUrl}/campaigns/${widget.campaignId}',
        subject: _campaign!.title,
      );
    }
  }

  void _donate() {
    Navigator.pushNamed(
      context,
      AppRoutes.donate,
      arguments: {'campaignId': widget.campaignId},
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;
    final isOwner = currentUser?.id == _campaign?.ownerId;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_campaign == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Campaign not found'),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _campaign!.proofUrls.isNotEmpty
                  ? Image.network(
                      _campaign!.proofUrls.first,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppTheme.primaryColor,
                      child: const Icon(
                        Icons.campaign,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareCampaign,
              ),
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // TODO: Navigate to edit
                  },
                ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status chip
                      _buildStatusChip(_campaign!.status),

                      const SizedBox(height: AppTheme.spacingM),

                      // Title
                      Text(
                        _campaign!.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: AppTheme.spacingS),

                      // Cause
                      Row(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: AppTheme.spacingXS),
                          Text(
                            _campaign!.cause,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppTheme.spacingL),

                      // Progress Card
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingM),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'GH₵ ${_campaign!.raisedAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    Text(
                                      'raised of GH₵ ${_campaign!.targetAmount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${_campaign!.progressPercentage.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppTheme.spacingM),

                            LinearProgressIndicator(
                              value: _campaign!.progressPercentage / 100,
                              minHeight: 8,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation(
                                _campaign!.isGoalReached
                                    ? AppTheme.successColor
                                    : AppTheme.primaryColor,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),

                            const SizedBox(height: AppTheme.spacingM),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatItem(
                                  '${_stats?['total_donations'] ?? 0}',
                                  'Donations',
                                ),
                                _buildStatItem(
                                  '${_stats?['unique_donors'] ?? 0}',
                                  'Supporters',
                                ),
                                _buildStatItem(
                                  '${_stats?['days_remaining'] ?? 0}',
                                  'Days Left',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.spacingL),

                // Tabs
                TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppTheme.primaryColor,
                  tabs: const [
                    Tab(text: 'Story'),
                    Tab(text: 'Donations'),
                    Tab(text: 'Updates'),
                  ],
                ),
              ],
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStoryTab(),
                _buildDonationsTab(),
                _buildUpdatesTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _campaign!.status == 'active'
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: ElevatedButton(
                  onPressed: _donate,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Donate Now',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case 'active':
        color = AppTheme.successColor;
        label = 'Active';
        icon = Icons.check_circle;
        break;
      case 'pending':
        color = Colors.orange;
        label = 'Pending Review';
        icon = Icons.pending;
        break;
      case 'completed':
        color = Colors.blue;
        label = 'Completed';
        icon = Icons.done_all;
        break;
      case 'rejected':
        color = AppTheme.errorColor;
        label = 'Rejected';
        icon = Icons.cancel;
        break;
      case 'draft':
        color = Colors.grey;
        label = 'Draft';
        icon = Icons.edit;
        break;
      default:
        color = Colors.grey;
        label = status;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppTheme.spacingXS),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStoryTab() {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      children: [
        const Text(
          'Campaign Story',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Text(
          _campaign!.story,
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
          ),
        ),
        
        if (_campaign!.proofUrls.length > 1) ...[
          const SizedBox(height: AppTheme.spacingXL),
          const Text(
            'Proof Documents',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppTheme.spacingM,
              mainAxisSpacing: AppTheme.spacingM,
            ),
            itemCount: _campaign!.proofUrls.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                child: Image.network(
                  _campaign!.proofUrls[index],
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildDonationsTab() {
    return StreamBuilder<List<Donation>>(
      stream: _firestoreService.getCampaignDonationsStream(widget.campaignId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'No donations yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                const Text(
                  'Be the first to support this campaign!',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final donation = snapshot.data![index];
            return Card(
              margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Icon(
                    donation.isAnonymous ? Icons.person_off : Icons.favorite,
                    color: AppTheme.primaryColor,
                  ),
                ),
                title: Text(
                  donation.isAnonymous 
                      ? 'Anonymous' 
                      : donation.donorName ?? 'Anonymous',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: donation.message != null
                    ? Text(donation.message!)
                    : null,
                trailing: Text(
                  'GH₵ ${donation.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUpdatesTab() {
    return StreamBuilder<List<CampaignUpdate>>(
      stream: _firestoreService.getCampaignUpdatesStream(widget.campaignId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.article_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'No updates yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final update = snapshot.data![index];
            return Card(
              margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.campaign,
                          size: 16,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        Text(
                          'Campaign Update',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(update.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    Text(
                      update.text,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
