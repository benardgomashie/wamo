import 'package:flutter/foundation.dart';

/// Utility class for platform-specific checks
class PlatformUtils {
  /// Check if running on web
  static bool get isWeb => kIsWeb;
  
  /// Check if running on mobile (iOS or Android)
  static bool get isMobile => !kIsWeb;
  
  /// Check if running on iOS
  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;
  
  /// Check if running on Android
  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;
  
  /// Check if running on desktop (Windows, macOS, Linux)
  static bool get isDesktop => 
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;
}
