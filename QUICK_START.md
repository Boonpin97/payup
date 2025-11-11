# 🚀 Quick Start Guide

## Get Your App Running in 5 Minutes!

### Step 1: Install Dependencies

Open PowerShell in the project directory and run:

```powershell
flutter pub get
```

This will download all required packages:
- Firebase Core & Firestore
- Date formatting (intl)
- Other dependencies

---

### Step 2: Set Up Firebase

You have **two options**:

#### Option A: Quick Test (Without Real Firebase)

The app will start but won't save data. Good for testing the UI.

1. Just run:
   ```powershell
   flutter run
   ```

2. You'll see Firebase errors in the console, but the UI will work!

#### Option B: Full Setup (With Firebase - Recommended)

Follow the detailed guide in `FIREBASE_SETUP.md` to:
1. Create Firebase project
2. Download config files
3. Update `lib/config/firebase_config.dart`

---

### Step 3: Run the App

```powershell
# See available devices
flutter devices

# Run on Android emulator
flutter run

# Run on iOS simulator (Mac only)
flutter run -d ios

# Run on physical device
flutter run -d <device-id>
```

---

### Step 4: Test the App

1. **Create a Trip**
   - Tap "Create Trip"
   - Enter a trip name (e.g., "Beach Weekend")
   - Note the 6-digit code shown

2. **Add Participants**
   - Add 2-3 participant names
   - Tap "Continue"

3. **Add an Expense**
   - Tap the "+" button
   - Fill in expense details
   - Choose split method (Even/Custom)
   - Tap "Save Expense"

4. **View Balances**
   - See who owes whom
   - View all expenses
   - Check settlement calculations

---

## 📱 App Features at a Glance

### 1️⃣ Trip Sign-In Screen
- **Create Trip**: Generate unique 6-digit code
- **Join Trip**: Enter existing code to join

### 2️⃣ Participants Screen
- Add 1-20 participants
- Quick counter to add/remove slots
- Each participant needs a name

### 3️⃣ Summary Screen (Main Dashboard)
- Total expenses at the top
- **Settlements**: Who owes whom (simplified)
- **Expenses List**: All recorded expenses
- Refresh button to reload data
- Info button to view trip details

### 4️⃣ Add Expense Screen
- Expense name and amount
- Select who paid
- Date/time picker (default: now)
- **Even Split**: Check participants to split among
- **Custom Split**: Enter exact amounts per person
- Auto-fill button for custom splits

---

## 🎨 UI Elements

### Custom Widgets Created
- `CustomButton` - Styled buttons with loading state
- `CustomTextField` - Input fields with validation
- `ExpenseCard` - Display expense with details
- `BalanceCard` - Show debt between two people

### Theme
- Primary color: Blue (#2196F3)
- Clean Material Design
- Rounded corners (12px)
- Card-based layout

---

## 📂 Project Files

```
✅ lib/main.dart                    - App entry & theme
✅ lib/config/firebase_config.dart  - Firebase settings (TODO: Update)
✅ lib/models/
    ✅ trip.dart                    - Trip data model
    ✅ expense.dart                 - Expense data model
✅ lib/services/
    ✅ firebase_service.dart        - All Firebase operations
✅ lib/screens/
    ✅ trip_signin_screen.dart      - Create/join trips
    ✅ participants_screen.dart     - Add participants
    ✅ summary_screen.dart          - Main dashboard
    ✅ add_expense_screen.dart      - Add expenses
✅ lib/widgets/
    ✅ custom_button.dart           - Button component
    ✅ custom_text_field.dart       - Input component
    ✅ expense_card.dart            - Expense display
    ✅ balance_card.dart            - Balance display
```

---

## 🧪 Testing

Run the test:

```powershell
flutter test
```

The basic test checks if the app loads correctly.

---

## 🔧 Troubleshooting

### "No devices found"
Start an Android emulator or iOS simulator first:
```powershell
# List available emulators
flutter emulators

# Start an emulator
flutter emulators --launch <emulator-id>
```

### "Firebase not initialized"
This is expected if you haven't set up Firebase yet. The app will still run but won't save data.

### Build errors
Try cleaning and rebuilding:
```powershell
flutter clean
flutter pub get
flutter run
```

### Hot reload not working
Press `R` in the terminal to hot restart, or `r` for hot reload.

---

## 💡 Development Tips

### Hot Reload
- Press `r` in terminal for hot reload
- Press `R` for hot restart (full restart)
- Press `q` to quit

### Useful Commands
```powershell
flutter doctor          # Check Flutter setup
flutter clean           # Clean build files
flutter pub get         # Get dependencies
flutter pub upgrade     # Update packages
flutter run --release   # Run in release mode
flutter build apk       # Build Android APK
flutter build ios       # Build iOS app
```

### VS Code Extensions (Recommended)
- Flutter
- Dart
- Flutter Widget Snippets

---

## 📖 Next Steps

1. ✅ Run the app and test the UI
2. 🔥 Set up Firebase (see `FIREBASE_SETUP.md`)
3. 📝 Check `FEATURES.md` for feature checklist
4. 🎨 Customize theme in `lib/main.dart`
5. 🚀 Deploy to production

---

## 🆘 Need Help?

- **Firebase Setup**: Read `FIREBASE_SETUP.md`
- **Features List**: Check `FEATURES.md`
- **Full Documentation**: See `README.md`
- **Flutter Docs**: https://docs.flutter.dev
- **Firebase Docs**: https://firebase.google.com/docs

---

**Happy Coding! 🎉**
