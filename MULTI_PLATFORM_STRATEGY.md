# Multi-Platform Architecture for Wamo
**Strategic Decision:** Cross-platform compatibility to reach more people  
**Date:** February 5, 2026

---

## Platform Strategy

### Target Platforms (Priority Order)
1. **Android** - Primary (Ghana market leader)
2. **iOS** - Secondary (diaspora donors)
3. **Web (Desktop)** - Diaspora donors, campaign sharing
4. **Web (Mobile)** - Progressive Web App fallback
5. **Desktop (Windows/Mac)** - Future consideration

---

## Payment Architecture (Platform-Specific)

### Mobile (iOS/Android) - Full SDK
```dart
// Use flutter_paystack_plus for native experience
import 'package:flutter_paystack_plus/flutter_paystack_plus.dart';

class MobilePaymentService {
  Future<bool> processDonation({
    required double amount,
    required String email,
  }) async {
    final charge = Charge()
      ..amount = (amount * 100).toInt() // Convert to kobo/pesewas
      ..email = email
      ..reference = _generateReference();
    
    final response = await PaystackPayment().checkout(
      context,
      charge: charge,
      method: CheckoutMethod.selectable, // Card + Mobile Money
    );
    
    return response.status;
  }
}
```

### Web - Payment Links (Redirect Flow)
```dart
// Use Paystack Payment Links API for web
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class WebPaymentService {
  Future<bool> processDonation({
    required double amount,
    required String email,
    required String campaignId,
  }) async {
    // 1. Create payment link via Paystack API
    final response = await http.post(
      Uri.parse('https://api.paystack.co/transaction/initialize'),
      headers: {
        'Authorization': 'Bearer ${AppConstants.paystackSecretKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount': (amount * 100).toInt(),
        'email': email,
        'reference': _generateReference(),
        'callback_url': '${AppConstants.appUrl}/payment/verify',
        'metadata': {
          'campaign_id': campaignId,
          'platform': 'web',
        },
      }),
    );
    
    final data = jsonDecode(response.body);
    final authorizationUrl = data['data']['authorization_url'];
    
    // 2. Redirect to Paystack payment page
    await launchUrl(Uri.parse(authorizationUrl));
    
    // 3. User completes payment → redirected back to callback_url
    // 4. Verify transaction via webhook or polling
    return true;
  }
}
```

### Unified Donation Screen
```dart
import 'platform_utils.dart';
import 'mobile_payment_service.dart';
import 'web_payment_service.dart';

class DonateScreen extends StatelessWidget {
  final Campaign campaign;
  
  Future<void> _processDonation({
    required BuildContext context,
    required double amount,
    required String email,
  }) async {
    final paymentService = PlatformUtils.isWeb
      ? WebPaymentService()
      : MobilePaymentService();
    
    final success = await paymentService.processDonation(
      amount: amount,
      email: email,
      campaignId: campaign.id,
    );
    
    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DonationSuccessScreen(
            campaign: campaign,
            amount: amount,
          ),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Donate to ${campaign.title}')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Same UI for all platforms
            AmountSelector(onAmountSelected: _selectAmount),
            DonorDetailsForm(
              nameController: _nameController,
              emailController: _emailController,
            ),
            
            // Platform-aware payment button
            ElevatedButton(
              onPressed: () => _processDonation(
                context: context,
                amount: _selectedAmount,
                email: _emailController.text,
              ),
              child: Text(PlatformUtils.isWeb 
                ? 'Continue to Paystack' 
                : 'Donate Now'),
            ),
            
            // Platform-specific info
            if (PlatformUtils.isWeb)
              Text('You will be redirected to complete payment'),
          ],
        ),
      ),
    );
  }
}
```

---

## Feature Parity Matrix

| Feature | Android | iOS | Web (Desktop) | Web (Mobile) |
|---------|---------|-----|---------------|--------------|
| **Browse Campaigns** | ✅ Full | ✅ Full | ✅ Full | ✅ Full |
| **Anonymous Donation** | ✅ Full | ✅ Full | ✅ Full | ✅ Full |
| **Mobile Money** | ✅ Native | ✅ Native | ⚠️ Redirect | ⚠️ Redirect |
| **Card Payment** | ✅ Native | ✅ Native | ✅ Redirect | ✅ Redirect |
| **Create Campaign** | ✅ Full | ✅ Full | ✅ Full | ⚠️ Simplified |
| **Image Upload** | ✅ Gallery/Camera | ✅ Gallery/Camera | ✅ File picker | ⚠️ File picker |
| **Phone Auth** | ✅ SMS/Firebase | ✅ SMS/Firebase | ✅ Firebase | ✅ Firebase |
| **WhatsApp Share** | ✅ Deep link | ✅ Deep link | ✅ Web link | ✅ Deep link |
| **Push Notifications** | ✅ FCM | ✅ APNS | ❌ Not supported | ❌ Not supported |
| **Offline Mode** | ⚠️ Future | ⚠️ Future | ❌ Not applicable | ❌ Not applicable |

**Legend:**
- ✅ Full native experience
- ⚠️ Limited or redirect flow
- ❌ Not supported

---

## Web-Specific Considerations

### 1. Payment Flow Differences
**Mobile:** Paystack SDK opens native payment UI → user completes payment → returns to app  
**Web:** Redirect to Paystack hosted page → user completes payment → redirect back to app

### 2. Authentication
**Mobile:** Firebase Phone Auth with SMS OTP  
**Web:** Same Firebase Phone Auth but uses reCAPTCHA for bot protection

