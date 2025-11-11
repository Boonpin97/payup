import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../config/firebase_config.dart';
import '../models/trip.dart';
import '../models/expense.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseFirestore? _firestore;
  
  FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception('Firebase not initialized. Call initializeFirebase() first.');
    }
    return _firestore!;
  }

  // Initialize Firebase
  Future<void> initializeFirebase() async {
    try {
      print('🔄 Starting Firebase initialization...');
      // TODO: Replace with your actual Firebase configuration
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: FIREBASE_API_KEY,
          appId: FIREBASE_APP_ID,
          messagingSenderId: FIREBASE_MESSAGING_SENDER_ID,
          projectId: FIREBASE_PROJECT_ID,
          authDomain: FIREBASE_AUTH_DOMAIN,
          storageBucket: FIREBASE_STORAGE_BUCKET,
        ),
      );
      _firestore = FirebaseFirestore.instance;
      print('✅ Firebase initialized successfully');
      print('✅ Firestore instance created: ${_firestore != null}');
    } catch (e) {
      print('❌ Error initializing Firebase: $e');
      rethrow;
    }
  }

  // Generate a unique 6-digit sign-in code
  String _generateSignInCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // Create a new trip
  Future<Trip> createTrip(String tripName) async {
    try {
      final signInCode = _generateSignInCode();
      final tripData = {
        'tripName': tripName,
        'signInCode': signInCode,
        'participants': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await firestore.collection(TRIPS_COLLECTION).add(tripData);
      
      // Fetch the created document to get the server timestamp
      final doc = await docRef.get();
      return Trip.fromFirestore(doc);
    } catch (e) {
      print('Error creating trip: $e');
      rethrow;
    }
  }

  // Join an existing trip by sign-in code
  Future<Trip?> joinTrip(String signInCode) async {
    try {
      final querySnapshot = await firestore
          .collection(TRIPS_COLLECTION)
          .where('signInCode', isEqualTo: signInCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return Trip.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      print('Error joining trip: $e');
      rethrow;
    }
  }

  // Get trip by ID
  Future<Trip?> getTrip(String tripId) async {
    try {
      final doc = await firestore.collection(TRIPS_COLLECTION).doc(tripId).get();
      
      if (!doc.exists) {
        return null;
      }

      return Trip.fromFirestore(doc);
    } catch (e) {
      print('Error getting trip: $e');
      rethrow;
    }
  }

  // Add participants to a trip
  Future<void> addParticipants(String tripId, List<String> participants) async {
    try {
      await firestore.collection(TRIPS_COLLECTION).doc(tripId).update({
        'participants': participants,
      });
    } catch (e) {
      print('Error adding participants: $e');
      rethrow;
    }
  }

  // Update trip participants
  Future<void> updateParticipants(String tripId, List<String> participants) async {
    try {
      await firestore.collection(TRIPS_COLLECTION).doc(tripId).update({
        'participants': participants,
      });
    } catch (e) {
      print('Error updating participants: $e');
      rethrow;
    }
  }

  // Add an expense to a trip
  Future<Expense> addExpense({
    required String tripId,
    required String name,
    required double amount,
    required String payer,
    required Map<String, double> splitAmong,
    DateTime? dateTime,
  }) async {
    try {
      final expenseData = {
        'name': name,
        'amount': amount,
        'payer': payer,
        'splitAmong': splitAmong,
        'dateTime': dateTime != null 
            ? Timestamp.fromDate(dateTime)
            : FieldValue.serverTimestamp(),
      };

      final docRef = await firestore
          .collection(TRIPS_COLLECTION)
          .doc(tripId)
          .collection(EXPENSES_COLLECTION)
          .add(expenseData);

      // Fetch the created document
      final doc = await docRef.get();
      return Expense.fromFirestore(doc);
    } catch (e) {
      print('Error adding expense: $e');
      rethrow;
    }
  }

  // Fetch all expenses for a trip
  Future<List<Expense>> fetchExpenses(String tripId) async {
    try {
      final querySnapshot = await firestore
          .collection(TRIPS_COLLECTION)
          .doc(tripId)
          .collection(EXPENSES_COLLECTION)
          .orderBy('dateTime', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Expense.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching expenses: $e');
      rethrow;
    }
  }

  // Stream expenses (real-time updates)
  Stream<List<Expense>> streamExpenses(String tripId) {
    return firestore
        .collection(TRIPS_COLLECTION)
        .doc(tripId)
        .collection(EXPENSES_COLLECTION)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense.fromFirestore(doc))
            .toList());
  }

  // Calculate balances - who owes whom
  Map<String, Map<String, double>> calculateBalances(List<Expense> expenses, List<String> participants) {
    // Initialize balance map: participant -> (otherParticipant -> amount)
    Map<String, double> netBalance = {};
    
    // Initialize all participants with 0 balance
    for (var participant in participants) {
      netBalance[participant] = 0.0;
    }

    // Calculate net balance for each participant
    for (var expense in expenses) {
      // Payer gets credited
      netBalance[expense.payer] = (netBalance[expense.payer] ?? 0.0) + expense.amount;

      // Each person in splitAmong gets debited
      expense.splitAmong.forEach((person, amount) {
        netBalance[person] = (netBalance[person] ?? 0.0) - amount;
      });
    }

    // Simplify debts using creditors and debtors
    List<MapEntry<String, double>> creditors = [];
    List<MapEntry<String, double>> debtors = [];

    netBalance.forEach((person, balance) {
      if (balance > 0.01) {
        creditors.add(MapEntry(person, balance));
      } else if (balance < -0.01) {
        debtors.add(MapEntry(person, -balance));
      }
    });

    // Create settlement map
    Map<String, Map<String, double>> settlements = {};
    for (var participant in participants) {
      settlements[participant] = {};
    }

    // Match debtors with creditors
    int i = 0, j = 0;
    while (i < debtors.length && j < creditors.length) {
      String debtor = debtors[i].key;
      String creditor = creditors[j].key;
      double debtAmount = debtors[i].value;
      double creditAmount = creditors[j].value;

      double settleAmount = debtAmount < creditAmount ? debtAmount : creditAmount;

      // Debtor owes creditor
      if (settlements[debtor] == null) {
        settlements[debtor] = {};
      }
      settlements[debtor]![creditor] = settleAmount;

      debtors[i] = MapEntry(debtor, debtAmount - settleAmount);
      creditors[j] = MapEntry(creditor, creditAmount - settleAmount);

      if (debtors[i].value < 0.01) i++;
      if (creditors[j].value < 0.01) j++;
    }

    return settlements;
  }

  // Delete an expense
  Future<void> deleteExpense(String tripId, String expenseId) async {
    try {
      await firestore
          .collection(TRIPS_COLLECTION)
          .doc(tripId)
          .collection(EXPENSES_COLLECTION)
          .doc(expenseId)
          .delete();
    } catch (e) {
      print('Error deleting expense: $e');
      rethrow;
    }
  }

  // Update an expense
  Future<void> updateExpense({
    required String tripId,
    required String expenseId,
    required String name,
    required double amount,
    required String payer,
    required Map<String, double> splitAmong,
    DateTime? dateTime,
  }) async {
    try {
      await firestore
          .collection(TRIPS_COLLECTION)
          .doc(tripId)
          .collection(EXPENSES_COLLECTION)
          .doc(expenseId)
          .update({
        'name': name,
        'amount': amount,
        'payer': payer,
        'splitAmong': splitAmong,
        if (dateTime != null) 'dateTime': Timestamp.fromDate(dateTime),
      });
    } catch (e) {
      print('Error updating expense: $e');
      rethrow;
    }
  }
}
