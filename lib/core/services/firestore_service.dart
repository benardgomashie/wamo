import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/campaign.dart';
import '../models/donation.dart';
import '../models/campaign_update.dart';
import '../models/payout.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== CAMPAIGNS ====================
  
  /// Create a new campaign
  Future<String> createCampaign(Campaign campaign) async {
    final docRef = await _firestore.collection('campaigns').add(campaign.toMap());
    return docRef.id;
  }

  /// Update a campaign
  Future<void> updateCampaign(String campaignId, Map<String, dynamic> data) async {
    await _firestore.collection('campaigns').doc(campaignId).update(data);
  }

  /// Get a single campaign
  Future<Campaign?> getCampaign(String campaignId) async {
    final doc = await _firestore.collection('campaigns').doc(campaignId).get();
    
    if (!doc.exists) {
      return null;
    }
    
    return Campaign.fromMap(doc.data()!, doc.id);
  }

  /// Get campaigns stream (real-time)
  Stream<List<Campaign>> getCampaignsStream({
    String? creatorId,
    String? status,
    String? cause,
    int limit = 20,
  }) {
    Query query = _firestore.collection('campaigns');

    if (creatorId != null) {
      query = query.where('owner_id', isEqualTo: creatorId);
    }

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    if (cause != null) {
      query = query.where('cause', isEqualTo: cause);
    }

    query = query
        .orderBy('created_at', descending: true)
        .limit(limit);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Campaign.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  /// Get user's campaigns
  Future<List<Campaign>> getUserCampaigns(String userId) async {
    final snapshot = await _firestore
        .collection('campaigns')
        .where('owner_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return Campaign.fromMap(doc.data(), doc.id);
    }).toList();
  }

  /// Delete a campaign
  Future<void> deleteCampaign(String campaignId) async {
    await _firestore.collection('campaigns').doc(campaignId).delete();
  }

  // ==================== DONATIONS ====================

  /// Get donations for a campaign (real-time)
  Stream<List<Donation>> getCampaignDonationsStream(String campaignId) {
    return _firestore
        .collection('donations')
        .where('campaign_id', isEqualTo: campaignId)
        .where('status', isEqualTo: 'completed')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Donation.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Get a single donation
  Future<Donation?> getDonation(String donationId) async {
    final doc = await _firestore.collection('donations').doc(donationId).get();
    
    if (!doc.exists) {
      return null;
    }
    
    return Donation.fromMap(doc.data()!, doc.id);
  }

  /// Get user's donations
  Future<List<Donation>> getUserDonations(String userId) async {
    final snapshot = await _firestore
        .collection('donations')
        .where('donor_contact', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return Donation.fromMap(doc.data(), doc.id);
    }).toList();
  }

  // ==================== CAMPAIGN UPDATES ====================

  /// Create a campaign update
  Future<String> createCampaignUpdate(CampaignUpdate update) async {
    final docRef = await _firestore.collection('updates').add(update.toMap());
    return docRef.id;
  }

  /// Get updates for a campaign (real-time)
  Stream<List<CampaignUpdate>> getCampaignUpdatesStream(String campaignId) {
    return _firestore
        .collection('updates')
        .where('campaign_id', isEqualTo: campaignId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CampaignUpdate.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Delete a campaign update
  Future<void> deleteCampaignUpdate(String updateId) async {
    await _firestore.collection('updates').doc(updateId).delete();
  }

  // ==================== PAYOUTS ====================

  /// Get payouts for a creator
  Stream<List<Payout>> getCreatorPayoutsStream(String creatorId) {
    return _firestore
        .collection('payouts')
        .where('creator_id', isEqualTo: creatorId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Payout.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Get a single payout
  Future<Payout?> getPayout(String payoutId) async {
    final doc = await _firestore.collection('payouts').doc(payoutId).get();
    
    if (!doc.exists) {
      return null;
    }
    
    return Payout.fromMap(doc.data()!, doc.id);
  }

  // ==================== STATISTICS ====================

  /// Get campaign statistics
  Future<Map<String, dynamic>> getCampaignStats(String campaignId) async {
    final campaign = await getCampaign(campaignId);
    
    if (campaign == null) {
      return {};
    }

    final donationsSnapshot = await _firestore
        .collection('donations')
        .where('campaign_id', isEqualTo: campaignId)
        .where('status', isEqualTo: 'completed')
        .get();

    final donationsList = donationsSnapshot.docs.map((doc) {
      return Donation.fromMap(doc.data(), doc.id);
    }).toList();

    final totalDonors = donationsList.length;
    final uniqueDonors = donationsList.map((d) => d.donorContact).toSet().length;

    return {
      'total_raised': campaign.raisedAmount,
      'goal_amount': campaign.targetAmount,
      'progress_percentage': campaign.progressPercentage,
      'total_donations': totalDonors,
      'unique_donors': uniqueDonors,
      'days_remaining': campaign.endDate.difference(DateTime.now()).inDays,
      'is_goal_reached': campaign.isGoalReached,
    };
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    final campaigns = await getUserCampaigns(userId);
    final donations = await getUserDonations(userId);

    final totalRaised = campaigns.fold<double>(
      0,
      (sum, campaign) => sum + campaign.raisedAmount,
    );

    final totalDonated = donations.fold<double>(
      0,
      (sum, donation) => sum + donation.amount,
    );

    final activeCampaigns = campaigns.where((c) => c.isActive).length;

    return {
      'total_campaigns': campaigns.length,
      'active_campaigns': activeCampaigns,
      'total_raised': totalRaised,
      'total_donated': totalDonated,
      'total_donations': donations.length,
    };
  }

  // ==================== SEARCH & FILTER ====================

  /// Search campaigns by title or description
  Future<List<Campaign>> searchCampaigns(String query) async {
    final snapshot = await _firestore
        .collection('campaigns')
        .where('status', isEqualTo: 'active')
        .get();

    final campaigns = snapshot.docs.map((doc) {
      return Campaign.fromMap(doc.data(), doc.id);
    }).toList();

    // Filter by query in memory (Firestore doesn't support full-text search)
    final lowerQuery = query.toLowerCase();
    return campaigns.where((campaign) {
      return campaign.title.toLowerCase().contains(lowerQuery) ||
          campaign.story.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get featured campaigns
  Stream<List<Campaign>> getFeaturedCampaignsStream({int limit = 10}) {
    return _firestore
        .collection('campaigns')
        .where('status', isEqualTo: 'active')
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Campaign.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Get trending campaigns (most donated in last 7 days)
  Stream<List<Campaign>> getTrendingCampaignsStream({int limit = 10}) {
    return _firestore
        .collection('campaigns')
        .where('status', isEqualTo: 'active')
        .orderBy('raised_amount', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Campaign.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}
