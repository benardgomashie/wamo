import 'package:cloud_firestore/cloud_firestore.dart';

/// Notification types for different events
enum NotificationType {
  // Campaign lifecycle
  campaignSubmitted,
  campaignApproved,
  campaignRejected,
  campaignFrozen,
  campaignEndingSoon,
  
  // Donations
  donationReceived,
  milestoneReached,
  goalReached,
  
  // Payouts
  payoutRequested,
  payoutApproved,
  payoutRejected,
  payoutCompleted,
  payoutFailed,
  
  // Updates
  campaignUpdatePosted,
  creatorMessage,
  
  // System
  verificationRequired,
  systemAnnouncement,
}

class AppNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data; // Additional metadata (campaignId, donationId, etc.)
  final String? actionUrl; // Deep link for navigation

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.isRead = false,
    required this.createdAt,
    this.data,
    this.actionUrl,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map, String documentId) {
    return AppNotification(
      id: documentId,
      userId: map['userId'] ?? '',
      type: _parseType(map['type']),
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      data: map['data'] as Map<String, dynamic>?,
      actionUrl: map['actionUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': _typeToString(type),
      'title': title,
      'body': body,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'data': data,
      'actionUrl': actionUrl,
    };
  }

  static NotificationType _parseType(String? type) {
    switch (type) {
      case 'campaign_submitted':
        return NotificationType.campaignSubmitted;
      case 'campaign_approved':
        return NotificationType.campaignApproved;
      case 'campaign_rejected':
        return NotificationType.campaignRejected;
      case 'campaign_frozen':
        return NotificationType.campaignFrozen;
      case 'campaign_ending_soon':
        return NotificationType.campaignEndingSoon;
      case 'donation_received':
        return NotificationType.donationReceived;
      case 'milestone_reached':
        return NotificationType.milestoneReached;
      case 'goal_reached':
        return NotificationType.goalReached;
      case 'payout_requested':
        return NotificationType.payoutRequested;
      case 'payout_approved':
        return NotificationType.payoutApproved;
      case 'payout_rejected':
        return NotificationType.payoutRejected;
      case 'payout_completed':
        return NotificationType.payoutCompleted;
      case 'payout_failed':
        return NotificationType.payoutFailed;
      case 'campaign_update_posted':
        return NotificationType.campaignUpdatePosted;
      case 'creator_message':
        return NotificationType.creatorMessage;
      case 'verification_required':
        return NotificationType.verificationRequired;
      case 'system_announcement':
        return NotificationType.systemAnnouncement;
      default:
        return NotificationType.systemAnnouncement;
    }
  }

  static String _typeToString(NotificationType type) {
    switch (type) {
      case NotificationType.campaignSubmitted:
        return 'campaign_submitted';
      case NotificationType.campaignApproved:
        return 'campaign_approved';
      case NotificationType.campaignRejected:
        return 'campaign_rejected';
      case NotificationType.campaignFrozen:
        return 'campaign_frozen';
      case NotificationType.campaignEndingSoon:
        return 'campaign_ending_soon';
      case NotificationType.donationReceived:
        return 'donation_received';
      case NotificationType.milestoneReached:
        return 'milestone_reached';
      case NotificationType.goalReached:
        return 'goal_reached';
      case NotificationType.payoutRequested:
        return 'payout_requested';
      case NotificationType.payoutApproved:
        return 'payout_approved';
      case NotificationType.payoutRejected:
        return 'payout_rejected';
      case NotificationType.payoutCompleted:
        return 'payout_completed';
      case NotificationType.payoutFailed:
        return 'payout_failed';
      case NotificationType.campaignUpdatePosted:
        return 'campaign_update_posted';
      case NotificationType.creatorMessage:
        return 'creator_message';
      case NotificationType.verificationRequired:
        return 'verification_required';
      case NotificationType.systemAnnouncement:
        return 'system_announcement';
    }
  }

  /// Returns icon for notification type
  String get iconName {
    switch (type) {
      case NotificationType.campaignApproved:
      case NotificationType.payoutApproved:
        return 'check_circle';
      case NotificationType.campaignRejected:
      case NotificationType.payoutRejected:
      case NotificationType.payoutFailed:
        return 'cancel';
      case NotificationType.donationReceived:
        return 'favorite';
      case NotificationType.milestoneReached:
      case NotificationType.goalReached:
        return 'emoji_events';
      case NotificationType.payoutCompleted:
        return 'account_balance_wallet';
      case NotificationType.campaignUpdatePosted:
        return 'announcement';
      case NotificationType.campaignEndingSoon:
        return 'schedule';
      default:
        return 'notifications';
    }
  }

  AppNotification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? data,
    String? actionUrl,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }
}
