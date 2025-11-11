# PayUp - Feature Implementation Checklist

## 📋 Project Overview
A Flutter mobile app for tracking shared expenses during trips, similar to Splitwise or SettleUp.
Uses Firebase Firestore as the backend database.

---

## ✅ Implementation Status

### 🏗️ Project Structure
- [x] Create `models/` folder with data models
- [x] Create `screens/` folder for UI pages
- [x] Create `services/` folder for Firebase integration
- [x] Create `widgets/` folder for reusable components
- [x] Update `pubspec.yaml` with required dependencies

### 📦 Models (models/)
- [x] `trip.dart` - Trip model with tripName, signInCode, participants
- [x] `expense.dart` - Expense model with name, amount, payer, splitAmong, dateTime

### 🔥 Firebase Service (services/)
- [x] `firebase_service.dart` - Main service class
  - [x] `initializeFirebase()` - Initialize Firebase with placeholder config
  - [x] `createTrip()` - Create new trip document
  - [x] `joinTrip()` - Find and join existing trip by code
  - [x] `addParticipants()` - Update participants array
  - [x] `addExpense()` - Add expense to trip subcollection
  - [x] `fetchExpenses()` - Retrieve all expenses for a trip
  - [x] `calculateBalances()` - Compute who owes whom
  - [x] `deleteExpense()` - Delete an expense
  - [x] `updateExpense()` - Update an expense
  - [x] `streamExpenses()` - Real-time expense updates

### 🖥️ Screens (screens/)
- [x] `trip_signin_screen.dart` - Create or join trip
  - [x] Create new trip form
  - [x] Join existing trip by code
  - [x] Navigate to participants setup
  - [x] Display sign-in code dialog
- [x] `participants_screen.dart` - Add/manage participants
  - [x] Input number of participants (1-20)
  - [x] Enter participant names
  - [x] Validation (no duplicates, required fields)
  - [x] Save to Firebase
- [x] `summary_screen.dart` - Trip dashboard
  - [x] Display list of expenses
  - [x] Show balance calculations
  - [x] "Add Expense" button
  - [x] Settlement suggestions (who owes whom)
  - [x] Total expenses summary
  - [x] Refresh functionality
  - [x] Trip info dialog
  - [x] Delete expense functionality
- [x] `add_expense_screen.dart` - Add new expense
  - [x] Expense name field
  - [x] Amount field with validation
  - [x] Payer dropdown (from participants)
  - [x] Date/time picker (default: now)
  - [x] Split options (even/custom)
  - [x] Participant checkboxes for split
  - [x] Custom amount per participant
  - [x] Auto-fill button for even distribution
  - [x] Split validation
  - [x] Submit to Firebase

### 🧩 Reusable Widgets (widgets/)
- [x] `custom_button.dart` - Styled button component with loading state
- [x] `custom_text_field.dart` - Input field component with validation
- [x] `expense_card.dart` - Display single expense with details
- [x] `balance_card.dart` - Display balance summary between two people

### 🎨 App Configuration
- [x] `main.dart` - App entry point with routing
- [x] `config/firebase_config.dart` - Firebase constants (placeholder)
- [x] Navigation setup (MaterialApp routes)
- [x] Theme configuration (Material Design)
- [x] Firebase initialization in main

---

## 🗄️ Firebase Schema

```
trips (collection)
  ├─ tripId (auto-generated document ID)
      ├─ tripName: string
      ├─ signInCode: string (unique 6-digit code)
      ├─ participants: array<string>
      ├─ createdAt: timestamp
      └─ expenses (subcollection)
           ├─ expenseId (auto-generated)
                ├─ name: string
                ├─ amount: double
                ├─ payer: string
                ├─ splitAmong: map<string, double>
                └─ dateTime: timestamp
```

---

## 🔧 Configuration TODOs

### Before Running:
1. [ ] Create Firebase project at https://console.firebase.google.com
2. [ ] Enable Firestore Database
3. [ ] Add your app (Android/iOS) to Firebase project
4. [ ] Download and add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
5. [ ] Update `config/firebase_config.dart` with your Firebase credentials
6. [ ] Run `flutter pub get` to install dependencies

### Firebase Rules to Set:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /trips/{tripId} {
      allow read, write: if true; // TODO: Add proper auth rules
      match /expenses/{expenseId} {
        allow read, write: if true;
      }
    }
  }
}
```

---

## 📱 App Flow

```
1. Trip Sign-In Screen
   ├─ Create New Trip → Enter trip name → Generate code
   └─ Join Existing Trip → Enter code → Verify and join
           ↓
2. Participants Screen
   └─ Add participant names → Save to Firebase
           ↓
3. Summary Screen (Main Dashboard)
   ├─ View all expenses
   ├─ See balance calculations
   └─ Button: "Add Expense"
           ↓
4. Add Expense Screen
   └─ Enter expense details → Choose split → Save to Firebase
           ↓
   Return to Summary Screen
```

---

## 🚀 Future Enhancements (Optional)

- [ ] User authentication (Firebase Auth)
- [ ] Push notifications for new expenses
- [ ] Expense categories and filters
- [ ] Currency conversion
- [ ] Export to PDF/Excel
- [ ] Group chat functionality
- [ ] Payment integration (PayPal, Venmo links)
- [ ] Photo attachments for receipts
- [ ] Edit/delete expenses
- [ ] Trip history and archives

---

## 📝 Notes

- All Firebase operations use placeholder URL and token initially
- State management kept simple with setState/Provider
- UI uses Material Design components
- Balance calculation uses simplified debt algorithm
- All amounts in app currency (configure later)

---

**Last Updated:** November 11, 2025
**Version:** 1.0.0
