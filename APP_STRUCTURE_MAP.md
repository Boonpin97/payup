# 🗺️ App Navigation & Structure Map

Visual guide to understand the app flow and file organization.

---

## 📱 Screen Flow Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    App Starts                            │
│                   (main.dart)                            │
│           Firebase Initialization                        │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│          Trip Sign-In Screen                             │
│      (trip_signin_screen.dart)                           │
│                                                           │
│  ┌─────────────┐          ┌─────────────┐               │
│  │ Create Trip │          │  Join Trip  │               │
│  │             │          │             │               │
│  │ • Name      │          │ • Code      │               │
│  │ • Auto code │          │ • Validate  │               │
│  └──────┬──────┘          └──────┬──────┘               │
│         └───────────┬────────────┘                       │
└─────────────────────┼────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│         Participants Screen                              │
│      (participants_screen.dart)                          │
│                                                           │
│  • Adjust count (1-20)                                   │
│  • Enter names                                           │
│  • Validate (no duplicates)                              │
│  • Save to Firebase                                      │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│          Summary Screen (Main Dashboard)                 │
│         (summary_screen.dart)                            │
│                                                           │
│  ┌─────────────────────────────────────────┐            │
│  │  Total: $XXX.XX                          │            │
│  │  X expenses                              │            │
│  └─────────────────────────────────────────┘            │
│                                                           │
│  Settlements:                                            │
│  ┌─────────────────────────────────────────┐            │
│  │  Alice owes Bob $10.00                   │            │
│  │  Carol owes Bob $5.00                    │            │
│  └─────────────────────────────────────────┘            │
│                                                           │
│  Expenses:                                               │
│  ┌─────────────────────────────────────────┐            │
│  │  🍽️ Dinner - $30.00                      │            │
│  │  Paid by Bob • Split 3 ways              │            │
│  └─────────────────────────────────────────┘            │
│                                                           │
│  ┌─────────────────────────────────────────┐            │
│  │  [+] Add Expense                         │            │
│  └────────────────┬────────────────────────┘            │
└────────────────────┼────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│         Add Expense Screen                               │
│      (add_expense_screen.dart)                           │
│                                                           │
│  • Name: _____________                                   │
│  • Amount: $ _________                                   │
│  • Paid by: [Dropdown]                                   │
│  • Date/Time: [Picker]                                   │
│                                                           │
│  Split Mode: [Even] [Custom]                             │
│                                                           │
│  If Even:                                                │
│  ☑ Alice                                                 │
│  ☑ Bob                                                   │
│  ☑ Carol                                                 │
│                                                           │
│  If Custom:                                              │
│  Alice:  $ ______                                        │
│  Bob:    $ ______                                        │
│  Carol:  $ ______                                        │
│                                                           │
│  [Save Expense] ────────► Back to Summary               │
└─────────────────────────────────────────────────────────┘
```

---

## 📂 File Structure with Responsibilities

```
lib/
│
├── main.dart                           🚀 Entry Point
│   ├── Initialize Firebase
│   ├── Define app theme
│   ├── Set up navigation
│   └── Launch first screen
│
├── config/
│   └── firebase_config.dart            ⚙️ Configuration
│       ├── Firebase API keys
│       ├── Project IDs
│       └── Collection names
│
├── models/                             📦 Data Models
│   │
│   ├── trip.dart
│   │   ├── Trip class definition
│   │   ├── Properties: id, name, code, participants, date
│   │   ├── toMap() - Convert to Firestore
│   │   ├── fromFirestore() - Parse from Firestore
│   │   └── copyWith() - Create modified copy
│   │
│   └── expense.dart
│       ├── Expense class definition
│       ├── Properties: id, name, amount, payer, split, date
│       ├── toMap() - Convert to Firestore
│       ├── fromFirestore() - Parse from Firestore
│       └── copyWith() - Create modified copy
│
├── services/                           🔧 Business Logic
│   │
│   └── firebase_service.dart
│       ├── Singleton instance
│       ├── initializeFirebase() - Setup Firebase
│       │
│       ├── Trip Operations:
│       │   ├── createTrip() - New trip
│       │   ├── joinTrip() - Find by code
│       │   ├── getTrip() - Fetch details
│       │   ├── addParticipants() - Set participants
│       │   └── updateParticipants() - Modify list
│       │
│       ├── Expense Operations:
│       │   ├── addExpense() - Create expense
│       │   ├── fetchExpenses() - Get all
│       │   ├── streamExpenses() - Real-time
│       │   ├── deleteExpense() - Remove
│       │   └── updateExpense() - Modify
│       │
│       └── Calculation:
│           └── calculateBalances() - Debt simplification
│
├── screens/                            🖥️ UI Screens
│   │
│   ├── trip_signin_screen.dart
│   │   ├── Create/Join toggle
│   │   ├── Form validation
│   │   ├── Firebase calls
│   │   ├── Success dialog
│   │   └── Navigate to participants
│   │
│   ├── participants_screen.dart
│   │   ├── Dynamic participant count
│   │   ├── Name input fields
│   │   ├── Duplicate validation
│   │   ├── Firebase save
│   │   └── Navigate to summary
│   │
│   ├── summary_screen.dart
│   │   ├── Total expenses header
│   │   ├── Balance calculations display
│   │   ├── Expense list
│   │   ├── Pull-to-refresh
│   │   ├── Delete expense
│   │   ├── Trip info dialog
│   │   └── Navigate to add expense
│   │
│   └── add_expense_screen.dart
│       ├── Expense form
│       ├── Date/time picker
│       ├── Split mode toggle
│       ├── Even split checkboxes
│       ├── Custom split inputs
│       ├── Validation
│       ├── Firebase save
│       └── Navigate back
│
└── widgets/                            🧩 Reusable Components
    │
    ├── custom_button.dart
    │   ├── Standard button styling
    │   ├── Loading state
    │   ├── Outlined variant
    │   └── Icon support
    │
    ├── custom_text_field.dart
    │   ├── Labeled input field
    │   ├── Validation support
    │   ├── Prefix/suffix icons
    │   └── Formatting options
    │
    ├── expense_card.dart
    │   ├── Expense name & amount
    │   ├── Payer info
    │   ├── Split details
    │   ├── Date/time display
    │   └── Delete button
    │
    └── balance_card.dart
        ├── Avatar with initial
        ├── "X owes Y" text
        └── Amount display
