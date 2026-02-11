import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../utils/app_logger.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/auth/create_profile_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  static const String _logScope = 'AuthWrapper';

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show splash screen while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          AppLogger.info(_logScope, 'Auth state is loading; showing splash.');
          return const SplashScreen();
        }

        // User is signed in
        if (snapshot.hasData && snapshot.data != null) {
          AppLogger.info(
            _logScope,
            'Authenticated user detected. uid=${snapshot.data!.uid}. Checking profile.',
          );
          return FutureBuilder<bool>(
            future: authService.userProfileExists(snapshot.data!.uid),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                AppLogger.info(
                    _logScope, 'Profile check in progress; showing splash.');
                return const SplashScreen();
              }

              // Profile exists, show dashboard
              if (profileSnapshot.data == true) {
                AppLogger.info(
                    _logScope, 'Profile exists; routing to dashboard.');
                return const DashboardScreen();
              }

              // No profile, navigate to create profile
              AppLogger.warn(
                _logScope,
                'Profile not found for uid=${snapshot.data!.uid}; routing to create profile.',
              );
              return CreateProfileScreen(
                uid: snapshot.data!.uid,
                phoneNumber: snapshot.data!.phoneNumber ?? '',
              );
            },
          );
        }

        // User is not signed in, show home screen
        AppLogger.info(_logScope, 'No authenticated user; routing to home.');
        return const HomeScreen();
      },
    );
  }
}
