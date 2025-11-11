import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String name;
  final double amount;
  final String payer;
  final Map<String, double> splitAmong; // participant name -> amount they owe
  final DateTime dateTime;

  Expense({
    required this.id,
    required this.name,
    required this.amount,
    required this.payer,
    required this.splitAmong,
    required this.dateTime,
  });

  // Convert Expense to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'payer': payer,
      'splitAmong': splitAmong,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }

  // Create Expense from Firebase document
  factory Expense.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      name: data['name'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      payer: data['payer'] ?? '',
      splitAmong: Map<String, double>.from(data['splitAmong'] ?? {}),
      dateTime: (data['dateTime'] as Timestamp).toDate(),
    );
  }

  // Create Expense from Map
  factory Expense.fromMap(Map<String, dynamic> data, String id) {
    return Expense(
      id: id,
      name: data['name'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      payer: data['payer'] ?? '',
      splitAmong: Map<String, double>.from(data['splitAmong'] ?? {}),
      dateTime: data['dateTime'] is Timestamp
          ? (data['dateTime'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Expense copyWith({
    String? id,
    String? name,
    double? amount,
    String? payer,
    Map<String, double>? splitAmong,
    DateTime? dateTime,
  }) {
    return Expense(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      payer: payer ?? this.payer,
      splitAmong: splitAmong ?? this.splitAmong,
      dateTime: dateTime ?? this.dateTime,
    );
  }
}
