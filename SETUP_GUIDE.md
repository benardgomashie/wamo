# Wamo - Setup Instructions

## Phase 0: Foundation Complete ✅

The foundational structure for Wamo has been created. Here's what's been set up:

### Project Structure Created
```
✅ Flutter app scaffold (lib/)
✅ Firebase configuration (firebase/)
✅ Core data models
✅ Basic routing and navigation
✅ Theme and constants
✅ Placeholder screens
✅ Cloud Functions structure
✅ Security rules (Firestore & Storage)
```

---

## Next Steps to Get Running

### 1. Install Flutter Dependencies
```bash
cd c:\Users\heshe\Wamo
flutter pub get
```

### 2. Set Up Firebase Project

#### Create Firebase Project
1. Go to https://console.firebase.google.com/
2. Click "Add project"
3. Name it "Wamo" (or wamo-dev for development)
4. Enable Google Analytics (optional for MVP)

#### Enable Firebase Services
In your Firebase project, enable:
- **Authentication** → Phone provider
- **Cloud Firestore** → Create database (start in test mode)
- **Storage** → Set up bucket
- **Cloud Functions** → Upgrade to Blaze plan (pay-as-you-go, includes free tier)

#### Get Firebase Configuration Files

**For Android:**
1. In Firebase Console → Project Settings → Your apps
2. Add Android app
3. Package name: `com.wamo.app` (or your preference)
4. Download `google-services.json`
5. Place it in `android/app/`

**For iOS:**
1. Add iOS app
2. Bundle ID: `com.wamo.app`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/`

### 3. Install Firebase CLI and Deploy Rules

```bash
# Install Firebase CLI (if not already installed)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in project directory
cd c:\Users\heshe\Wamo\firebase
firebase init

# Select your Firebase project
# Choose: Firestore, Functions, Storage

# Deploy security rules
firebase deploy --only firestore:rules,storage
```

### 4. Set Up Cloud Functions

```bash
cd c:\Users\heshe\Wamo\firebase\functions
npm install
npm run build
```

### 5. Configure Environment Variables

Create a `.env` file in the project root:
```env
PAYSTACK_TEST_SECRET_KEY=sk_test_your_key_here
PAYSTACK_TEST_PUBLIC_KEY=pk_test_your_key_here
PAYSTACK_LIVE_SECRET_KEY=sk_live_your_key_here
PAYSTACK_LIVE_PUBLIC_KEY=pk_live_your_key_here
```

For Cloud Functions, set environment variables:
```bash
firebase functions:config:set paystack.secret_key="sk_test_your_key_here"
```

### 6. Initialize Git Repository

```bash
git init
git add .
git commit -m "Initial commit: Wamo Phase 0 foundation"
git branch develop
git branch staging
```

### 7. Run the App

```bash
# Check for connected devices
flutter devices

# Run on connected device/emulator
flutter run
```

---

## What's Working Now

- ✅ App launches with splash screen
- ✅ Navigation to home screen
- ✅ Basic theme and branding applied
- ✅ Placeholder screens for all major features
- ✅ Data models defined
- ✅ Firebase structure ready

## What's Next (Phase 1)

Focus on **Authentication & Core Data** (Weeks 2-3):

1. **Implement Phone Authentication**
   - Firebase Phone Auth integration
   - OTP verification screen
   - User profile creation

2. **Campaign Data Operations**
   - Create campaign CRUD functions
   - Test Firestore operations
   - Implement real-time listeners

3. **Testing**
   - Unit tests for models
   - Firebase emulator testing

---

## Troubleshooting

### Firebase not initialized error
Make sure you've:
- Added google-services.json (Android)
- Added GoogleService-Info.plist (iOS)
- Run `flutter pub get`

### Package errors
```bash
flutter clean
flutter pub get
```

### iOS build issues
```bash
cd ios
pod install --repo-update
cd ..
```

---

## Key Files to Review

- [README.md](README.md) - Complete project documentation
- [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) - Full 8-10 week plan
- [WAMO_PROJECT_SPEC.md](WAMO_PROJECT_SPEC.md) - Technical specifications
- [lib/app/constants.dart](lib/app/constants.dart) - All app constants
- [firebase/firestore.rules](firebase/firestore.rules) - Database security

---

## Development Workflow

1. **Create feature branch**
   ```bash
   git checkout -b feature/phone-auth
   ```

2. **Make changes and test**
   ```bash
   flutter run
   flutter test
   ```

3. **Commit and push**
   ```bash
   git add .
   git commit -m "feat: implement phone authentication"
   git push origin feature/phone-auth
   ```

---

## Team Checklist

- [ ] Review implementation plan
- [ ] Set up Firebase project
- [ ] Configure Paystack test account
- [ ] Add Firebase config files
- [ ] Run `flutter pub get`
- [ ] Test app launches successfully
- [ ] Set up development environment
- [ ] Schedule daily standups

---

**Status:** Foundation Complete - Ready for Phase 1
**Next:** Implement Phone Authentication (Week 2)
