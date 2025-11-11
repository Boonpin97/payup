# 🔥 Firebase Setup Guide

## Overview

This app uses **FlutterFire** (Firebase for Flutter) which requires:
1. **Platform-specific files** for builds:
   - Android: `google-services.json`
   - iOS: `GoogleService-Info.plist`
2. **Firebase config values** in code (`firebase_config.dart`) - same for all platforms

You'll register your app with Firebase for each platform you want to support, but the configuration values used in the Dart code are platform-agnostic.

### What You Need:

```
Firebase Project
├── Android App Registration
│   └── Generates: google-services.json
│       └── Place in: android/app/
│
├── iOS App Registration  
│   └── Generates: GoogleService-Info.plist
│       └── Place in: ios/Runner/
│
└── Config Values (from any platform)
    └── Add to: lib/config/firebase_config.dart
        ├── FIREBASE_API_KEY
        ├── FIREBASE_APP_ID
        ├── FIREBASE_MESSAGING_SENDER_ID
        ├── FIREBASE_PROJECT_ID
        ├── FIREBASE_AUTH_DOMAIN
        └── FIREBASE_STORAGE_BUCKET
```

---

## Step-by-Step Firebase Configuration

### 1. Create Firebase Project

1. Visit [Firebase Console](https://console.firebase.google.com)
2. Click **"Add project"**
3. Enter project name (e.g., "PayUp-App")
4. (Optional) Enable Google Analytics
5. Click **"Create project"**

---

### 2. Enable Cloud Firestore

1. In Firebase Console, click **"Firestore Database"** in left sidebar
2. Click **"Create database"**
3. Choose **"Start in test mode"** (for development)
4. Select your preferred region (closest to your users)
5. Click **"Enable"**

⚠️ **Important**: Test mode allows read/write access for 30 days. Update rules before production!

---

### 3. Add Flutter App to Firebase

**Important:** You need to register your app for each platform you want to support. For mobile development, register Android and/or iOS apps. The configuration values you'll use in the code are the same across platforms.

#### For Android:

1. In Firebase Console, click the **Android icon** (⚙️ → Project settings)
2. Click **"Add app"** → **Android**
3. Enter details:
   - **Android package name**: `com.example.pay_up` (or check `android/app/build.gradle`)
   - **App nickname**: PayUp (optional)
   - **Debug signing certificate**: Leave blank for now
4. Click **"Register app"**
5. Download **`google-services.json`**
6. Place it in: `android/app/google-services.json`

#### For iOS:

1. In Firebase Console, click the **iOS icon**
2. Click **"Add app"** → **iOS**
3. Enter details:
   - **Bundle ID**: `com.example.payUp` (or check `ios/Runner.xcodeproj`)
   - **App nickname**: PayUp (optional)
4. Click **"Register app"**
5. Download **`GoogleService-Info.plist`**
6. Place it in: `ios/Runner/GoogleService-Info.plist`
7. Open `ios/Runner.xcworkspace` in Xcode
8. Drag `GoogleService-Info.plist` into the project (under Runner folder)

**📱 Platform Files Summary:**
- `google-services.json` → Needed for Android builds
- `GoogleService-Info.plist` → Needed for iOS builds  
- Config values in `firebase_config.dart` → Needed for Firebase initialization (works for all platforms)

---

### 4. Get Firebase Configuration Values

This app uses **platform-agnostic Firebase initialization**, which means the same config works for Android, iOS, and Web.

**Option A: Get values from Android app (Recommended)**

1. Go to **Firebase Console** → **Project Settings** (⚙️ icon)
2. Scroll down to **"Your apps"** section
3. Click on your **Android app**
4. In the Firebase SDK snippet, find these values:
   - Look for `"api_key"` → use for **FIREBASE_API_KEY**
   - Look for `"mobilesdk_app_id"` → use for **FIREBASE_APP_ID**
   - Look for `"project_number"` → use for **FIREBASE_MESSAGING_SENDER_ID**
   - Look for `"project_id"` → use for **FIREBASE_PROJECT_ID**

**Option B: Add a Web app to get values easily**

1. In Firebase Console → Project Settings
2. Click **"Add app"** → Choose **Web** (</> icon)
3. Register app nickname: "PayUp Web"
4. You'll see a config object like this:

```javascript
const firebaseConfig = {
  apiKey: "AIzaSy...",              // FIREBASE_API_KEY
  authDomain: "your-project.firebaseapp.com",  // FIREBASE_AUTH_DOMAIN
  projectId: "your-project-id",     // FIREBASE_PROJECT_ID
  storageBucket: "your-project.appspot.com",   // FIREBASE_STORAGE_BUCKET
  messagingSenderId: "123456",      // FIREBASE_MESSAGING_SENDER_ID
  appId: "1:123456:web:abc123"      // FIREBASE_APP_ID
};
```

**Note:** Adding a Web app is just to easily see these values. The same values work for Android and iOS.

5. Copy these values to `lib/config/firebase_config.dart`:

```dart
const String FIREBASE_API_KEY = 'AIzaSy...';
const String FIREBASE_APP_ID = '1:123456:...';
const String FIREBASE_MESSAGING_SENDER_ID = '123456';
const String FIREBASE_PROJECT_ID = 'your-project-id';
const String FIREBASE_AUTH_DOMAIN = 'your-project-id.firebaseapp.com';
const String FIREBASE_STORAGE_BUCKET = 'your-project-id.appspot.com';
```

---

### 5. Update Firestore Security Rules

1. In Firebase Console, go to **"Firestore Database"**
2. Click **"Rules"** tab
3. Replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write access to trips collection
    match /trips/{tripId} {
      allow read, write: if true; // Change this later with proper auth
      
      // Allow access to expenses subcollection
      match /expenses/{expenseId} {
        allow read, write: if true;
      }
    }
  }
}
```

4. Click **"Publish"**

⚠️ **Security Warning**: The rules above allow anyone to read/write. This is OK for development but **NOT for production**. Later, add Firebase Authentication and restrict access.

---

### 6. Create Firestore Indexes (Optional but Recommended)

1. In Firebase Console, go to **"Firestore Database"** → **"Indexes"** tab
2. Add composite index:
   - **Collection**: `trips/expenses`
   - **Fields**:
     - `dateTime` (Descending)
   - **Status**: Enable
3. This improves query performance when fetching expenses

---

### 7. Install Dependencies

Run in your terminal:

```powershell
flutter pub get
```

This installs:
- `firebase_core` - Firebase SDK
- `cloud_firestore` - Firestore database
- `intl` - Date formatting

---

### 8. Test Firebase Connection

1. Run the app:
   ```powershell
   flutter run
   ```

2. Check console output for:
   ```
   Firebase initialized successfully
   ```

3. If you see errors:
   - Verify `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) exists
   - Check package name/bundle ID matches Firebase registration
   - Ensure `firebase_config.dart` has correct values

