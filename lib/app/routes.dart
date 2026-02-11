import 'package:flutter/material.dart';
import '../features/splash/splash_screen.dart';
import '../features/home/home_screen.dart';
import '../features/auth/phone_auth_screen.dart';
import '../features/auth/otp_verification_screen.dart';
import '../features/auth/create_profile_screen.dart';
import '../features/campaigns/create_campaign_screen.dart';
import '../features/campaigns/campaign_detail_screen.dart';
import '../features/campaigns/browse_campaigns_screen.dart';
import '../features/donations/donate_screen.dart';
import '../features/dashboard/dashboard_screen.dart';

class AppRoutes {
  // Route Names
  static const String splash = '/';
  static const String home = '/home';
  static const String phoneAuth = '/auth/phone';
  static const String otpVerification = '/auth/otp';
  static const String createProfile = '/auth/create-profile';
  static const String browseCampaigns = '/campaigns/browse';
  static const String createCampaign = '/campaigns/create';
  static const String campaignDetail = '/campaigns/detail';
  static const String donate = '/donate';
  static const String dashboard = '/dashboard';
  
  // Route Generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
        
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
        
      case phoneAuth:
        return MaterialPageRoute(builder: (_) => const PhoneAuthScreen());
        
      case otpVerification:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => OTPVerificationScreen(
            phoneNumber: args?['phoneNumber'] ?? '',
            verificationId: args?['verificationId'] ?? '',
          ),
        );
        
      case createProfile:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CreateProfileScreen(
            uid: args?['uid'] ?? '',
            phoneNumber: args?['phoneNumber'] ?? '',
          ),
        );
        
      case browseCampaigns:
        return MaterialPageRoute(builder: (_) => const BrowseCampaignsScreen());
        
      case createCampaign:
        return MaterialPageRoute(builder: (_) => const CreateCampaignScreen());
        
      case campaignDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CampaignDetailScreen(
            campaignId: args?['campaignId'] ?? '',
          ),
        );
        
      case donate:
        final args = settings.arguments as Map<String, dynamic>?;
        final campaign = args?['campaign'];
        if (campaign == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Campaign not found')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => DonateScreen(campaign: campaign),
        );
        
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
        
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