### 3. Image Upload
**Mobile:** Camera + Gallery picker  
**Web:** File input only (no camera access in most browsers)

### 4. Deep Linking
**Mobile:** Open WhatsApp/other apps directly  
**Web:** Use web URLs (e.g., `https://wa.me/` instead of `whatsapp://`)

---

## Progressive Web App (PWA) Setup

Make web version installable and feel native:

```yaml
# web/manifest.json
{
  "name": "Wamo - Give. Help. Reach.",
  "short_name": "Wamo",
  "description": "Mobile-first crowdfunding for Africa",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#2FA4A9",
  "theme_color": "#2FA4A9",
  "orientation": "portrait-primary",
  "icons": [
    {
      "src": "icons/icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

```html
<!-- web/index.html -->
<head>
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="mobile-web-app-capable" content="yes">
  <link rel="manifest" href="manifest.json">
  <meta name="theme-color" content="#2FA4A9">
</head>
```

---

## Implementation Priority

### Week 1: Core Payment Unification
1. Create `PaymentService` interface
2. Implement `MobilePaymentService` with flutter_paystack_plus
3. Implement `WebPaymentService` with Paystack API
4. Merge `donate_screen.dart` and `web_donation_screen.dart`
5. Test both flows end-to-end

### Week 2: Web Optimization
1. Set up PWA manifest
2. Implement payment callback handler
3. Add web-specific loading states (redirect awareness)
4. Test campaign browsing on web
5. Test donation flow on desktop browsers

### Week 3: Mobile Optimization
1. Optimize image upload for mobile (compression)
2. Add offline campaign caching
3. Test WhatsApp sharing on mobile vs web
4. Performance testing (low bandwidth)
5. Cross-browser testing (Chrome, Safari, Firefox)

---

## Trade-offs & Decisions

### What We Sacrifice for Multi-Platform
- **Development time:** +30% for platform-specific code
- **Maintenance complexity:** Must test on 4+ platforms
- **Some native features:** Web can't access camera/contacts

### What We Gain
- **Reach:** Diaspora donors can donate from desktop
- **Campaign discovery:** SEO-friendly web pages
- **Lower barrier:** No app install required for browsing
- **Professional image:** Full web presence builds trust

### Core Principle Maintained
> **Donors can give from any device, creators optimize for mobile**

Campaign creation is still mobile-first (creators are local, have phones).  
Donation is multi-platform (donors are everywhere, use various devices).

---

## Testing Strategy

### Per-Platform Testing
```bash
# Android
flutter run -d android

# iOS  
flutter run -d ios

# Web (Chrome)
flutter run -d chrome

# Web (Production build)
flutter build web --release
firebase deploy --only hosting
```

### Payment Testing Matrix
| Platform | Mobile Money | Card | Test Key |
|----------|--------------|------|----------|
| Android  | ✅ Test | ✅ Test | pk_test_... |
| iOS      | ✅ Test | ✅ Test | pk_test_... |
| Web      | ✅ Test | ✅ Test | pk_test_... |

### Browser Compatibility
- Chrome (Android, Desktop)
- Safari (iOS, macOS)
- Firefox (Desktop)
- Edge (Desktop)

---

## Deployment Architecture

```
┌─────────────────────────────────────────────┐
│           Wamo Multi-Platform App           │
└─────────────────────────────────────────────┘
                      │
         ┌────────────┼────────────┐
         │            │            │
    ┌────▼───┐   ┌───▼────┐  ┌───▼────┐
    │ Android│   │  iOS   │  │  Web   │
    │  App   │   │  App   │  │  App   │
    └────┬───┘   └───┬────┘  └───┬────┘
         │            │           │
         └────────────┼───────────┘
                      │
         ┌────────────▼────────────┐
         │   Firebase Backend      │
         │  (Firestore, Auth,      │
         │   Functions, Storage)   │
         └────────────┬────────────┘
                      │
         ┌────────────▼────────────┐
         │   Paystack Payments     │
         │  • SDK (Mobile)         │
         │  • API (Web)            │
         │  • Webhooks (Backend)   │
         └─────────────────────────┘
```

---

## Migration Path (Existing Code)

### Files to Keep & Enhance
```bash
✅ lib/core/utils/platform_utils.dart  # Already checking platform
✅ web/                                 # Web assets
✅ lib/core/stubs/flutter_paystack_stub.dart  # Convert to proper abstraction
```

### Files to Merge
```bash
🔄 lib/features/donations/donate_screen.dart
🔄 lib/features/donations/web_donation_screen.dart
→  Single unified screen with platform-aware payment
```

### New Files to Create
```bash
📝 lib/core/services/mobile_payment_service.dart
📝 lib/core/services/web_payment_service.dart
📝 lib/core/services/payment_service_interface.dart
📝 web/manifest.json (PWA)
```

---

## Success Metrics (Multi-Platform)

### Mobile Metrics
- Android downloads
- iOS downloads
- Mobile donation completion rate
- Mobile Money usage %

### Web Metrics
- Web visitors
- Campaign views (SEO)
- Web donation completion rate
- Card payment usage %

### Cross-Platform
- Platform distribution of donors
- Average donation amount by platform
- Campaign sharing success rate
- Total reach (mobile + web)

**Target:** 60% mobile, 40% web donations within 3 months

---

## Conclusion

**Multi-platform is achievable** while maintaining core principles:

✅ Donors can give from any device (friction-free)  
✅ Mobile-optimized for African creators  
✅ Paystack works on all platforms  
✅ WhatsApp sharing works everywhere  
✅ Trust & transparency maintained  

**Next Step:** Implement unified payment architecture (Week 1 plan above)
