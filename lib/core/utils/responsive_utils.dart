import 'package:flutter/material.dart';

/// Responsive breakpoints for Wamo web
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1200;
  static const double widescreen = 1440;
  
  /// Maximum content width for centered layouts
  static const double maxContentWidth = 1200;
  
  /// Sidebar width for dashboard
  static const double sidebarWidth = 260;
  
  /// Campaign detail split ratio
  static const double campaignContentRatio = 0.65;
  static const double donationCardRatio = 0.35;
}

/// Device type enumeration
enum DeviceType { mobile, tablet, desktop }

/// Responsive layout builder with breakpoint awareness
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType, double screenWidth) builder;
  
  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });
  
  static DeviceType getDeviceType(double width) {
    if (width < Breakpoints.mobile) {
      return DeviceType.mobile;
    } else if (width < Breakpoints.tablet) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }
  
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < Breakpoints.mobile;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= Breakpoints.mobile && width < Breakpoints.tablet;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= Breakpoints.tablet;
  }
  
  static bool isMobileOrTablet(BuildContext context) {
    return MediaQuery.of(context).size.width < Breakpoints.tablet;
  }
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final deviceType = getDeviceType(screenWidth);
        return builder(context, deviceType, screenWidth);
      },
    );
  }
}

/// Widget that shows different layouts based on screen size
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;
  
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });
  
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, _) {
        switch (deviceType) {
          case DeviceType.mobile:
            return mobile;
          case DeviceType.tablet:
            return tablet ?? mobile;
          case DeviceType.desktop:
            return desktop;
        }
      },
    );
  }
}

/// Constrains content to max width with centered alignment
class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment alignment;
  
  const MaxWidthContainer({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.maxContentWidth,
    this.padding = EdgeInsets.zero,
    this.alignment = CrossAxisAlignment.center,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Extension methods for responsive sizing
extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  
  bool get isMobile => screenWidth < Breakpoints.mobile;
  bool get isTablet => screenWidth >= Breakpoints.mobile && screenWidth < Breakpoints.tablet;
  bool get isDesktop => screenWidth >= Breakpoints.tablet;
  bool get isWidescreen => screenWidth >= Breakpoints.widescreen;
  
  DeviceType get deviceType => ResponsiveBuilder.getDeviceType(screenWidth);
  
  /// Returns responsive value based on device type
  T responsive<T>({
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    if (isMobile) return mobile;
    if (isTablet) return tablet ?? mobile;
    return desktop;
  }
  
  /// Returns responsive spacing
  double get responsiveSpacing {
    if (isMobile) return 16;
    if (isTablet) return 24;
    return 32;
  }
  
  /// Returns responsive horizontal padding
  EdgeInsets get responsiveHorizontalPadding {
    if (isMobile) return const EdgeInsets.symmetric(horizontal: 16);
    if (isTablet) return const EdgeInsets.symmetric(horizontal: 32);
    return const EdgeInsets.symmetric(horizontal: 48);
  }
}

/// Utility class for responsive grid layouts
class ResponsiveGrid {
  static int getColumnCount(double width) {
    if (width < Breakpoints.mobile) return 1;
    if (width < Breakpoints.tablet) return 2;
    if (width < Breakpoints.desktop) return 3;
    return 4;
  }
  
  static double getCrossAxisSpacing(double width) {
    if (width < Breakpoints.mobile) return 12;
    if (width < Breakpoints.tablet) return 16;
    return 24;
  }
  
  static double getMainAxisSpacing(double width) {
    if (width < Breakpoints.mobile) return 12;
    if (width < Breakpoints.tablet) return 16;
    return 24;
  }
}
