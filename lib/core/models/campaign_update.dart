import 'package:cloud_firestore/cloud_firestore.dart';

class CampaignUpdate {
  final String id;
  final String campaignId;
  final String text;
  final List<String> mediaUrls; // Images or documents
  final DateTime createdAt;
  final bool isPinned;

  CampaignUpdate({
    required this.id,
    required this.campaignId,
    required this.text,
    this.mediaUrls = const [],
    required this.createdAt,
    this.isPinned = false,
  });

  // Convert CampaignUpdate to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'campaign_id': campaignId,
      'text': text,
      'media_urls': mediaUrls,
      'created_at': Timestamp.fromDate(createdAt),
      'is_pinned': isPinned,
    };
  }

  // Create CampaignUpdate from Firestore document
  factory CampaignUpdate.fromMap(Map<String, dynamic> map, String documentId) {
    return CampaignUpdate(
      id: documentId,
      campaignId: map['campaign_id'] ?? '',
      text: map['text'] ?? '',
      mediaUrls: List<String>.from(map['media_urls'] ?? []),
      createdAt: (map['created_at'] as Timestamp).toDate(),
      isPinned: map['is_pinned'] ?? false,
    );
  }

  // Create a copy with updated fields
  CampaignUpdate copyWith({
    String? id,
    String? campaignId,
    String? text,
    List<String>? mediaUrls,
    DateTime? createdAt,
    bool? isPinned,
  }) {
    return CampaignUpdate(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      text: text ?? this.text,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      createdAt: createdAt ?? this.createdAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
