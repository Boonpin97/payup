# PayUp - Group Expense Tracker

A Flutter mobile app for tracking and splitting group expenses during trips, similar to Splitwise or SettleUp. Built with Firebase Firestore as the backend.

## 📱 Features

- ✅ **Trip Management**: Create or join trips using unique sign-in codes
- ✅ **Participant Management**: Add multiple participants to each trip
- ✅ **Expense Tracking**: Add, view, and delete expenses
- ✅ **Smart Splitting**: Even split or custom amount splits
- ✅ **Balance Calculation**: Automatic calculation of who owes whom
- ✅ **Real-time Sync**: All data synced with Firebase Firestore
- ✅ **Clean UI**: Modern Material Design interface

## 🏗️ Project Structure

```
lib/
├── config/
│   └── firebase_config.dart       # Firebase configuration (TODO: Add your credentials)
├── models/
│   ├── expense.dart                # Expense data model
│   └── trip.dart                   # Trip data model
├── screens/
│   ├── add_expense_screen.dart     # Add new expense
│   ├── participants_screen.dart    # Add participants to trip
│   ├── summary_screen.dart         # Main dashboard with expenses and balances
│   └── trip_signin_screen.dart     # Create or join trip
├── services/
│   └── firebase_service.dart       # Firebase CRUD operations
├── widgets/
│   ├── balance_card.dart           # Display balance info
│   ├── custom_button.dart          # Reusable button widget
│   ├── custom_text_field.dart      # Reusable input field
│   └── expense_card.dart           # Display expense info
└── main.dart                       # App entry point
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK (3.9.2 or higher)
- Firebase account
- Android Studio / Xcode (for running on emulator/device)

### Firebase Setup

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Click "Add project"
   - Follow the setup wizard

2. **Enable Firestore Database**
   - In your Firebase project, go to "Firestore Database"
   - Click "Create database"
   - Start in **test mode** (you'll update rules later)
   - Choose your region

3. **Add Your App to Firebase**
   
   **For Android:**
   - Click "Add app" → Android icon
   - Enter package name: `com.example.pay_up` (or your custom package)
   - Download `google-services.json`
   - Place it in `android/app/`
   
   **For iOS:**
   - Click "Add app" → iOS icon
   - Enter bundle ID: `com.example.payUp` (or your custom ID)
   - Download `GoogleService-Info.plist`
   - Place it in `ios/Runner/`

4. **Update Firebase Configuration**
   - Open `lib/config/firebase_config.dart`
   - Replace placeholder values with your Firebase project details:
   ```dart
   const String FIREBASE_API_KEY = 'your-api-key';
   const String FIREBASE_APP_ID = 'your-app-id';
   const String FIREBASE_MESSAGING_SENDER_ID = 'your-sender-id';
   const String FIREBASE_PROJECT_ID = 'your-project-id';
   ```
   
   You can find these values in:
   - Firebase Console → Project Settings → General
   - Scroll down to "Your apps" section

5. **Set Firestore Security Rules**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /trips/{tripId} {
         allow read, write: if true; // TODO: Add proper authentication
         match /expenses/{expenseId} {
           allow read, write: if true;
         }
       }
     }
   }
   ```

### Installation

1. **Clone the repository** (or use your existing project)

2. **Install dependencies**
   ```powershell
   flutter pub get
   ```

3. **Run the app**
   ```powershell
   # For Android
   flutter run

   # For iOS
   flutter run -d ios

   # For specific device
   flutter devices
   flutter run -d <device-id>
   ```

## 📊 Firebase Schema

```
Firestore Database
└── trips (collection)
    └── [tripId] (document)
        ├── tripName: string
        ├── signInCode: string (6-digit code)
        ├── participants: array<string>
        ├── createdAt: timestamp
        └── expenses (subcollection)
            └── [expenseId] (document)
                ├── name: string
                ├── amount: double
                ├── payer: string
                ├── splitAmong: map<string, double>
                └── dateTime: timestamp
```

## 🎯 App Flow

1. **Trip Sign-In** → Create new trip or join with code
2. **Add Participants** → Enter names of all trip members
3. **Summary Dashboard** → View expenses and balances
4. **Add Expense** → Record new expense with split details
5. **View Settlements** → See who owes whom

## 🧩 Key Features Explained

### Balance Calculation Algorithm

The app uses a debt simplification algorithm that:
1. Calculates net balance for each participant (credits - debits)
2. Separates participants into creditors and debtors
3. Matches debtors with creditors to minimize number of transactions
4. Displays simplified "who owes whom" relationships

### Split Options

- **Even Split**: Divide expense equally among selected participants
- **Custom Split**: Manually specify amount for each participant
- Validates that custom splits equal the total expense amount

## 🛠️ Built With

- **Flutter** - UI framework
- **Firebase Core** - Firebase SDK initialization
- **Cloud Firestore** - NoSQL cloud database
- **intl** - Date formatting

## 📝 TODO Before Production

- [ ] Add user authentication (Firebase Auth)
- [ ] Implement proper Firestore security rules
- [ ] Add expense editing functionality
- [ ] Add expense categories and filters
- [ ] Add export to PDF/CSV
- [ ] Add offline support
- [ ] Add push notifications for new expenses
- [ ] Add profile pictures for participants
- [ ] Add currency selection
- [ ] Add receipt photo attachments

## 🐛 Troubleshooting

### Firebase initialization error
- Verify `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is in correct location
- Check that package name/bundle ID matches what you registered in Firebase
- Update `lib/config/firebase_config.dart` with correct credentials

### Build errors
```powershell
flutter clean
flutter pub get
flutter run
```

### Firestore permission denied
- Check your Firestore security rules in Firebase Console
- Ensure rules allow read/write access (for development/testing)

## 📄 License

This project is created as a personal expense tracking app.

## 👤 Author

Built with ❤️ using Flutter and Firebase

---

**Note**: Remember to update your Firebase credentials and security rules before deploying to production!

