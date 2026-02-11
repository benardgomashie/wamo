import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../app/theme.dart';
import '../../app/routes.dart';
import '../../core/utils/responsive_utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, screenWidth) {
        final isDesktop = deviceType == DeviceType.desktop;
        
        return Scaffold(
          appBar: _buildAppBar(context, isDesktop),
          body: SafeArea(
            child: SingleChildScrollView(
              child: MaxWidthContainer(
                maxWidth: Breakpoints.maxContentWidth,
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 48 : 16,
                  vertical: isDesktop ? 32 : 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero Section - Two column on desktop
                    if (isDesktop)
                      _buildDesktopHero(context)
                    else
                      _buildMobileHero(context),
                    
                    SizedBox(height: isDesktop ? 80 : 32),
                    
                    // How It Works Section - Horizontal on desktop
                    _buildHowItWorksSection(context, isDesktop),
                    
                    SizedBox(height: isDesktop ? 80 : 32),
                    
                    // Features Section - Grid on desktop
                    _buildFeaturesSection(context, isDesktop),
                    
                    SizedBox(height: isDesktop ? 80 : 32),
                    
                    // CTA Section
                    _buildCTASection(context, isDesktop),
                    
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDesktop) {
    if (isDesktop) {
      return AppBar(
        toolbarHeight: 74,
        centerTitle: false,
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.favorite,
                  color: AppTheme.secondaryColor,
                  size: 30,
                ),
                const SizedBox(width: 10),
                const Text(
                  'wamo',
                  style: TextStyle(
                    fontSize: 40 / 1.6,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.browseCampaigns),
                  child: const Text('Explore Campaigns'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.phoneAuth),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Start a Fundraiser'),
                ),
              ],
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.phoneAuth),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textPrimaryColor,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Log In'),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, size: 20),
                ],
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppTheme.dividerColor,
          ),
        ),
        automaticallyImplyLeading: false,
      );
    }
    
    return AppBar(
      title: const Text(AppConstants.appName),
    );
  }

  Widget _buildDesktopHero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // Left side - Text content
          Expanded(
            flex: 55,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Give. Help. Reach.',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppConstants.appMeaning,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Crowdfunding built for Africa. Mobile Money payments, verified campaigns, and transparent giving.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.95),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    _buildHeroButton(
                      context,
                      'Start a Fundraiser',
                      isPrimary: true,
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.phoneAuth),
                    ),
                    _buildHeroButton(
                      context,
                      'Explore Campaigns',
                      isPrimary: false,
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.browseCampaigns),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
          // Right side - Illustration
          Expanded(
            flex: 45,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'ChatGPT Image Feb 11, 2026, 05_30_39 AM.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.volunteer_activism,
                        size: 120,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            AppConstants.appTagline,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppConstants.appMeaning,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.phoneAuth),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Start a Fundraiser'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroButton(
    BuildContext context,
    String label, {
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    if (isPrimary) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      );
    }
    
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildHowItWorksSection(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'How It Works',
          style: TextStyle(
            fontSize: isDesktop ? 32 : 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isDesktop ? 48 : 16),
        if (isDesktop)
          // Horizontal layout for desktop
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildHowItWorksCard('1', 'Create Campaign', 'Share your story and set your goal in under 5 minutes', Icons.campaign)),
              const SizedBox(width: 24),
              Expanded(child: _buildHowItWorksCard('2', 'Share with Network', 'Share via WhatsApp, SMS, and social media', Icons.share)),
              const SizedBox(width: 24),
              Expanded(child: _buildHowItWorksCard('3', 'Receive Donations', 'Accept Mobile Money and card payments instantly', Icons.payment)),
              const SizedBox(width: 24),
              Expanded(child: _buildHowItWorksCard('4', 'Get Your Funds', 'Receive funds directly to your Mobile Money account', Icons.account_balance_wallet)),
            ],
          )
        else
          // Vertical layout for mobile
          Column(
            children: [
              _buildHowItWorksStep(number: '1', title: 'Create Campaign', description: 'Share your story and set your goal in under 5 minutes', icon: Icons.campaign),
              _buildHowItWorksStep(number: '2', title: 'Share with Network', description: 'Share via WhatsApp, SMS, and social media', icon: Icons.share),
              _buildHowItWorksStep(number: '3', title: 'Receive Donations', description: 'Accept Mobile Money and card payments instantly', icon: Icons.payment),
              _buildHowItWorksStep(number: '4', title: 'Get Your Funds', description: 'Receive funds directly to your Mobile Money account', icon: Icons.account_balance_wallet),
            ],
          ),
      ],
    );
  }

  Widget _buildHowItWorksCard(String number, String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, bool isDesktop) {
    final features = [
      {'icon': Icons.verified_user, 'title': 'Trusted & Verified', 'description': 'All campaigns are manually verified'},
      {'icon': Icons.phone_android, 'title': 'Mobile Money', 'description': 'Pay the way Africans actually pay'},
      {'icon': Icons.speed, 'title': 'Fast & Simple', 'description': 'Create campaigns in minutes, donate in seconds'},
      {'icon': Icons.visibility, 'title': 'Transparent', 'description': 'Track every donation and see exactly where money goes'},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Why Wamo?',
          style: TextStyle(
            fontSize: isDesktop ? 32 : 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isDesktop ? 48 : 16),
        if (isDesktop)
          // 2x2 Grid for desktop
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: features.map((f) => SizedBox(
              width: 280,
              child: _buildFeatureCard(
                icon: f['icon'] as IconData,
                title: f['title'] as String,
                description: f['description'] as String,
              ),
            )).toList(),
          )
        else
          Column(
            children: features.map((f) => _buildFeature(
              icon: f['icon'] as IconData,
              title: f['title'] as String,
              description: f['description'] as String,
            )).toList(),
          ),
      ],
    );
  }

  Widget _buildFeatureCard({required IconData icon, required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondaryColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection(BuildContext context, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 48 : 24),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        children: [
          Text(
            'Ready to make a difference?',
            style: TextStyle(
              fontSize: isDesktop ? 28 : 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Join thousands of people making an impact across Africa',
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.browseCampaigns),
                child: const Text('Explore Campaigns'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.phoneAuth),
                child: const Text('Start a Fundraiser'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Mobile-only step widget (existing style)
  Widget _buildHowItWorksStep({
    required String number,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Mobile-only feature widget (existing style)
  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
