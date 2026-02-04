# Wamo Web Compatibility Guide

## Overview
Wamo is primarily a mobile-first crowdfunding platform optimized for African markets. Web support is currently **in development** with the following status:

## Current Web Support Status

### ✅ Fully Supported Features
- **Email/Password Authentication** - Web users can sign up and sign in with email/password
- **Campaign Browsing** - View all campaigns, search, filter by category
- **Campaign Details** - View full campaign information, images, and updates
- **User Profiles** - Create and edit user profiles
- **In-App Notifications** - View notifications in the app (notification center)
- **Campaign Creation** - Create new campaigns (for campaign creators)

### ⚠️ Partially Supported Features
- **Notifications** - In-app notification center works, but no push notifications on web
  - Mobile: FCM push notifications + in-app center
  - Web: In-app notification center only

### ❌ Not Yet Supported on Web
- **Phone OTP Authentication** - Web uses email/password instead
  - Mobile: Primary auth method is phone OTP
  - Web: Email/password authentication

- **Donation Processing** - Payment integration pending
  - Mobile: Paystack integration (Mobile Money + Cards)
  - Web: Coming soon (will use Paystack inline payment or alternative)
  
- **Image Uploads** - File picker compatibility needs testing
  - Status: May work but untested

## Technical Implementation Details

### Platform Detection
We use a `PlatformUtils` class to detect the current platform:

```dart
import 'package:wamo/core/utils/platform_utils.dart';

if (PlatformUtils.isWeb) {
  // Web-specific code
} else if (PlatformUtils.isMobile) {
  // Mobile-specific code  
}
```

### Authentication Flow
- **Mobile**: Splash → Phone OTP → Dashboard
- **Web**: Splash → Email Auth → Dashboard

### Firebase Configuration
- All Firebase packages support web (Auth, Firestore, Storage, Analytics)
- FCM (Firebase Cloud Messaging) is conditionally initialized - skipped on web

### Known Issues

#### flutter_paystack Compatibility
The `flutter_paystack` package (v1.0.7) has deprecated TextTheme properties that cause compilation warnings on newer Flutter versions:
- `headline1` → should be `headlineLarge`
- `headline6` → should be `titleLarge`
- `subtitle1` → should be `bodyLarge`

**Current Status**: Package included for mobile, causes deprecation warnings but doesn't prevent mobile builds.  
**Web Impact**: Cannot compile for web until this is resolved.

**Potential Solutions**:
1. Wait for official flutter_paystack update
2. Use forked version with fixes: `flutter_paystack_plus`  
3. Implement alternative payment solution for web (Paystack Inline JS)
4. Use dependency override to patch the package locally

## Running Wamo

### Mobile (Android/iOS)
```bash
# Android
flutter run -d android

# iOS  
flutter run -d ios
```

### Web (When payment issue is resolved)
```bash
flutter run -d chrome
```

## Development Roadmap

### Phase 1: Basic Web Support (Current)
- [x] Platform detection utility
- [x] Email authentication for web
- [x] Conditional FCM initialization  
- [x] Platform-aware splash screen routing
- [ ] Fix flutter_paystack or implement alternative

### Phase 2: Feature Parity
- [ ] Web-compatible payment processing
- [ ] Test image uploads on web
- [ ] Progressive Web App (PWA) configuration
- [ ] Web-optimized UI components

### Phase 3: Web Optimizations
- [ ] Responsive design improvements
- [ ] Web-specific analytics
- [ ] SEO optimization
- [ ] Performance optimization for web

## For Developers

### Adding New Features
When adding features, always consider platform differences:

```dart
// Good: Platform-aware implementation
if (PlatformUtils.isMobile) {
  await NotificationService().requestPermission();
} else {
  // Skip or use alternative for web
  print('Push notifications not available on web');
}

// Bad: Assuming mobile-only APIs
await FirebaseMessaging.instance.getToken(); // Crashes on web
```

### Testing Across Platforms
- Test on mobile emulators/devices first
- Then test on web browsers
- Use platform checks for mobile-only features
- Document platform-specific behavior

## Deployment

### Mobile Deployment
- Android: Google Play Store
- iOS: Apple App Store
- Standard Flutter mobile deployment process

### Web Deployment (Future)
- Firebase Hosting (recommended)
- Netlify, Vercel, or other static hosts
- Requires completing Phase 1 & 2 of web roadmap

## Contact & Support
For questions about web compatibility or to contribute to web support:
- GitHub: [benardgomashie/wamo](https://github.com/benardgomashie/wamo)
- Check issues for web-related tasks

---

**Last Updated**: December 2024  
**Flutter Version**: 3.x+  
**Target Platforms**: Android, iOS, Web (in progress)
