import 'package:cloud_firestore/cloud_firestore.dart';

class Campaign {
  final String id;
  final String ownerId;
  final String title;
  final String cause; // Medical, Education, Funeral, Emergency, Community
  final String story;
  final double targetAmount;
  final double raisedAmount;
  final String status; // draft, pending, active, completed, rejected, frozen
  final DateTime createdAt;
  final DateTime? verifiedAt;
  final DateTime endDate;
  final String payoutMethod; // mobile_money, bank
  final String payoutDetails; // MoMo number or bank account
  final List<String> proofUrls;
  final int donationCount;

  Campaign({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.cause,
    required this.story,
    required this.targetAmount,
    this.raisedAmount = 0.0,
    this.status = 'draft',
    required this.createdAt,
    this.verifiedAt,
    required this.endDate,
    this.payoutMethod = 'mobile_money',
    required this.payoutDetails,
    this.proofUrls = const [],
    this.donationCount = 0,
  });

  // Calculate progress percentage
  double get progressPercentage {
    if (targetAmount == 0) return 0;
    return (raisedAmount / targetAmount * 100).clamp(0, 100);
  }

  // Check if goal is reached
  bool get isGoalReached => raisedAmount >= targetAmount;

  // Check if campaign is active
  bool get isActive => status == 'active' && DateTime.now().isBefore(endDate);

  // Check if campaign is expired
  bool get isExpired => DateTime.now().isAfter(endDate);

  // Convert Campaign to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner_id': ownerId,
      'title': title,
      'cause': cause,
      'story': story,
      'target_amount': targetAmount,
      'raised_amount': raisedAmount,
      'status': status,
      'created_at': Timestamp.fromDate(createdAt),
      'verified_at': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'end_date': Timestamp.fromDate(endDate),
      'payout_method': payoutMethod,
      'payout_details': payoutDetails,
      'proof_urls': proofUrls,
      'donation_count': donationCount,
    };
  }

  // Create Campaign from Firestore document
  factory Campaign.fromMap(Map<String, dynamic> map, String documentId) {
    return Campaign(
      id: documentId,
      ownerId: map['owner_id'] ?? '',
      title: map['title'] ?? '',
      cause: map['cause'] ?? '',
      story: map['story'] ?? '',
      targetAmount: (map['target_amount'] ?? 0).toDouble(),
      raisedAmount: (map['raised_amount'] ?? 0).toDouble(),
      status: map['status'] ?? 'draft',
      createdAt: (map['created_at'] as Timestamp).toDate(),
      verifiedAt: map['verified_at'] != null 
          ? (map['verified_at'] as Timestamp).toDate() 
          : null,
      endDate: (map['end_date'] as Timestamp).toDate(),
      payoutMethod: map['payout_method'] ?? 'mobile_money',
      payoutDetails: map['payout_details'] ?? '',
      proofUrls: List<String>.from(map['proof_urls'] ?? []),
      donationCount: map['donation_count'] ?? 0,
    );
  }

  // Create a copy with updated fields
  Campaign copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? cause,
    String? story,
    double? targetAmount,
    double? raisedAmount,
    String? status,
    DateTime? createdAt,
    DateTime? verifiedAt,
    DateTime? endDate,
    String? payoutMethod,
    String? payoutDetails,
    List<String>? proofUrls,
    int? donationCount,
  }) {
    return Campaign(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      cause: cause ?? this.cause,
      story: story ?? this.story,
      targetAmount: targetAmount ?? this.targetAmount,
      raisedAmount: raisedAmount ?? this.raisedAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      endDate: endDate ?? this.endDate,
      payoutMethod: payoutMethod ?? this.payoutMethod,
      payoutDetails: payoutDetails ?? this.payoutDetails,
      proofUrls: proofUrls ?? this.proofUrls,
      donationCount: donationCount ?? this.donationCount,
    );
  }
}
