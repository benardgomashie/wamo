import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String role; // creator, donor, admin
  final String verificationStatus; // pending, verified, rejected
  final DateTime createdAt;
  final String? fcmToken; // For push notifications

  User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    this.verificationStatus = 'pending',
    required this.createdAt,
    this.fcmToken,
  });

  // Convert User to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'verification_status': verificationStatus,
      'created_at': Timestamp.fromDate(createdAt),
      'fcm_token': fcmToken,
    };
  }

  // Create User from Firestore document
  factory User.fromMap(Map<String, dynamic> map, String documentId) {
    return User(
      id: documentId,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      role: map['role'] ?? 'creator',
      verificationStatus: map['verification_status'] ?? 'pending',
      createdAt: (map['created_at'] as Timestamp).toDate(),
      fcmToken: map['fcm_token'],
    );
  }

  // Create a copy with updated fields
  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? role,
    String? verificationStatus,
    DateTime? createdAt,
    String? fcmToken,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
