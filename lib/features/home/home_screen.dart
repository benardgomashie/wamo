import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../app/theme.dart';
import '../../app/routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Section
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.accentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
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
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      AppConstants.appMeaning,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.phoneAuth);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                      ),
                      child: const Text('Start a Fundraiser'),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingXL),
              
              // How It Works Section
              const Text(
                'How It Works',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              
              _buildHowItWorksStep(
                number: '1',
                title: 'Create Campaign',
                description: 'Share your story and set your goal in under 5 minutes',
                icon: Icons.campaign,
              ),
              
              _buildHowItWorksStep(
                number: '2',
                title: 'Share with Network',
                description: 'Share via WhatsApp, SMS, and social media',
                icon: Icons.share,
              ),
              
              _buildHowItWorksStep(
                number: '3',
                title: 'Receive Donations',
                description: 'Accept Mobile Money and card payments instantly',
                icon: Icons.payment,
              ),
              
              _buildHowItWorksStep(
                number: '4',
                title: 'Get Your Funds',
                description: 'Receive funds directly to your Mobile Money account',
                icon: Icons.account_balance_wallet,
              ),
              
              const SizedBox(height: AppTheme.spacingXL),
              
              // Features Section
              const Text(
                'Why Wamo?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              
              _buildFeature(
                icon: Icons.verified_user,
                title: 'Trusted & Verified',
                description: 'All campaigns are manually verified',
              ),
              
              _buildFeature(
                icon: Icons.phone_android,
                title: 'Mobile Money',
                description: 'Pay the way Africans actually pay',
              ),
              
              _buildFeature(
                icon: Icons.speed,
                title: 'Fast & Simple',
                description: 'Create campaigns in minutes, donate in seconds',
              ),
              
              _buildFeature(
                icon: Icons.visibility,
                title: 'Transparent',
                description: 'Track every donation and see exactly where money goes',
              ),
              
              const SizedBox(height: AppTheme.spacingXL),
              
              // CTA Button
              OutlinedButton(
                onPressed: () {
                  // TODO: Navigate to explore campaigns
                },
                child: const Text('Explore Campaigns'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
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
