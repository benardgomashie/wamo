import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/campaign.dart';

class CampaignService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get active campaigns with optional filters
  Stream<List<Campaign>> getActiveCampaigns({
    String? cause,
    int limit = 20,
  }) {
    Query query = _firestore
        .collection('campaigns')
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true);

    if (cause != null && cause != 'all') {
      query = query.where('cause', isEqualTo: cause);
    }

    return query.limit(limit).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Campaign.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  /// Search campaigns by title or story
  Future<List<Campaign>> searchCampaigns(String searchTerm) async {
    if (searchTerm.isEmpty) {
      return [];
    }

    // Firestore doesn't support full-text search, so we'll get active campaigns
    // and filter client-side (for MVP - consider Algolia/ElasticSearch for production)
    final querySnapshot = await _firestore
        .collection('campaigns')
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();

    final searchLower = searchTerm.toLowerCase();
    final campaigns = querySnapshot.docs
        .map((doc) => Campaign.fromMap(doc.data(), doc.id))
        .where((campaign) =>
            campaign.title.toLowerCase().contains(searchLower) ||
            campaign.story.toLowerCase().contains(searchLower))
        .toList();

    return campaigns;
  }

  /// Get trending campaigns (highest donation velocity)
  Stream<List<Campaign>> getTrendingCampaigns({int limit = 10}) {
    // Sort by recent donation activity (last 7 days)
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    return _firestore
        .collection('campaigns')
        .where('status', isEqualTo: 'active')
        .where('createdAt', isGreaterThan: Timestamp.fromDate(sevenDaysAgo))
        .orderBy('createdAt', descending: true)
        .orderBy('donationCount', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Campaign.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get campaigns by cause category
  Stream<List<Campaign>> getCampaignsByCategory(String cause, {int limit = 20}) {
    return _firestore
        .collection('campaigns')
        .where('status', isEqualTo: 'active')
        .where('cause', isEqualTo: cause)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Campaign.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get campaigns nearing their goal (80%+)
  Stream<List<Campaign>> getCampaignsNearGoal({int limit = 10}) {
    return _firestore
        .collection('campaigns')
        .where('status', isEqualTo: 'active')
        .orderBy('raisedAmount', descending: true)
        .limit(50) // Get more to filter
        .snapshots()
        .map((snapshot) {
      final campaigns = snapshot.docs
          .map((doc) => Campaign.fromMap(doc.data(), doc.id))
          .where((campaign) {
        final progress = campaign.raisedAmount / campaign.targetAmount;
        return progress >= 0.8 && progress < 1.0;
      }).toList();

      return campaigns.take(limit).toList();
    });
  }

  /// Get urgent campaigns (ending soon)
  Stream<List<Campaign>> getUrgentCampaigns({int limit = 10}) {
    final now = DateTime.now();
    final twoDaysFromNow = now.add(const Duration(days: 2));

    return _firestore
        .collection('campaigns')
        .where('status', isEqualTo: 'active')
        .where('endDate', isLessThan: Timestamp.fromDate(twoDaysFromNow))
        .where('endDate', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('endDate', descending: false)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Campaign.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get campaign statistics
  Future<Map<String, dynamic>> getCampaignStats() async {
    final activeCampaigns = await _firestore
        .collection('campaigns')
        .where('status', isEqualTo: 'active')
        .get();

    final completedCampaigns = await _firestore
        .collection('campaigns')
        .where('status', isEqualTo: 'completed')
        .get();

    double totalRaised = 0;
    int totalDonations = 0;

    for (var doc in activeCampaigns.docs) {
      final data = doc.data();
      totalRaised += (data['raisedAmount'] ?? 0).toDouble();
      totalDonations += (data['donationCount'] ?? 0) as int;
    }

    for (var doc in completedCampaigns.docs) {
      final data = doc.data();
      totalRaised += (data['raisedAmount'] ?? 0).toDouble();
      totalDonations += (data['donationCount'] ?? 0) as int;
    }

    return {
      'activeCampaigns': activeCampaigns.size,
      'completedCampaigns': completedCampaigns.size,
      'totalRaised': totalRaised,
      'totalDonations': totalDonations,
      'averageDonation': totalDonations > 0 ? totalRaised / totalDonations : 0,
    };
  }

  /// Report a campaign
  Future<void> reportCampaign({
    required String campaignId,
    required String reason,
    String? details,
    String? userId,
  }) async {
    await _firestore.collection('campaign_reports').add({
      'campaignId': campaignId,
      'reason': reason,
      'details': details,
      'reportedBy': userId ?? 'anonymous',
      'reportedAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  /// Get campaign categories with counts
  Future<Map<String, int>> getCategoryCounts() async {
    final campaigns = await _firestore
        .collection('campaigns')
        .where('status', isEqualTo: 'active')
        .get();

    final counts = <String, int>{
      'all': campaigns.size,
      'medical': 0,
      'education': 0,
      'funeral': 0,
      'emergency': 0,
      'community': 0,
    };

    for (var doc in campaigns.docs) {
      final cause = doc.data()['cause'] as String?;
      if (cause != null && counts.containsKey(cause)) {
        counts[cause] = counts[cause]! + 1;
      }
    }

    return counts;
  }
}
