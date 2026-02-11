import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../app/routes.dart';
import '../../core/models/campaign.dart';
import '../../core/services/firestore_service.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/responsive_utils.dart';
import '../../widgets/wamo_empty_state.dart';

class BrowseCampaignsScreen extends StatefulWidget {
  const BrowseCampaignsScreen({super.key});

  @override
  State<BrowseCampaignsScreen> createState() => _BrowseCampaignsScreenState();
}

class _BrowseCampaignsScreenState extends State<BrowseCampaignsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  static const String _logScope = 'BrowseCampaignsScreen';
  String _selectedCategory = 'all';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Campaigns'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Create Campaign'),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.phoneAuth);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search campaigns...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Category filter
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              children: [
                _buildCategoryChip('all', 'All'),
                _buildCategoryChip('medical', 'Medical'),
                _buildCategoryChip('education', 'Education'),
                _buildCategoryChip('emergency', 'Emergency'),
                _buildCategoryChip('community', 'Community'),
                _buildCategoryChip('other', 'Other'),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Campaigns list
          Expanded(
            child: StreamBuilder<List<Campaign>>(
              stream: _selectedCategory == 'all'
                  ? _firestoreService.getCampaignsStream(status: 'active')
                  : _firestoreService.getCampaignsStream(
                      status: 'active', cause: _selectedCategory),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  AppLogger.error(
                    _logScope,
                    'Campaign stream error.',
                    snapshot.error,
                    snapshot.stackTrace,
                  );
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const WamoEmptyState(
                    icon: Icons.campaign,
                    title: 'No campaigns found',
                    message: 'Check back later for new campaigns',
                  );
                }

                var campaigns = snapshot.data!;

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  campaigns = campaigns.where((campaign) {
                    return campaign.title
                            .toLowerCase()
                            .contains(_searchQuery) ||
                        campaign.story.toLowerCase().contains(_searchQuery);
                  }).toList();
                }

                if (campaigns.isEmpty) {
                  return const WamoEmptyState(
                    icon: Icons.search_off,
                    title: 'No campaigns match your search',
                    message: 'Try a different search term',
                  );
                }

                return ResponsiveBuilder(
                  builder: (context, deviceType, screenWidth) {
                    if (deviceType == DeviceType.mobile) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(AppTheme.spacingM),
                        itemCount: campaigns.length,
                        itemBuilder: (context, index) {
                          return _buildCampaignCard(campaigns[index]);
                        },
                      );
                    }
                    // Desktop/Tablet: Use grid layout
                    final crossAxisCount =
                        deviceType == DeviceType.desktop ? 3 : 2;
                    return GridView.builder(
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: AppTheme.spacingM,
                        mainAxisSpacing: AppTheme.spacingM,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: campaigns.length,
                      itemBuilder: (context, index) {
                        return _buildCampaignCardGrid(campaigns[index]);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String value, String label) {
    final isSelected = _selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.spacingS),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = value;
          });
        },
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.grey.shade200,
        selectedColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected
              ? Colors.white
              : Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildCampaignCard(Campaign campaign) {
    final progress = campaign.targetAmount > 0
        ? (campaign.raisedAmount / campaign.targetAmount * 100).clamp(0, 100)
        : 0.0;

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
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campaign image
            if (campaign.proofUrls.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusM),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    campaign.proofUrls.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image_not_supported, size: 48),
                      );
                    },
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    campaign.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppTheme.spacingS),

                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingS,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: Text(
                      campaign.cause.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingM),

                  // Progress bar
                  LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.successColor,
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingS),

                  // Amount info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GH₵${campaign.raisedAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.successColor,
                            ),
                          ),
                          Text(
                            'of GH₵${campaign.targetAmount.toStringAsFixed(0)} goal',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${progress.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spacingS),

                  // Donor count
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${campaign.donationCount} donors',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignCardGrid(Campaign campaign) {
    final progress = campaign.targetAmount > 0
        ? (campaign.raisedAmount / campaign.targetAmount * 100).clamp(0, 100)
        : 0.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.campaignDetail,
              arguments: {'campaignId': campaign.id},
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campaign image - takes more space in grid
              Expanded(
                flex: 3,
                child: campaign.proofUrls.isNotEmpty
                    ? Image.network(
                        campaign.proofUrls.first,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade300,
                            child:
                                const Icon(Icons.image_not_supported, size: 48),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.campaign,
                            size: 48, color: Colors.grey),
                      ),
              ),

              // Content
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          campaign.cause.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Title
                      Text(
                        campaign.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const Spacer(),

                      // Progress bar
                      LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.successColor,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Amount info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'GH₵${campaign.raisedAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.successColor,
                              ),
                            ),
                          ),
                          Text(
                            '${progress.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      Text(
                        'of GH₵${campaign.targetAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
