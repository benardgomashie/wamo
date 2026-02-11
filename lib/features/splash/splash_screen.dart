import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../app/constants.dart';
import '../../app/theme.dart';
import '../../app/routes.dart';
import '../../core/utils/app_logger.dart';
import '../auth/phone_auth_screen.dart';
import '../dashboard/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const String _logScope = 'SplashScreen';

  @override
  void initState() {
    super.initState();
    AppLogger.info(_logScope, 'Splash initialized.');
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    try {
      // Wait for 2 seconds
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Check authentication status
      final user = FirebaseAuth.instance.currentUser;
      AppLogger.info(
          _logScope, 'Auth check complete. userPresent=${user != null}');

      if (user != null) {
        // User is logged in, check if profile exists
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          // User has profile, go to dashboard
          if (!mounted) return;
          AppLogger.info(_logScope,
              'Profile exists for uid=${user.uid}; navigating to dashboard.');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        } else {
          // Logged in but no profile, shouldn't happen but handle it
          if (!mounted) return;
          AppLogger.warn(_logScope,
              'No profile for uid=${user.uid}; navigating to ${AppRoutes.home}.');
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } else {
        // Not logged in, go to phone auth screen (all platforms)
        if (!mounted) return;
        AppLogger.info(_logScope, 'No user session; navigating to phone auth.');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const PhoneAuthScreen(),
          ),
        );
      }
    } catch (e, stackTrace) {
      if (!mounted) return;
      AppLogger.error(
          _logScope, 'Failed during splash navigation.', e, stackTrace);
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Wamo Logo
            Image.asset(
              'assets/images/wamo_logo.png',
              width: 200,
              height: 80,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                  ),
                  child: const Center(
                    child: Text(
                      'W',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: AppTheme.spacingL),

            // App Name
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: AppTheme.spacingS),

            // Tagline
            const Text(
              AppConstants.appTagline,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: AppTheme.spacingS),

            // Meaning
            Text(
              AppConstants.appMeaning,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.white.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: AppTheme.spacingXXL),

            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
