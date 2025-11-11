# ✅ Setup Checklist - Follow These Steps!

Print this out or check off as you complete each step.

---

## 📱 Phase 1: Quick Test (5 minutes)

Test the app without Firebase to see if everything works:

- [ ] Open terminal/PowerShell in project folder
- [ ] Run: `flutter pub get`
- [ ] Wait for packages to download
- [ ] Run: `flutter run`
- [ ] App should launch (ignore Firebase errors)
- [ ] Click around to see the UI
- [ ] Test form validation
- [ ] Note: Data won't save without Firebase

✅ **Result:** You've confirmed the app UI works!

---

## 🔥 Phase 2: Firebase Setup (15-20 minutes)

Get Firebase working so data actually saves:

### Step 1: Create Firebase Project
- [ ] Go to [console.firebase.google.com](https://console.firebase.google.com)
- [ ] Click "Add project"
- [ ] Name it (e.g., "PayUp")
- [ ] Disable Google Analytics (optional)
- [ ] Click "Create project"
- [ ] Wait for it to complete
- [ ] Click "Continue"

### Step 2: Enable Firestore
- [ ] Click "Firestore Database" in left sidebar
- [ ] Click "Create database"
- [ ] Choose "Start in test mode"
- [ ] Select your region (closest to you)
- [ ] Click "Enable"
- [ ] Wait for setup to complete

### Step 3: Register Your App

**For Android:**
- [ ] Click "⚙️" (Project Settings) → "Your apps"
- [ ] Click Android icon
- [ ] Package name: `com.example.pay_up`
  (or find yours in `android/app/build.gradle`)
- [ ] Click "Register app"
- [ ] Download `google-services.json`
- [ ] Move it to: `android/app/google-services.json`
- [ ] Click "Next" → "Next" → "Continue to console"

**For iOS (if needed):**
- [ ] Click iOS icon in Project Settings
- [ ] Bundle ID: `com.example.payUp`
  (or find yours in Xcode project)
- [ ] Click "Register app"
- [ ] Download `GoogleService-Info.plist`
- [ ] Move it to: `ios/Runner/GoogleService-Info.plist`
- [ ] Open `ios/Runner.xcworkspace` in Xcode
- [ ] Drag the plist file into Runner folder
- [ ] Click "Next" → "Next" → "Continue to console"

### Step 4: Get Firebase Config

**Easiest Method:** Add a Web app to see config values clearly

- [ ] In Firebase Console → Project Settings
- [ ] Click "Add app" → Choose **Web** (</> icon)
- [ ] Register app: "PayUp Web"
- [ ] You'll see config like:
  ```javascript
  apiKey: "AIzaSy..."
  authDomain: "project.firebaseapp.com"
  projectId: "your-project-name"
  storageBucket: "project.appspot.com"
  messagingSenderId: "123456"
  appId: "1:123456:web:abc"
  ```
- [ ] Copy these values (same values work for Android/iOS)

**Note:** Adding Web app is just to see values easily. You don't need to build for Web.

**Alternative:** Get values from Android app config in Firebase Console

### Step 5: Update Config File
- [ ] Open `lib/config/firebase_config.dart` in VS Code
- [ ] Replace `YOUR_API_KEY_HERE` with your `apiKey`
- [ ] Replace `YOUR_APP_ID_HERE` with your `appId`
- [ ] Replace `YOUR_SENDER_ID_HERE` with your `messagingSenderId`
- [ ] Replace `YOUR_PROJECT_ID_HERE` with your `projectId`
- [ ] Save the file

### Step 6: Set Firestore Rules
- [ ] In Firebase Console → Firestore Database
- [ ] Click "Rules" tab
- [ ] Replace content with:
  ```javascript
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      match /trips/{tripId} {
        allow read, write: if true;
        match /expenses/{expenseId} {
          allow read, write: if true;
        }
      }
    }
  }
  ```
- [ ] Click "Publish"

✅ **Result:** Firebase is configured!

---

## 🎮 Phase 3: Test With Firebase (10 minutes)

Now test that everything actually saves:

- [ ] Stop the app if running (press `q`)
- [ ] Run: `flutter clean`
- [ ] Run: `flutter pub get`
- [ ] Run: `flutter run`
- [ ] Look for: "Firebase initialized successfully" in console
- [ ] If error, double-check Phase 2 steps

### Test 1: Create Trip
- [ ] Click "Create Trip"
- [ ] Enter name: "Test Trip"
- [ ] Click "Create Trip"
- [ ] See 6-digit code appear
- [ ] Click "Continue"

### Test 2: Add Participants
- [ ] Set participant count to 3
- [ ] Enter names: "Alice", "Bob", "Carol"
- [ ] Click "Continue"

### Test 3: Add Expense
- [ ] Click "+" button
- [ ] Name: "Lunch"
- [ ] Amount: "30.00"
- [ ] Paid by: "Alice"
- [ ] Keep all participants checked
- [ ] Click "Save Expense"
- [ ] See expense appear in list

### Test 4: Check Balance
- [ ] Look at "Settlements" section
- [ ] Should show "Bob owes Alice $10.00"
- [ ] Should show "Carol owes Alice $10.00"
- [ ] Total should be $30.00

### Test 5: Verify in Firebase
- [ ] Open Firebase Console
- [ ] Go to Firestore Database
- [ ] Click on `trips` collection
- [ ] See your trip document
- [ ] Click on `expenses` subcollection
- [ ] See your expense

✅ **Result:** Everything works end-to-end!

---

## 🎨 Phase 4: Customize (Optional)

Make it your own:

### Change Theme
- [ ] Open `lib/main.dart`
- [ ] Find `primarySwatch: Colors.blue`
- [ ] Change to: `Colors.purple`, `Colors.green`, etc.
- [ ] Hot reload to see changes

### Change App Name
- [ ] Android: `android/app/src/main/AndroidManifest.xml`
  - Change `android:label="pay_up"` to your name
- [ ] iOS: `ios/Runner/Info.plist`
  - Change `CFBundleName` to your name

### Add App Icon
- [ ] Use a tool like [appicon.co](https://appicon.co)
- [ ] Generate icons for Android and iOS
- [ ] Replace default icons in:
  - `android/app/src/main/res/mipmap-*/`
  - `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

✅ **Result:** App is personalized!

---

## 🚀 Phase 5: Deploy (When Ready)

### For Testing
- [ ] Connect your phone via USB
- [ ] Enable Developer Mode on phone
- [ ] Run: `flutter run -d <your-device>`
- [ ] App installs on your phone

### For Production
- [ ] Update Firestore security rules (see `FIREBASE_SETUP.md`)
- [ ] Add user authentication
- [ ] Test thoroughly
- [ ] Build release:
  - Android: `flutter build apk --release`
  - iOS: `flutter build ios --release`
- [ ] Distribute to friends or publish to stores

✅ **Result:** App is deployed!

---

## 📚 Reference Documents

Keep these handy:

- **Quick help**: `QUICK_START.md`
- **Firebase steps**: `FIREBASE_SETUP.md`
- **Feature list**: `FEATURES.md`
- **Full guide**: `README.md`
- **Summary**: `PROJECT_SUMMARY.md`

---

## 🆘 Troubleshooting

### Problem: "No devices found"
**Solution:**
```powershell
flutter emulators                    # List emulators
flutter emulators --launch <name>    # Start one
```

### Problem: "Firebase not initialized"
**Solution:** Check `lib/config/firebase_config.dart` has correct values

### Problem: "google-services.json not found"
**Solution:** Make sure file is in `android/app/` folder

### Problem: Build errors
**Solution:**
```powershell
flutter clean
flutter pub get
flutter run
```

### Problem: Permission denied in Firestore
**Solution:** Check Firestore Rules allow read/write

### Problem: App is slow
**Solution:** Run in release mode: `flutter run --release`

---

## ✨ Success Indicators

You'll know it's working when:

✅ App launches without errors  
✅ Console shows "Firebase initialized successfully"  
✅ You can create a trip  
✅ Trip appears in Firebase Console  
✅ You can add participants  
✅ You can add expenses  
✅ Balances calculate correctly  
✅ Data persists after closing app  

---

## 🎉 Congratulations!

When all boxes are checked, you have:
- ✅ A working expense tracking app
- ✅ Cloud data storage
- ✅ Beautiful UI
- ✅ Ready for real use

**Now invite friends to test it!**

---

## 📝 Notes Section

Use this space to jot down:
- Your Firebase Project ID: ___________________
- Your app package name: ___________________
- Issues encountered: ___________________
- Features to add: ___________________

---

**Happy building! 🚀**
