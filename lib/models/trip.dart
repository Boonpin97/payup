import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  final String id;
  final String tripName;
  final String signInCode;
  final List<String> participants;
  final DateTime createdAt;

  Trip({
    required this.id,
    required this.tripName,
    required this.signInCode,
    required this.participants,
    required this.createdAt,
  });

  // Convert Trip to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'tripName': tripName,
      'signInCode': signInCode,
      'participants': participants,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create Trip from Firebase document
  factory Trip.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Trip(
      id: doc.id,
      tripName: data['tripName'] ?? '',
      signInCode: data['signInCode'] ?? '',
      participants: List<String>.from(data['participants'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Create Trip from Map
  factory Trip.fromMap(Map<String, dynamic> data, String id) {
    return Trip(
      id: id,
      tripName: data['tripName'] ?? '',
      signInCode: data['signInCode'] ?? '',
      participants: List<String>.from(data['participants'] ?? []),
      createdAt: data['createdAt'] is Timestamp 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Trip copyWith({
    String? id,
    String? tripName,
    String? signInCode,
    List<String>? participants,
    DateTime? createdAt,
  }) {
    return Trip(
      id: id ?? this.id,
      tripName: tripName ?? this.tripName,
      signInCode: signInCode ?? this.signInCode,
      participants: participants ?? this.participants,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
