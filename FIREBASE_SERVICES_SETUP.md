# Firebase Services Setup Guide

## ✅ Completed
- [x] Firebase project created (wamo-26a85)
- [x] FlutterFire CLI configuration complete
- [x] All platforms registered (Android, iOS, Web, macOS, Windows)
- [x] firebase_options.dart generated
- [x] Security rules written (Firestore & Storage)
- [x] Cloud Functions scaffolded

## 🔧 Next Steps: Enable Firebase Services

### 1. Enable Firebase Authentication

1. Go to [Firebase Console](https://console.firebase.google.com/project/wamo-26a85)
2. Navigate to **Build** → **Authentication**
3. Click **Get Started**
4. Enable **Phone** provider:
   - Click on **Phone** in the Sign-in method tab
   - Toggle **Enable**
   - Click **Save**

5. (Optional) Enable **Email/Password** for diaspora users:
   - Click on **Email/Password**
   - Toggle **Enable**
   - Click **Save**

### 2. Enable Cloud Firestore

1. In Firebase Console, navigate to **Build** → **Firestore Database**
2. Click **Create database**
3. Select **Start in test mode** (we'll deploy rules later)
4. Choose location: **eur3 (europe-west)** (closest to Ghana)
5. Click **Enable**

### 3. Enable Cloud Storage

1. Navigate to **Build** → **Storage**
2. Click **Get started**
3. Select **Start in test mode**
4. Use the default location (same as Firestore)
5. Click **Done**

### 4. Enable Firebase Cloud Messaging (for notifications)

1. Navigate to **Build** → **Cloud Messaging**
2. Cloud Messaging should already be enabled
3. Note down the **Server key** from Cloud Messaging API (legacy) if needed

### 5. Enable Analytics & Crashlytics

1. Navigate to **Build** → **Analytics**
2. Click **Enable Google Analytics** (if not already enabled)
3. Navigate to **Release & Monitor** → **Crashlytics**
4. Crashlytics will be auto-enabled when you run the app

## 📋 Deploy Security Rules

Once Firestore and Storage are enabled, deploy the security rules:

\`\`\`bash
cd c:\\Users\\heshe\\Wamo

# Login to Firebase (if not already logged in)
firebase login

# Set the active project
firebase use wamo-26a85

# Deploy Firestore and Storage rules
firebase deploy --only firestore:rules,storage
\`\`\`

## 🚀 Deploy Cloud Functions

\`\`\`bash
cd c:\\Users\\heshe\\Wamo\\firebase\\functions

# Install dependencies
npm install

# Deploy functions
cd ..
firebase deploy --only functions
\`\`\`

## ⚙️ Configure Paystack Webhook

After deploying Cloud Functions:

1. Get your Cloud Function URL:
   - Go to Firebase Console → **Functions**
   - Find the `paystackWebhook` function
   - Copy the function URL

2. Configure Paystack webhook:
   - Go to [Paystack Dashboard](https://dashboard.paystack.com)
   - Navigate to **Settings** → **Webhooks**
   - Add webhook URL: `https://YOUR_REGION-wamo-26a85.cloudfunctions.net/paystackWebhook`
   - Save

3. Get Paystack keys:
   - In Paystack Dashboard, go to **Settings** → **API Keys & Webhooks**
   - Copy your **Secret Key** and **Public Key**

4. Add Paystack keys to Firebase Functions:
   \`\`\`bash
   firebase functions:config:set paystack.secret_key="YOUR_SECRET_KEY"
   firebase functions:config:set paystack.public_key="YOUR_PUBLIC_KEY"
   
   # Redeploy functions to use the config
   firebase deploy --only functions
   \`\`\`

## 🧪 Test the Application

\`\`\`bash
# Run the app on a connected device or emulator
flutter run

# Or run on web
flutter run -d chrome
\`\`\`

## ✅ Verification Checklist

After completing all steps:

- [ ] Firebase Authentication is enabled with Phone provider
- [ ] Cloud Firestore database is created
- [ ] Cloud Storage is enabled
- [ ] Firestore rules are deployed
- [ ] Storage rules are deployed
- [ ] Cloud Functions are deployed
- [ ] Paystack webhook is configured
- [ ] App runs successfully with Firebase initialized
- [ ] Phone authentication works (can send OTP)
- [ ] User profile creation works

## 🐛 Troubleshooting

### Issue: "Firebase project not found"
**Solution:** Ensure you're logged into the correct Google account with access to the project.

### Issue: "Insufficient permissions to deploy"
**Solution:** Check that your Google account has Editor or Owner role in the Firebase project.

### Issue: "Phone authentication not working"
**Solution:** 
- Check that Phone provider is enabled in Firebase Console
- Ensure test phone numbers are properly configured (if testing)
- Verify Android SHA-1 fingerprints are added (for Android)

### Issue: "Firestore permission denied"
**Solution:** 
- Deploy security rules: `firebase deploy --only firestore:rules`
- Check rules allow authenticated users to read/write

### Issue: "Cloud Functions deployment fails"
**Solution:**
- Ensure Node.js is installed (v18 or higher)
- Run `npm install` in firebase/functions directory
- Check Firebase billing is enabled (Blaze plan required for Functions)

## 📚 Next Development Steps

After Firebase services are enabled and tested:

1. **Week 3-4: Campaign Creation & Management**
   - Implement campaign creation form
   - Add image upload functionality
   - Build campaign detail page
   - Add campaign editing

2. **Week 4-5: Donation Flow**
   - Integrate Paystack payment SDK
   - Build donation UI
   - Implement payment processing
   - Show donation success/failure

3. **Week 5-6: Campaign Discovery**
   - Build search and filter UI
   - Add category browsing
   - Implement trending/featured campaigns
   - Add campaign sharing

## 📞 Support

For Firebase-specific issues, check:
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev)
- [Firebase Support](https://firebase.google.com/support)
