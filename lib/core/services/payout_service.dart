import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payout.dart';

class PayoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Requests a payout for a campaign
  /// Returns the payout ID if successful
  Future<String> requestPayout({
    required String campaignId,
    required String momoNumber,
    required String momoNetwork, // 'MTN', 'Vodafone', 'AirtelTigo'
  }) async {
    // Validate inputs
    if (momoNumber.isEmpty || momoNumber.length < 10) {
      throw Exception('Invalid Mobile Money number');
    }

    if (!['MTN', 'Vodafone', 'AirtelTigo'].contains(momoNetwork)) {
      throw Exception('Invalid Mobile Money network');
    }

    // Call Cloud Function to request payout
    try {
      // TODO: Replace with actual Cloud Functions call
      // final callable = FirebaseFunctions.instance.httpsCallable('requestPayout');
      // final result = await callable.call({
      //   'campaignId': campaignId,
      //   'momoNumber': momoNumber,
      //   'momoNetwork': momoNetwork,
      // });
      
      // For now, create payout record directly (will be replaced with Cloud Function)
      final payoutData = {
        'campaignId': campaignId,
        'creatorId': 'temp_user_id', // Should come from auth
        'amount': 0, // Will be calculated by Cloud Function
        'platformFeeDeducted': 0,
        'status': 'pending_review',
        'recipientMomoNumber': momoNumber,
        'recipientMomoNetwork': momoNetwork,
        'requestedAt': FieldValue.serverTimestamp(),
        'retryCount': 0,
      };

      final docRef = await _firestore.collection('payouts').add(payoutData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to request payout: $e');
    }
  }

  /// Gets payout details by ID
  Future<Payout?> getPayoutById(String payoutId) async {
    try {
      final doc = await _firestore.collection('payouts').doc(payoutId).get();
      if (doc.exists) {
        return Payout.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get payout: $e');
    }
  }

  /// Gets all payouts for a campaign
  Stream<List<Payout>> getPayoutsForCampaign(String campaignId) {
    return _firestore
        .collection('payouts')
        .where('campaignId', isEqualTo: campaignId)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Payout.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Gets all payouts for a creator
  Stream<List<Payout>> getPayoutsForCreator(String creatorId) {
    return _firestore
        .collection('payouts')
        .where('creatorId', isEqualTo: creatorId)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Payout.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Gets pending payouts for admin review
  Future<List<Payout>> getPendingPayouts({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('payouts')
          .where('status', isEqualTo: 'pending_review')
          .orderBy('requestedAt', descending: false)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Payout.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get pending payouts: $e');
    }
  }

  /// Retries a failed payout
  Future<void> retryPayout(String payoutId) async {
    try {
      // TODO: Replace with Cloud Function call
      // final callable = FirebaseFunctions.instance.httpsCallable('retryPayout');
      // await callable.call({'payoutId': payoutId});
      
      // For now, update status directly
      await _firestore.collection('payouts').doc(payoutId).update({
        'status': 'approved',
        'failureReason': null,
      });
    } catch (e) {
      throw Exception('Failed to retry payout: $e');
    }
  }

  /// Calculates total payouts for a creator
  Future<double> getTotalPayoutsForCreator(String creatorId) async {
    try {
      final snapshot = await _firestore
          .collection('payouts')
          .where('creatorId', isEqualTo: creatorId)
          .where('status', isEqualTo: 'completed')
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['amount'] ?? 0).toDouble();
      }

      return total;
    } catch (e) {
      throw Exception('Failed to calculate total payouts: $e');
    }
  }

  /// Gets payout statistics for admin dashboard
  Future<Map<String, dynamic>> getPayoutStatistics() async {
    try {
      final allPayouts = await _firestore.collection('payouts').get();

      int pending = 0;
      int approved = 0;
      int processing = 0;
      int completed = 0;
      int failed = 0;
      double totalPaid = 0;

      for (var doc in allPayouts.docs) {
        final status = doc.data()['status'] as String;
        switch (status) {
          case 'pending_review':
            pending++;
            break;
          case 'approved':
            approved++;
            break;
          case 'processing':
            processing++;
            break;
          case 'completed':
            completed++;
            totalPaid += (doc.data()['amount'] ?? 0).toDouble();
            break;
          case 'failed':
            failed++;
            break;
        }
      }

      return {
        'pending': pending,
        'approved': approved,
        'processing': processing,
        'completed': completed,
        'failed': failed,
        'totalPaid': totalPaid,
      };
    } catch (e) {
      throw Exception('Failed to get payout statistics: $e');
    }
  }
}
