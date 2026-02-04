import 'package:cloud_firestore/cloud_firestore.dart';

class Donation {
  final String id;
  final String campaignId;
  final String? donorName;
  final String? donorContact; // Email or phone
  final double amount; // Actual donation amount (what creator receives)
  final double totalPaid; // Total amount paid by donor (donation + fees)
  final double platformFee; // 4% platform fee
  final double paystackFee; // Payment processing fee
  final String paymentMethod; // mobile_money, card
  final String status; // pending, successful, failed
  final DateTime createdAt;
  final String reference; // Paystack transaction reference
  final bool isAnonymous;
  final String? message; // Optional message from donor

  Donation({
    required this.id,
    required this.campaignId,
    this.donorName,
    this.donorContact,
    required this.amount,
    required this.totalPaid,
    required this.platformFee,
    required this.paystackFee,
    required this.paymentMethod,
    this.status = 'pending',
    required this.createdAt,
    required this.reference,
    this.isAnonymous = false,
    this.message,
  });

  // Calculate total fees
  double get totalFees => platformFee + paystackFee;

  // Convert Donation to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'campaign_id': campaignId,
      'donor_name': donorName,
      'donor_contact': donorContact,
      'amount': amount,
      'total_paid': totalPaid,
      'platform_fee': platformFee,
      'paystack_fee': paystackFee,
      'payment_method': paymentMethod,
      'status': status,
      'created_at': Timestamp.fromDate(createdAt),
      'reference': reference,
      'is_anonymous': isAnonymous,
      'message': message,
    };
  }

  // Create Donation from Firestore document
  factory Donation.fromMap(Map<String, dynamic> map, String documentId) {
    return Donation(
      id: documentId,
      campaignId: map['campaign_id'] ?? '',
      donorName: map['donor_name'],
      donorContact: map['donor_contact'],
      amount: (map['amount'] ?? 0).toDouble(),
      totalPaid: (map['total_paid'] ?? 0).toDouble(),
      platformFee: (map['platform_fee'] ?? 0).toDouble(),
      paystackFee: (map['paystack_fee'] ?? 0).toDouble(),
      paymentMethod: map['payment_method'] ?? 'mobile_money',
      status: map['status'] ?? 'pending',
      createdAt: (map['created_at'] as Timestamp).toDate(),
      reference: map['reference'] ?? '',
      isAnonymous: map['is_anonymous'] ?? false,
      message: map['message'],
    );
  }

  // Create a copy with updated fields
  Donation copyWith({
    String? id,
    String? campaignId,
    String? donorName,
    String? donorContact,
    double? amount,
    double? totalPaid,
    double? platformFee,
    double? paystackFee,
    String? paymentMethod,
    String? status,
    DateTime? createdAt,
    String? reference,
    bool? isAnonymous,
    String? message,
  }) {
    return Donation(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      donorName: donorName ?? this.donorName,
      donorContact: donorContact ?? this.donorContact,
      amount: amount ?? this.amount,
      totalPaid: totalPaid ?? this.totalPaid,
      platformFee: platformFee ?? this.platformFee,
      paystackFee: paystackFee ?? this.paystackFee,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      reference: reference ?? this.reference,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      message: message ?? this.message,
    );
  }
}
