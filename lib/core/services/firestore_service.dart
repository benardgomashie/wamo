import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/campaign.dart';
import '../models/donation.dart';
import '../models/campaign_update.dart';
import '../models/payout.dart';
import '../utils/app_logger.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _logScope = 'FirestoreService';

  // ==================== CAMPAIGNS ====================

  /// Create a new campaign
  Future<String> createCampaign(Campaign campaign) async {
    AppLogger.info(_logScope, 'Creating campaign. ownerId=${campaign.ownerId}');
    try {
      final docRef =
          await _firestore.collection('campaigns').add(campaign.toMap());
      AppLogger.info(_logScope, 'Campaign created. id=${docRef.id}');
      return docRef.id;
    } catch (e, stackTrace) {
      AppLogger.error(_logScope, 'Failed to create campaign.', e, stackTrace);
      rethrow;
    }
  }

  /// Update a campaign
  Future<void> updateCampaign(
      String campaignId, Map<String, dynamic> data) async {
    AppLogger.info(_logScope,
        'Updating campaign. id=$campaignId fields=${data.keys.toList()}');
    try {
      await _firestore.collection('campaigns').doc(campaignId).update(data);
      AppLogger.info(_logScope, 'Campaign updated. id=$campaignId');
    } catch (e, stackTrace) {
      AppLogger.error(
          _logScope, 'Failed to update campaign id=$campaignId', e, stackTrace);
      rethrow;
    }
  }

  /// Get a single campaign
  Future<Campaign?> getCampaign(String campaignId) async {
    AppLogger.info(_logScope, 'Fetching campaign. id=$campaignId');
    try {
      final doc =
          await _firestore.collection('campaigns').doc(campaignId).get();

      if (!doc.exists) {
        AppLogger.warn(_logScope, 'Campaign not found. id=$campaignId');
        return null;
      }

      AppLogger.info(_logScope, 'Campaign fetched. id=$campaignId');
      return Campaign.fromMap(doc.data()!, doc.id);
    } catch (e, stackTrace) {
      AppLogger.error(
          _logScope, 'Failed to fetch campaign id=$campaignId', e, stackTrace);
      rethrow;
    }
  }

  /// Get campaigns stream (real-time)
  Stream<List<Campaign>> getCampaignsStream({
    String? creatorId,
    String? status,
    String? cause,
    int limit = 20,
  }) {
    AppLogger.info(
      _logScope,
      'Opening campaigns stream. creatorId=$creatorId status=$status cause=$cause limit=$limit',
    );
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

    query = query.orderBy('created_at', descending: true).limit(limit);

    return query.snapshots().handleError((error, stackTrace) {
      AppLogger.error(_logScope, 'Campaigns stream failed.', error, stackTrace);
    }).map((snapshot) {
      return snapshot.docs.map((doc) {
        return Campaign.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  /// Get user's campaigns
  Future<List<Campaign>> getUserCampaigns(String userId) async {
    AppLogger.info(_logScope, 'Fetching user campaigns. userId=$userId');
    try {
      final snapshot = await _firestore
          .collection('campaigns')
          .where('owner_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();

      AppLogger.info(_logScope,
          'User campaigns fetched. userId=$userId count=${snapshot.docs.length}');
      return snapshot.docs.map((doc) {
        return Campaign.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e, stackTrace) {
      AppLogger.error(_logScope, 'Failed fetching campaigns for userId=$userId',
          e, stackTrace);
      rethrow;
    }
  }

  /// Delete a campaign
  Future<void> deleteCampaign(String campaignId) async {
    AppLogger.warn(_logScope, 'Deleting campaign. id=$campaignId');
    try {
      await _firestore.collection('campaigns').doc(campaignId).delete();
      AppLogger.info(_logScope, 'Campaign deleted. id=$campaignId');
    } catch (e, stackTrace) {
      AppLogger.error(
          _logScope, 'Failed deleting campaign id=$campaignId', e, stackTrace);
      rethrow;
    }
  }

  // ==================== DONATIONS ====================

  /// Get donations for a campaign (real-time)
  Stream<List<Donation>> getCampaignDonationsStream(String campaignId) {
    AppLogger.info(
        _logScope, 'Opening donations stream for campaignId=$campaignId');
    return _firestore
        .collection('donations')
        .where('campaign_id', isEqualTo: campaignId)
        .where('status', isEqualTo: 'completed')
        .orderBy('created_at', descending: true)
        .snapshots()
        .handleError((error, stackTrace) {
      AppLogger.error(
        _logScope,
        'Campaign donations stream failed for campaignId=$campaignId',
        error,
        stackTrace,
      );
    }).map((snapshot) {
      return snapshot.docs.map((doc) {
        return Donation.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Get a single donation
  Future<Donation?> getDonation(String donationId) async {
    AppLogger.info(_logScope, 'Fetching donation. id=$donationId');
    try {
      final doc =
          await _firestore.collection('donations').doc(donationId).get();

      if (!doc.exists) {
        AppLogger.warn(_logScope, 'Donation not found. id=$donationId');
        return null;
      }

      return Donation.fromMap(doc.data()!, doc.id);
    } catch (e, stackTrace) {
      AppLogger.error(
          _logScope, 'Failed fetching donation id=$donationId', e, stackTrace);
      rethrow;
    }
  }

  /// Get user's donations
  Future<List<Donation>> getUserDonations(String userId) async {
    AppLogger.info(_logScope, 'Fetching user donations. userId=$userId');
    try {
      final snapshot = await _firestore
          .collection('donations')
          .where('donor_contact', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();

      AppLogger.info(_logScope,
          'User donations fetched. userId=$userId count=${snapshot.docs.length}');
      return snapshot.docs.map((doc) {
        return Donation.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e, stackTrace) {
      AppLogger.error(_logScope, 'Failed fetching donations for userId=$userId',
          e, stackTrace);
      rethrow;
    }
  }

  // ==================== CAMPAIGN UPDATES ====================

  /// Create a campaign update
  Future<String> createCampaignUpdate(CampaignUpdate update) async {
    AppLogger.info(
        _logScope, 'Creating campaign update. campaignId=${update.campaignId}');
    try {
      final docRef = await _firestore.collection('updates').add(update.toMap());
      AppLogger.info(_logScope, 'Campaign update created. id=${docRef.id}');
      return docRef.id;
    } catch (e, stackTrace) {
      AppLogger.error(
          _logScope, 'Failed to create campaign update.', e, stackTrace);
      rethrow;
    }
  }

  /// Get updates for a campaign (real-time)
  Stream<List<CampaignUpdate>> getCampaignUpdatesStream(String campaignId) {
    AppLogger.info(
        _logScope, 'Opening campaign updates stream. campaignId=$campaignId');
    return _firestore
        .collection('updates')
        .where('campaign_id', isEqualTo: campaignId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .handleError((error, stackTrace) {
      AppLogger.error(
        _logScope,
        'Campaign updates stream failed for campaignId=$campaignId',
        error,
        stackTrace,
      );
    }).map((snapshot) {
      return snapshot.docs.map((doc) {
        return CampaignUpdate.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Delete a campaign update
  Future<void> deleteCampaignUpdate(String updateId) async {
    AppLogger.warn(_logScope, 'Deleting campaign update. id=$updateId');
    try {
      await _firestore.collection('updates').doc(updateId).delete();
      AppLogger.info(_logScope, 'Campaign update deleted. id=$updateId');
    } catch (e, stackTrace) {
      AppLogger.error(_logScope, 'Failed deleting campaign update id=$updateId',
          e, stackTrace);
      rethrow;
    }
  }

  // ==================== PAYOUTS ====================

  /// Get payouts for a creator
  Stream<List<Payout>> getCreatorPayoutsStream(String creatorId) {
    AppLogger.info(_logScope, 'Opening payouts stream. creatorId=$creatorId');
    return _firestore
        .collection('payouts')
        .where('creator_id', isEqualTo: creatorId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .handleError((error, stackTrace) {
      AppLogger.error(
        _logScope,
        'Creator payouts stream failed for creatorId=$creatorId',
        error,
        stackTrace,
      );
    }).map((snapshot) {
      return snapshot.docs.map((doc) {
        return Payout.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Get a single payout
  Future<Payout?> getPayout(String payoutId) async {
    AppLogger.info(_logScope, 'Fetching payout. id=$payoutId');
    try {
      final doc = await _firestore.collection('payouts').doc(payoutId).get();

      if (!doc.exists) {
        AppLogger.warn(_logScope, 'Payout not found. id=$payoutId');
        return null;
      }

      return Payout.fromMap(doc.data()!, doc.id);
    } catch (e, stackTrace) {
      AppLogger.error(
          _logScope, 'Failed fetching payout id=$payoutId', e, stackTrace);
      rethrow;
    }
  }

  // ==================== STATISTICS ====================

  /// Get campaign statistics
  Future<Map<String, dynamic>> getCampaignStats(String campaignId) async {
    AppLogger.info(
        _logScope, 'Computing campaign stats. campaignId=$campaignId');
    try {
      final campaign = await getCampaign(campaignId);

      if (campaign == null) {
        AppLogger.warn(_logScope,
            'Campaign stats skipped; campaign missing. id=$campaignId');
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
      final uniqueDonors =
          donationsList.map((d) => d.donorContact).toSet().length;

      AppLogger.info(_logScope,
          'Campaign stats ready. campaignId=$campaignId donors=$totalDonors');
      return {
        'total_raised': campaign.raisedAmount,
        'goal_amount': campaign.targetAmount,
        'progress_percentage': campaign.progressPercentage,
        'total_donations': totalDonors,
        'unique_donors': uniqueDonors,
        'days_remaining': campaign.endDate.difference(DateTime.now()).inDays,
        'is_goal_reached': campaign.isGoalReached,
      };
    } catch (e, stackTrace) {
      AppLogger.error(_logScope,
          'Failed computing stats for campaignId=$campaignId', e, stackTrace);
      rethrow;
    }
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    AppLogger.info(_logScope, 'Computing user stats. userId=$userId');
    try {
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
    } catch (e, stackTrace) {
      AppLogger.error(_logScope, 'Failed computing stats for userId=$userId', e,
          stackTrace);
      rethrow;
    }
  }

  // ==================== SEARCH & FILTER ====================

  /// Search campaigns by title or description
  Future<List<Campaign>> searchCampaigns(String query) async {
    AppLogger.info(_logScope, 'Searching campaigns. query="$query"');
    try {
      final snapshot = await _firestore
          .collection('campaigns')
          .where('status', isEqualTo: 'active')
          .get();

      final campaigns = snapshot.docs.map((doc) {
        return Campaign.fromMap(doc.data(), doc.id);
      }).toList();

      // Filter by query in memory (Firestore doesn't support full-text search)
      final lowerQuery = query.toLowerCase();
      final filtered = campaigns.where((campaign) {
        return campaign.title.toLowerCase().contains(lowerQuery) ||
            campaign.story.toLowerCase().contains(lowerQuery);
      }).toList();
      AppLogger.info(
          _logScope, 'Campaign search result count=${filtered.length}');
      return filtered;
    } catch (e, stackTrace) {
      AppLogger.error(_logScope, 'Failed searching campaigns.', e, stackTrace);
      rethrow;
    }
  }

  /// Get featured campaigns
  Stream<List<Campaign>> getFeaturedCampaignsStream({int limit = 10}) {
    AppLogger.info(
        _logScope, 'Opening featured campaigns stream. limit=$limit');
    return _firestore
        .collection('campaigns')
        .where('status', isEqualTo: 'active')
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .handleError((error, stackTrace) {
      AppLogger.error(
          _logScope, 'Featured campaigns stream failed.', error, stackTrace);
    }).map((snapshot) {
      return snapshot.docs.map((doc) {
        return Campaign.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Get trending campaigns (most donated in last 7 days)
  Stream<List<Campaign>> getTrendingCampaignsStream({int limit = 10}) {
    AppLogger.info(
        _logScope, 'Opening trending campaigns stream. limit=$limit');
    return _firestore
        .collection('campaigns')
        .where('status', isEqualTo: 'active')
        .orderBy('raised_amount', descending: true)
        .limit(limit)
        .snapshots()
        .handleError((error, stackTrace) {
      AppLogger.error(
          _logScope, 'Trending campaigns stream failed.', error, stackTrace);
    }).map((snapshot) {
      return snapshot.docs.map((doc) {
        return Campaign.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}
