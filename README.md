# Wamo - Give. Help. Reach.

**Mobile-first crowdfunding platform for Africa**

> "Wamo" means "help" in Ga

## Project Overview

Wamo enables fast, trusted fundraising in Africa using local payment systems (Mobile Money + Cards) and community trust models.

### Mission
Make fundraising in Africa accessible, trustworthy, and effective by building platforms designed for local payments, real communities, and real needs.

### MVP Scope
- **Geography:** Ghana
- **Users:** Individual campaign creators + donors (local & diaspora)
- **Payments:** Paystack (Mobile Money + Cards)
- **Platform:** Flutter (iOS + Android)
- **Backend:** Firebase

---

## Tech Stack

- **Frontend:** Flutter 3.x
- **Backend:** Firebase
  - Authentication (Phone OTP)
  - Cloud Firestore
  - Cloud Functions (Node.js/TypeScript)
  - Firebase Storage
  - Firebase Analytics & Crashlytics
- **Payments:** Paystack
- **Version Control:** Git + GitHub

---

## Project Structure

```
wamo/
├── README.md
├── IMPLEMENTATION_PLAN.md
├── WAMO_PROJECT_SPEC.md
├── lib/                      # Flutter application code
│   ├── main.dart
│   ├── app/
│   │   ├── routes.dart
│   │   ├── theme.dart
│   │   └── constants.dart
│   ├── core/
│   │   ├── models/
│   │   ├── services/
│   │   └── utils/
│   ├── features/
│   │   ├── auth/
│   │   ├── campaigns/
│   │   ├── donations/
│   │   ├── dashboard/
│   │   └── notifications/
│   └── widgets/
│       └── shared/
├── firebase/                 # Firebase backend code
│   ├── firestore.rules
│   ├── storage.rules
│   └── functions/
│       ├── src/
│       │   ├── index.ts
│       │   ├── webhooks/
│       │   ├── campaigns/
│       │   └── notifications/
│       ├── package.json
│       └── tsconfig.json
├── test/                     # Flutter tests
├── android/                  # Android-specific files
├── ios/                      # iOS-specific files
└── pubspec.yaml             # Flutter dependencies
```