```

---

## 🔄 Data Flow Diagram

```
User Action → Screen Widget → Firebase Service → Firestore

Example: Adding an Expense

┌──────────────────┐
│   User fills      │
│   expense form    │
└────────┬──────────┘
         │
         ▼
┌──────────────────────────────┐
│  add_expense_screen.dart      │
│  • Validates input            │
│  • Calculates split           │
│  • Calls service method       │
└────────┬──────────────────────┘
         │
         ▼
┌──────────────────────────────┐
│  firebase_service.dart        │
│  • addExpense(...)            │
│  • Converts to Map            │
│  • Calls Firestore API        │
└────────┬──────────────────────┘
         │
         ▼
┌──────────────────────────────┐
│  Cloud Firestore              │
│  trips/{id}/expenses/{id}     │
│  • Stores document            │
│  • Returns ID                 │
└────────┬──────────────────────┘
         │
         ▼
┌──────────────────────────────┐
│  summary_screen.dart          │
│  • Fetches updated expenses   │
│  • Recalculates balances      │
│  • Displays new expense       │
└───────────────────────────────┘
```

---

## 🎨 Widget Hierarchy

```
MaterialApp (main.dart)
│
└── TripSignInScreen
    │
    ├── CustomTextField (trip name)
    ├── CustomTextField (sign-in code)
    └── CustomButton (create/join)
        │
        └── ParticipantsScreen
            │
            ├── CustomTextField (participant 1)
            ├── CustomTextField (participant 2)
            ├── CustomTextField (participant 3)
            └── CustomButton (continue)
                │
                └── SummaryScreen
                    │
                    ├── Total Card (gradient)
                    ├── BalanceCard (Alice → Bob)
                    ├── BalanceCard (Carol → Bob)
                    ├── ExpenseCard (Dinner)
                    ├── ExpenseCard (Gas)
                    └── FloatingActionButton
                        │
                        └── AddExpenseScreen
                            │
                            ├── CustomTextField (name)
                            ├── CustomTextField (amount)
                            ├── DropdownButton (payer)
                            ├── DateTimePicker
                            ├── CheckboxListTile (Alice)
                            ├── CheckboxListTile (Bob)
                            ├── CheckboxListTile (Carol)
                            └── CustomButton (save)