---

### 9. Test Firestore Operations

1. Create a new trip in the app
2. Go to **Firebase Console** → **Firestore Database**
3. You should see:
   ```
   trips
   └── [auto-generated-id]
       ├── tripName: "Your Trip Name"
       ├── signInCode: "123456"
       ├── participants: []
       └── createdAt: [timestamp]
   ```

---

## 🔐 Production Security Checklist

Before launching to real users:

- [ ] Enable Firebase Authentication
- [ ] Update Firestore rules to require authentication
- [ ] Implement user-based access control
- [ ] Restrict trip access to participants only
- [ ] Enable App Check to prevent abuse
- [ ] Set up billing alerts
- [ ] Enable backup for Firestore
- [ ] Add rate limiting

### Example Production Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /trips/{tripId} {
      // Only authenticated users can read/write
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
                            request.auth.uid in resource.data.participants;
      
      match /expenses/{expenseId} {
        allow read, write: if request.auth != null;
      }
    }
  }
}
```

---

## 🐛 Common Issues

### Issue: "Confused about Android vs Web vs iOS setup?"
**Clarification:**
- **Register Android app** → Get `google-services.json` → Needed for Android builds
- **Register iOS app** → Get `GoogleService-Info.plist` → Needed for iOS builds
- **Add Web app (optional)** → Easiest way to see config values → Copy to `firebase_config.dart`
- The config values (apiKey, appId, etc.) are **the same** regardless of which platform you get them from
- The platform files (`.json`, `.plist`) are **different** and platform-specific

### Issue: "Default FirebaseApp is not initialized"
**Solution**: 
- Check that `main()` calls `await FirebaseService().initializeFirebase()`
- Verify Firebase config values in `firebase_config.dart`

### Issue: "google-services.json not found"
**Solution**:
- Place file in `android/app/google-services.json`
- Run `flutter clean` then `flutter pub get`

### Issue: "Permission denied" when writing to Firestore
**Solution**:
- Check Firestore Rules allow write access
- Start in "test mode" for development

### Issue: iOS build fails
**Solution**:
- Open `ios/Runner.xcworkspace` (not .xcodeproj)
- Ensure `GoogleService-Info.plist` is in Xcode project
- Run `pod install` in `ios/` directory

---

## 📚 Additional Resources

- [Firebase Flutter Documentation](https://firebase.flutter.dev/)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [FlutterFire GitHub](https://github.com/firebase/flutterfire)
- [Firebase Console](https://console.firebase.google.com)

---

**Need Help?** Check the [Firebase Support](https://firebase.google.com/support) or Flutter community forums.
