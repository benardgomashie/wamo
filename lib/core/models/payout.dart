import 'package:cloud_firestore/cloud_firestore.dart';

class Payout {
  final String id;
  final String campaignId;
  final String creatorId;
  final double amount;
  final double platformFeeDeducted;
  final String status; // funds_available, pending_review, approved, processing, completed, failed, on_hold
  final String? recipientMomoNumber;
  final String? recipientMomoNetwork; // MTN, Vodafone, AirtelTigo
  final String? paystackTransferCode;
  final String? paystackRecipientCode;
  final String? failureReason;
  final String? adminNotes;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime requestedAt;
  final DateTime? initiatedAt;
  final DateTime? completedAt;
  final String? transactionReference; // From Paystack
  final int retryCount;

  Payout({
    required this.id,
    required this.campaignId,
    required this.creatorId,
    required this.amount,
    required this.platformFeeDeducted,
    this.status = 'funds_available',
    this.recipientMomoNumber,
    this.recipientMomoNetwork,
    this.paystackTransferCode,
    this.paystackRecipientCode,
    this.failureReason,
    this.adminNotes,
    this.approvedBy,
    this.approvedAt,
    required this.requestedAt,
    this.initiatedAt,
    this.completedAt,
    this.transactionReference,
    this.retryCount = 0,
  });

  // Check if payout is completed
  bool get isCompleted => status == 'completed';

  // Check if payout is pending
  bool get isPending => status == 'pending_review' || status == 'approved' || status == 'processing';

  // Check if payout failed
  bool get isFailed => status == 'failed';

  // Convert Payout to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'campaignId': campaignId,
      'creatorId': creatorId,
      'amount': amount,
      'platformFeeDeducted': platformFeeDeducted,
      'status': status,
      'recipientMomoNumber': recipientMomoNumber,
      'recipientMomoNetwork': recipientMomoNetwork,
      'paystackTransferCode': paystackTransferCode,
      'paystackRecipientCode': paystackRecipientCode,
      'failureReason': failureReason,
      'adminNotes': adminNotes,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'initiatedAt': initiatedAt != null ? Timestamp.fromDate(initiatedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'transactionReference': transactionReference,
      'retryCount': retryCount,
    };
  }

  // Create Payout from Firestore document
  factory Payout.fromMap(Map<String, dynamic> map, String documentId) {
    return Payout(
      id: documentId,
      campaignId: map['campaignId'] ?? '',
      creatorId: map['creatorId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      platformFeeDeducted: (map['platformFeeDeducted'] ?? 0).toDouble(),
      status: map['status'] ?? 'funds_available',
      recipientMomoNumber: map['recipientMomoNumber'],
      recipientMomoNetwork: map['recipientMomoNetwork'],
      paystackTransferCode: map['paystackTransferCode'],
      paystackRecipientCode: map['paystackRecipientCode'],
      failureReason: map['failureReason'],
      adminNotes: map['adminNotes'],
      approvedBy: map['approvedBy'],
      approvedAt: map['approvedAt'] != null 
          ? (map['approvedAt'] as Timestamp).toDate() 
          : null,
      requestedAt: (map['requestedAt'] as Timestamp).toDate(),
      initiatedAt: map['initiatedAt'] != null 
          ? (map['initiatedAt'] as Timestamp).toDate() 
          : null,
      completedAt: map['completedAt'] != null 
          ? (map['completedAt'] as Timestamp).toDate() 
          : null,
      transactionReference: map['transactionReference'],
      retryCount: map['retryCount'] ?? 0,
    );
  }

  // Create a copy with updated fields
  Payout copyWith({
    String? id,
    String? campaignId,
    String? creatorId,
    double? amount,
    double? platformFeeDeducted,
    String? status,
    String? recipientMomoNumber,
    String? recipientMomoNetwork,
    String? paystackTransferCode,
    String? paystackRecipientCode,
    String? failureReason,
    String? adminNotes,
    String? approvedBy,
    DateTime? approvedAt,
    DateTime? requestedAt,
    DateTime? initiatedAt,
    DateTime? completedAt,
    String? transactionReference,
    int? retryCount,
  }) {
    return Payout(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      creatorId: creatorId ?? this.creatorId,
      amount: amount ?? this.amount,
      platformFeeDeducted: platformFeeDeducted ?? this.platformFeeDeducted,
      status: status ?? this.status,
      recipientMomoNumber: recipientMomoNumber ?? this.recipientMomoNumber,
      recipientMomoNetwork: recipientMomoNetwork ?? this.recipientMomoNetwork,
      paystackTransferCode: paystackTransferCode ?? this.paystackTransferCode,
      paystackRecipientCode: paystackRecipientCode ?? this.paystackRecipientCode,
      failureReason: failureReason ?? this.failureReason,
      adminNotes: adminNotes ?? this.adminNotes,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      requestedAt: requestedAt ?? this.requestedAt,
      initiatedAt: initiatedAt ?? this.initiatedAt,
      completedAt: completedAt ?? this.completedAt,
      transactionReference: transactionReference ?? this.transactionReference,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  // Get human-readable status message
  String get statusMessage {
    switch (status) {
      case 'funds_available':
        return 'Funds available for payout';
      case 'pending_review':
        return 'Under admin review';
      case 'approved':
        return 'Approved, transfer pending';
      case 'processing':
        return 'Transfer in progress';
      case 'completed':
        return 'Transfer completed';
      case 'failed':
        return failureReason ?? 'Transfer failed';
      case 'on_hold':
        return 'Payout on hold';
      default:
        return status;
    }
  }

  // Check if payout can be retried
  bool get canRetry => status == 'failed' && retryCount < 3;

  // Check if payout is in terminal state
  bool get isTerminal => status == 'completed' || status == 'on_hold';
}