```

---

## 🗃️ Firestore Data Structure

```
Firestore
│
└── 📁 trips/
    │
    ├── 📄 abc123xyz (Trip Document)
    │   ├── tripName: "Beach Weekend"
    │   ├── signInCode: "123456"
    │   ├── participants: ["Alice", "Bob", "Carol"]
    │   ├── createdAt: 2024-11-11T10:30:00Z
    │   │
    │   └── 📁 expenses/
    │       │
    │       ├── 📄 exp001 (Expense Document)
    │       │   ├── name: "Dinner"
    │       │   ├── amount: 30.00
    │       │   ├── payer: "Alice"
    │       │   ├── splitAmong: {
    │       │   │     "Alice": 10.00,
    │       │   │     "Bob": 10.00,
    │       │   │     "Carol": 10.00
    │       │   │   }
    │       │   └── dateTime: 2024-11-11T19:00:00Z
    │       │
    │       └── 📄 exp002 (Expense Document)
    │           ├── name: "Gas"
    │           ├── amount: 45.00
    │           ├── payer: "Bob"
    │           ├── splitAmong: {
    │           │     "Alice": 15.00,
    │           │     "Bob": 15.00,
    │           │     "Carol": 15.00
    │           │   }
    │           └── dateTime: 2024-11-11T12:00:00Z
    │
    └── 📄 def456uvw (Another Trip)
        └── ...
```

---

## 🧮 Balance Calculation Algorithm

```
Input: Expenses list + Participants

Step 1: Calculate Net Balance
┌─────────┬──────────┬─────────┬────────────┐
│ Person  │ Paid     │ Owes    │ Net        │
├─────────┼──────────┼─────────┼────────────┤
│ Alice   │ $30.00   │ $25.00  │ +$5.00     │
│ Bob     │ $45.00   │ $25.00  │ +$20.00    │
│ Carol   │ $0.00    │ $25.00  │ -$25.00    │
└─────────┴──────────┴─────────┴────────────┘

Step 2: Separate Creditors and Debtors
Creditors (owed money):
  • Alice: +$5.00
  • Bob: +$20.00

Debtors (owes money):
  • Carol: -$25.00

Step 3: Match Debtors with Creditors
Carol owes $25.00 total
  → Pay Bob $20.00 (Bob's balance → $0)
  → Pay Alice $5.00 (Alice's balance → $0)

Step 4: Output Settlements
  • Carol owes Bob $20.00
  • Carol owes Alice $5.00
```

---

## 🎯 Key Interactions Map

```
User Action              →  What Happens

"Create Trip"            →  Generate code
                         →  Save to Firestore
                         →  Show code dialog
                         →  Navigate to participants

"Add Participant"        →  Validate name
                         →  No duplicates
                         →  Update local list

"Save Participants"      →  Update Firestore
                         →  Navigate to summary

"Add Expense"            →  Open form
                         →  Select payer
                         →  Choose split
                         →  Calculate amounts

"Even Split"             →  Amount ÷ Checked participants
                         →  Auto-calculate shares

"Custom Split"           →  Manual amount per person
                         →  Validate total = expense

"Save Expense"           →  Validate form
                         →  Save to Firestore
                         →  Refresh summary
                         →  Update balances

"Delete Expense"         →  Show confirmation
                         →  Delete from Firestore
                         →  Refresh summary
                         →  Recalculate balances

"Pull to Refresh"        →  Fetch latest expenses
                         →  Update UI

"View Trip Info"         →  Show dialog
                         →  Display code + participants
```

---

## 🔑 Important File Connections

```
File that needs it      ← Imports from

trip_signin_screen      ← firebase_service
                        ← custom_button
                        ← custom_text_field
                        ← participants_screen
                        ← Trip model

participants_screen     ← firebase_service
                        ← custom_button
                        ← custom_text_field
                        ← summary_screen
                        ← Trip model

summary_screen          ← firebase_service
                        ← expense_card
                        ← balance_card
                        ← custom_button
                        ← add_expense_screen
                        ← Trip & Expense models

add_expense_screen      ← firebase_service
                        ← custom_button
                        ← custom_text_field
                        ← Trip model

firebase_service        ← firebase_core
                        ← cloud_firestore
                        ← firebase_config
                        ← Trip & Expense models

All screens/widgets     ← flutter/material.dart
```

---

This map should help you understand how everything fits together! 🗺️
