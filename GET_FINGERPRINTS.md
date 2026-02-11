# Firebase Configuration Guide

## SHA-1/SHA-256 Fingerprints for Android

### Debug Certificate (for development)

**Windows:**
```bash
cd android
gradlew signingReport
```

**Or using keytool directly:**
```bash
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

**Output will show:**
```
SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
SHA-256: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
```

### Add to Firebase Console

1. Go to: https://console.firebase.google.com/project/wamo-26a85/settings/general
2. Scroll to **"Your apps"** → Click Android app
3. Click **"Add fingerprint"**
4. Paste the SHA-1 value
5. Click **"Add fingerprint"** again and add SHA-256
6. Download the updated `google-services.json` and replace `android/app/google-services.json`

### Production Certificate (when ready)

**For release builds, also add your release keystore fingerprint:**
```bash
keytool -list -v -keystore your-release-key.keystore -alias your-key-alias
```

---

## Authorized Domains for Web

### Add Localhost for Development

1. Go to: https://console.firebase.google.com/project/wamo-26a85/authentication/settings
2. Click **"Authorized domains"** tab
3. Click **"Add domain"**
4. Add: `localhost`
5. Save

### Production Domain (already configured)

Your production domain `wamo-26a85.web.app` should already be there. If not, add:
- `wamo-26a85.web.app`
- `wamo-26a85.firebaseapp.com`

### Custom Domain (if you have one)

If you get a custom domain like `wamo.app`:
1. Click **"Add domain"**
2. Enter your domain
3. Save

---

## Quick Commands

**Get Android fingerprints:**
```bash
cd android && gradlew signingReport
```

**Look for this section in output:**
```
Variant: debug
Config: debug
Store: C:\Users\YourName\.android\debug.keystore
Alias: AndroidDebugKey
MD5: ...
SHA1: [COPY THIS]
SHA-256: [COPY THIS]
```

Then add both SHA-1 and SHA-256 to Firebase Console.