---

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK:** 3.x or higher ([Install Flutter](https://flutter.dev/docs/get-started/install))
- **Dart SDK:** Included with Flutter
- **Firebase CLI:** `npm install -g firebase-tools`
- **Node.js:** v16+ (for Cloud Functions)
- **Git:** For version control
- **Android Studio or Xcode:** For mobile development

### Editor Recommendations
- VS Code with Flutter & Dart extensions
- Android Studio

---

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/wamo.git
cd wamo
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project named "Wamo"
3. Enable the following services:
   - Authentication (Phone provider)
   - Cloud Firestore
   - Cloud Storage
   - Cloud Functions
   - Analytics
   - Crashlytics

#### Configure Firebase for Flutter

**For Android:**
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/`

**For iOS:**
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place it in `ios/Runner/`

#### Install Firebase CLI and Login

```bash
npm install -g firebase-tools
firebase login
```

#### Initialize Firebase in Project

```bash
firebase init
```

Select:
- Firestore
- Functions
- Storage
- Hosting (optional, for admin panel)

### 4. Set Up Cloud Functions

```bash
cd firebase/functions
npm install
```

### 5. Environment Variables

Create a `.env` file in the project root:

```env
# Paystack
PAYSTACK_TEST_SECRET_KEY=sk_test_xxxxx
PAYSTACK_TEST_PUBLIC_KEY=pk_test_xxxxx
PAYSTACK_LIVE_SECRET_KEY=sk_live_xxxxx
PAYSTACK_LIVE_PUBLIC_KEY=pk_live_xxxxx

# Firebase
FIREBASE_PROJECT_ID=wamo-dev
```

**Never commit `.env` to Git!**

### 6. Run the App

```bash
# Check connected devices
flutter devices

# Run on connected device
flutter run

# Run in debug mode
flutter run --debug

# Run in release mode
flutter run --release
```

---

## Development Workflow

### Branch Strategy
- `main` - Production-ready code
- `develop` - Development branch
- `staging` - Pre-production testing
- `feature/*` - Feature branches

### Making Changes
1. Create a feature branch: `git checkout -b feature/campaign-creation`
2. Make your changes
3. Write tests
4. Commit: `git commit -m "feat: add campaign creation flow"`
5. Push: `git push origin feature/campaign-creation`
6. Create Pull Request to `develop`

### Commit Message Convention
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting)
- `refactor:` - Code refactoring
- `test:` - Adding tests
- `chore:` - Build process or auxiliary tool changes

---

## Testing

### Run Unit Tests
```bash
flutter test
```

### Run Widget Tests
```bash
flutter test test/widgets
```

### Run Integration Tests
```bash
flutter test integration_test
```

### Code Coverage
```bash
flutter test --coverage
```

---

## Firebase Deployment

### Deploy Firestore Rules
```bash
firebase deploy --only firestore:rules
```

### Deploy Storage Rules
```bash
firebase deploy --only storage
```

### Deploy Cloud Functions
```bash
cd firebase/functions
npm run build
firebase deploy --only functions
```

### Deploy Everything
```bash
firebase deploy
```

---

## Paystack Integration

### Test Mode
Use Paystack test keys during development.

**Test Cards:**
- Success: `4084084084084081`
- Insufficient Funds: `4084080000000409`

**Test Mobile Money:**
- MTN: `0241234567` (any 10-digit Ghana number in test mode)

### Live Mode
Switch to live keys only after thorough testing and admin approval.

---

## Project Configuration

### Flutter Packages (Core)
- `firebase_core` - Firebase initialization
- `firebase_auth` - Authentication
- `cloud_firestore` - Database
- `firebase_storage` - File storage
- `firebase_analytics` - Analytics
- `firebase_crashlytics` - Crash reporting
- `flutter_paystack` - Payment processing

### Additional Packages
- `provider` or `riverpod` - State management
- `go_router` - Navigation
- `cached_network_image` - Image caching
- `image_picker` - Photo selection
- `share_plus` - Sharing functionality
- `url_launcher` - Open URLs (WhatsApp, etc.)

---

## Common Issues & Solutions

### Issue: Firebase not initialized
**Solution:** Ensure `Firebase.initializeApp()` is called in `main.dart` before running the app.

### Issue: Gradle build fails (Android)
**Solution:** Check `android/build.gradle` has correct Google Services plugin.

### Issue: CocoaPods error (iOS)
**Solution:** 
```bash
cd ios
pod install --repo-update
```

### Issue: Phone auth not working
**Solution:** 
- Enable Phone authentication in Firebase Console
- For iOS: Configure reCAPTCHA verification
- For Android: Add SHA-1 fingerprint to Firebase

---

## Performance Optimization

- Use `const` constructors where possible
- Implement lazy loading for lists
- Compress images before upload (max 2MB)
- Use Firestore pagination for large datasets
- Cache frequently accessed data
- Optimize Firestore queries (use indexes)

---

## Security Best Practices

- Never store API keys in code
- Use Firestore security rules
- Validate all inputs
- Sanitize user-generated content
- Use HTTPS only
- Implement rate limiting in Cloud Functions
- Verify Paystack webhook signatures

---

## Support & Documentation

- **Implementation Plan:** See [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)
- **Project Spec:** See [WAMO_PROJECT_SPEC.md](WAMO_PROJECT_SPEC.md)
- **Flutter Docs:** https://flutter.dev/docs
- **Firebase Docs:** https://firebase.google.com/docs
- **Paystack Docs:** https://paystack.com/docs

---

## Team

- **Product Lead:** [Name]
- **Mobile Developer:** [Name]
- **Backend Developer:** [Name]
- **Designer:** [Name]

---

## License

Proprietary - All rights reserved

---

## Contact

For questions or support, contact: [team@wamo.app]

---

**Built with ❤️ for Africa**
