import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../app/routes.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/firestore_service.dart';
import '../../core/models/campaign.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/web_widgets.dart';
import '../../widgets/wamo_empty_state.dart';
import '../../widgets/wamo_toast.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  static const String _logScope = 'DashboardScreen';
  Map<String, dynamic>? _stats;
  bool _isLoadingStats = true;
  int _selectedNavIndex = 0;
  String? _lastLoadedUserId; // Track which user we loaded stats for

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload stats if user has changed
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;
    
    if (user != null && user.id != _lastLoadedUserId) {
      debugPrint('[DashboardScreen] User changed, reloading stats. newUserId=${user.id}');
      _loadStats();
    }
  }

  Future<void> _loadStats() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.currentUser;

      if (user != null) {
        debugPrint('[DashboardScreen] Loading stats for user: ${user.id}');
        final stats = await _firestoreService.getUserStats(user.id);
        if (mounted) {
          setState(() {
            _stats = stats;
            _isLoadingStats = false;
            _lastLoadedUserId = user.id; // Track which user we loaded
          });
        }
        debugPrint('[DashboardScreen] Stats loaded successfully');
      } else {
        debugPrint('[DashboardScreen] User is null, setting default stats');
        if (mounted) {
          setState(() {
            _stats = {
              'total_campaigns': 0,
              'active_campaigns': 0,
              'total_raised': 0.0,
              'total_donated': 0.0,
              'total_donations': 0,
            };
            _isLoadingStats = false;
            _lastLoadedUserId = null;
          });
        }
      }
    } catch (e, stackTrace) {
      debugPrint('[DashboardScreen] Error loading stats: $e');
      debugPrint('[DashboardScreen] Stack trace: $stackTrace');
      // Set default stats on error
      if (mounted) {
        setState(() {
          _stats = {
            'total_campaigns': 0,
            'active_campaigns': 0,
            'total_raised': 0.0,
            'total_donated': 0.0,
            'total_donations': 0,
          };
          _isLoadingStats = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ResponsiveBuilder(
      builder: (context, deviceType, screenWidth) {
        final isDesktop = deviceType == DeviceType.desktop;

        if (isDesktop) {
          return _buildDesktopLayout(user, userProvider);
        } else {
          return _buildMobileLayout(user, userProvider);
        }
      },
    );
  }

  /// Desktop layout with sidebar
  Widget _buildDesktopLayout(dynamic user, UserProvider userProvider) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(user, userProvider),

          // Main content
          Expanded(
            child: Container(
              color: AppTheme.backgroundColor,
              child: Column(
                children: [
                  // Top bar
                  _buildDesktopTopBar(user),

                  // Content area
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: MaxWidthContainer(
                        maxWidth: 1000,
                        child: _buildSelectedContent(user),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(dynamic user, UserProvider userProvider) {
    return Container(
      width: Breakpoints.sidebarWidth,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          right: BorderSide(color: AppTheme.dividerColor),
        ),
      ),
      child: Column(
        children: [
          // Logo area
          Container(
            padding: const EdgeInsets.all(20),
            child: Image.asset(
              'assets/images/wamo_logo.png',
              height: 35,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'W',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Wamo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                SidebarItem(
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard,
                  label: 'Dashboard',
                  isSelected: _selectedNavIndex == 0,
                  onTap: () => setState(() => _selectedNavIndex = 0),
                ),
                SidebarItem(
                  icon: Icons.campaign_outlined,
                  selectedIcon: Icons.campaign,
                  label: 'My Campaigns',
                  isSelected: _selectedNavIndex == 1,
                  onTap: () => setState(() => _selectedNavIndex = 1),
                ),
                SidebarItem(
                  icon: Icons.update_outlined,
                  selectedIcon: Icons.update,
                  label: 'Updates',
                  isSelected: _selectedNavIndex == 2,
                  onTap: () => setState(() => _selectedNavIndex = 2),
                ),
                SidebarItem(
                  icon: Icons.account_balance_wallet_outlined,
                  selectedIcon: Icons.account_balance_wallet,
                  label: 'Payouts',
                  isSelected: _selectedNavIndex == 3,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.payoutHistory);
                  },
                ),
                SidebarItem(
                  icon: Icons.notifications_outlined,
                  selectedIcon: Icons.notifications,
                  label: 'Notifications',
                  isSelected: _selectedNavIndex == 4,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.notifications);
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // User profile section at bottom
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user.phone,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (value) async {
                      if (value == 'logout') {
                        await userProvider.signOut();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, size: 18),
                            SizedBox(width: 8),
                            Text('Sign Out'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTopBar(dynamic user) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          bottom: BorderSide(color: AppTheme.dividerColor),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Welcome back, ${user.name}!',
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const Spacer(),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.createCampaign),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('New Campaign'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Mobile layout (original design)
  Widget _buildMobileLayout(dynamic user, UserProvider userProvider) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/wamo_logo.png',
              height: 28,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Text('Dashboard');
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await userProvider.signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User greeting
              Text(
                'Welcome, ${user.name}!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: AppTheme.spacingS),

              // Verification status
              if (user.verificationStatus != 'verified')
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verification Pending',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade900,
                              ),
                            ),
                            Text(
                              'Your account is being verified. You can create campaigns once approved.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: AppTheme.spacingL),

              // Statistics cards
              if (_isLoadingStats)
                const Center(child: CircularProgressIndicator())
              else if (_stats != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Campaigns',
                        _stats!['total_campaigns'].toString(),
                        Icons.campaign,
                        AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: _buildStatCard(
                        'Active',
                        _stats!['active_campaigns'].toString(),
                        Icons.trending_up,
                        AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingM),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Raised',
                        'GH₵ ${_stats!['total_raised'].toStringAsFixed(2)}',
                        Icons.account_balance_wallet,
                        AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: _buildStatCard(
                        'Donated',
                        'GH₵ ${_stats!['total_donated'].toStringAsFixed(2)}',
                        Icons.favorite,
                        AppTheme.errorColor,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: AppTheme.spacingXL),

              // My Campaigns section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Campaigns',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: View all campaigns
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingM),

              // Campaigns list
              StreamBuilder<List<Campaign>>(
                stream: _firestoreService.getCampaignsStream(
                  creatorId: user.id,
                  limit: 5,
                ),
                builder: (context, snapshot) {
                  // Check for errors (e.g., missing Firestore indexes)
                  if (snapshot.hasError) {
                    AppLogger.error(
                      _logScope,
                      'Campaign stream error (mobile cards).',
                      snapshot.error,
                      snapshot.stackTrace,
                    );
                    return _buildEmptyCampaigns();
                  }

                  // Show loading only on initial wait, not when active
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyCampaigns();
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final campaign = snapshot.data![index];
                      return _buildCampaignCard(campaign);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.createCampaign);
        },
        icon: const Icon(Icons.add),
        label: const Text('New Campaign'),
      ),
    );
  }

  /// Switch content based on selected sidebar item
  Widget _buildSelectedContent(dynamic user) {
    switch (_selectedNavIndex) {
      case 0:
        return _buildDashboardContent(user);
      case 1:
        return _buildMyCampaignsContent(user);
      case 2:
        return _buildUpdatesContent(user);
      default:
        return _buildDashboardContent(user);
    }
  }

  /// My Campaigns tab content
  Widget _buildMyCampaignsContent(dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Campaigns',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        
        StreamBuilder<List<Campaign>>(
          stream: _firestoreService.getCampaignsStream(
            creatorId: user.id,
            limit: 50,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              debugPrint('❌ My campaigns stream error: ${snapshot.error}');
              return _buildEmptyCampaigns();
            }
            
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyCampaigns();
            }
            
            return _buildDesktopCampaignsTable(snapshot.data!);
          },
        ),
      ],
    );
  }

  /// Updates tab content (placeholder for now)
  Widget _buildUpdatesContent(dynamic user) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.update_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Campaign Updates',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Post updates feature coming soon',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  /// Dashboard content used by both desktop and (can be reused by) mobile layouts
  Widget _buildDashboardContent(dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Verification status
        if (user.verificationStatus != 'verified')
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verification Pending',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade900,
                        ),
                      ),
                      Text(
                        'Your account is being verified. You can create campaigns once approved.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Statistics cards - use grid layout for desktop
        if (_isLoadingStats)
          const Center(child: CircularProgressIndicator())
        else if (_stats != null) ...[
          _buildDesktopStatsGrid(),
        ],

        const SizedBox(height: 32),

        // My Campaigns section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Campaigns',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: View all campaigns
              },
              child: const Text('View All'),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Campaigns list/table
        StreamBuilder<List<Campaign>>(
          stream: _firestoreService.getCampaignsStream(
            creatorId: user.id,
            limit: 10,
          ),
          builder: (context, snapshot) {
            // Check for errors (e.g., missing Firestore indexes)
            if (snapshot.hasError) {
              AppLogger.error(
                _logScope,
                'Campaign stream error (desktop table).',
                snapshot.error,
                snapshot.stackTrace,
              );
              return _buildEmptyCampaigns();
            }

            // Show loading only on initial wait, not when active
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyCampaigns();
            }

            return _buildDesktopCampaignsTable(snapshot.data!);
          },
        ),
      ],
    );
  }

  Widget _buildDesktopStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildDesktopStatCard(
            'Total Campaigns',
            _stats!['total_campaigns'].toString(),
            Icons.campaign,
            AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDesktopStatCard(
            'Active',
            _stats!['active_campaigns'].toString(),
            Icons.trending_up,
            AppTheme.successColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDesktopStatCard(
            'Total Raised',
            'GH₵ ${_stats!['total_raised'].toStringAsFixed(2)}',
            Icons.account_balance_wallet,
            AppTheme.secondaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDesktopStatCard(
            'Total Donated',
            'GH₵ ${_stats!['total_donated'].toStringAsFixed(2)}',
            Icons.favorite,
            AppTheme.errorColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopCampaignsTable(List<Campaign> campaigns) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Expanded(
                    flex: 3,
                    child: Text('Campaign',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13))),
                const Expanded(
                    flex: 1,
                    child: Text('Status',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13))),
                const Expanded(
                    flex: 2,
                    child: Text('Progress',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13))),
                const SizedBox(
                    width: 80,
                    child: Text('Actions',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13))),
              ],
            ),
          ),
          const Divider(height: 1),
          // Table rows
          ...campaigns.map((campaign) => _buildCampaignTableRow(campaign)),
        ],
      ),
    );
  }

  Widget _buildCampaignTableRow(Campaign campaign) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.campaignDetail,
            arguments: {'campaignId': campaign.id},
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            border: Border(
                bottom:
                    BorderSide(color: AppTheme.dividerColor.withOpacity(0.5))),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  campaign.title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 1,
                child: _buildStatusChip(campaign.status),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: campaign.progressPercentage / 100,
                      backgroundColor: Colors.grey.shade200,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'GH₵ ${campaign.raisedAmount.toStringAsFixed(0)} / ${campaign.targetAmount.toStringAsFixed(0)}',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (campaign.status == 'draft') ...[
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: 'Edit Draft',
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.createCampaign,
                            arguments: {'campaignId': campaign.id},
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        tooltip: 'Delete Draft',
                        onPressed: () => _confirmDeleteDraft(campaign.id),
                      ),
                    ] else
                      IconButton(
                        icon: const Icon(Icons.visibility_outlined, size: 20),
                        tooltip: 'View',
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.campaignDetail,
                            arguments: {'campaignId': campaign.id},
                          );
                        },
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

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCampaigns() {
    return WamoEmptyState(
      icon: Icons.campaign_outlined,
      title: 'No campaigns yet',
      message: 'Create your first campaign to start raising funds',
      actionLabel: 'Start a Campaign',
      onAction: () {
        Navigator.pushNamed(context, AppRoutes.createCampaign);
      },
    );
  }

  Widget _buildCampaignCard(Campaign campaign) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.campaignDetail,
            arguments: {'campaignId': campaign.id},
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      campaign.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(campaign.status),
                ],
              ),

              const SizedBox(height: AppTheme.spacingS),

              // Progress bar
              LinearProgressIndicator(
                value: campaign.progressPercentage / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(
                  campaign.isGoalReached
                      ? AppTheme.successColor
                      : AppTheme.primaryColor,
                ),
              ),

              const SizedBox(height: AppTheme.spacingS),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'GH₵ ${campaign.raisedAmount.toStringAsFixed(2)} raised',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Text(
                    'Goal: GH₵ ${campaign.targetAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              
              // Show edit/delete actions for drafts
              if (campaign.status == 'draft') ...[
                const SizedBox(height: AppTheme.spacingS),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.createCampaign,
                          arguments: {'campaignId': campaign.id},
                        );
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    TextButton.icon(
                      onPressed: () => _confirmDeleteDraft(campaign.id),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteDraft(String campaignId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Draft?'),
        content: const Text(
          'Are you sure you want to delete this draft campaign? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firestoreService.deleteCampaign(campaignId);
        if (mounted) {
          WamoToast.success(context, 'Draft deleted successfully');
        }
      } catch (e) {
        if (mounted) {
          WamoToast.error(context, 'Failed to delete draft: $e');
        }
      }
    }
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'active':
        color = AppTheme.successColor;
        label = 'Active';
        break;
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'draft':
        color = Colors.grey.shade600;
        label = 'Draft';
        break;
      case 'completed':
        color = Colors.blue;
        label = 'Completed';
        break;
      case 'rejected':
        color = AppTheme.errorColor;
        label = 'Rejected';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
