import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../app/constants.dart';
import '../models/campaign.dart';
import '../utils/platform_utils.dart';

// Conditional import - only import paystack on mobile
import 'package:flutter_paystack_plus/flutter_paystack_plus.dart'
    if (dart.library.html) '../stubs/flutter_paystack_stub.dart';

class DonationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PaystackPop _paystack = PaystackPop();
  final Uuid _uuid = const Uuid();

  /// Initialize Paystack with public key
  Future<void> initialize() async {
    await _paystack.initialize(
      publicKey: AppConstants.paystackPublicKey,
    );
  }

  /// Calculate fees for a donation amount
  /// Returns a map with breakdowns: donation, platformFee, paystackFee, total
  Map<String, double> calculateFees(double donationAmount) {
    // Platform fee (4%)
    final platformFee = donationAmount * (AppConstants.platformFeePercentage / 100);

    // Paystack fee estimation
    // Card: 1.5% + GHS 0.50 (capped at GHS 2,000)
    // Mobile Money: ~1.5% (varies by provider)
    // Using conservative estimate: 2%
    final paystackFeePercent = 2.0;
    final paystackFee = donationAmount * (paystackFeePercent / 100);

    final totalAmount = donationAmount + platformFee + paystackFee;

    return {
      'donation': donationAmount,
      'platformFee': platformFee,
      'paystackFee': paystackFee,
      'total': totalAmount,
    };
  }

  /// Validate donation amount
  String? validateAmount(double? amount) {
    if (amount == null || amount <= 0) {
      return 'Please enter a valid amount';
    }

    if (amount < AppConstants.minDonationAmount) {
      return 'Minimum donation is GH₵${AppConstants.minDonationAmount.toStringAsFixed(0)}';
    }

    if (amount > AppConstants.maxDonationAmount) {
      return 'Maximum donation is GH₵${AppConstants.maxDonationAmount.toStringAsFixed(0)}';
    }

    return null;
  }

  /// Initiate donation payment
  /// Returns transaction reference if successful, throws on error
  Future<String> initiateDonation({
    required BuildContext context,
    required String campaignId,
    required double amount,
    required String email,
    String? donorName,
    String? donorContact,
    String? message,
    bool isAnonymous = false,
  }) async {
    // Validate amount
    final validationError = validateAmount(amount);
    if (validationError != null) {
      throw Exception(validationError);
    }

    // Get campaign to verify it exists and is active
    final campaignDoc = await _firestore
        .collection('campaigns')
        .doc(campaignId)
        .get();

    if (!campaignDoc.exists) {
      throw Exception('Campaign not found');
    }

    final campaign = Campaign.fromMap(campaignDoc.data()!, campaignDoc.id);

    if (campaign.status != 'active') {
      throw Exception('This campaign is not currently accepting donations');
    }

    // Calculate fees
    final fees = calculateFees(amount);
    final totalAmount = fees['total']!;

    // Generate transaction reference
    final reference = 'wamo_${_uuid.v4().replaceAll('-', '').substring(0, 16)}';

    // Convert to kobo (Paystack uses smallest currency unit)
    final amountInKobo = (totalAmount * 100).toInt();

    // Create charge with metadata
    final metadata = {
      'campaign_id': campaignId,
      'donation_amount': amount,
      'platform_fee': fees['platformFee'],
      'paystack_fee': fees['paystackFee'],
      'donor_name': isAnonymous ? 'Anonymous' : (donorName ?? 'Anonymous'),
      'donor_contact': donorContact ?? '',
      'message': message ?? '',
      'is_anonymous': isAnonymous,
    };

    // Process payment using PaystackPop
    final response = await _paystack.chargeCard(
      context,
      charge: Charge()
        ..amount = amountInKobo
        ..email = email
        ..reference = reference
        ..metadata = metadata,
    );

    if (response.status) {
      // Payment initiated successfully
      // Note: Donation record will be created by webhook after verification
      return reference;
    } else {
      throw Exception(response.message ?? 'Payment failed');
    }
  }

  /// Charge card directly (alternative to checkout modal)
  Future<String> chargeCard({
    required BuildContext context,
    required String campaignId,
    required double amount,
    required String email,
    required PaymentCard card,
    String? donorName,
    String? donorContact,
    String? message,
    bool isAnonymous = false,
  }) async {
    final fees = calculateFees(amount);
    final totalAmount = fees['total']!;
    final reference = 'wamo_${_uuid.v4().replaceAll('-', '').substring(0, 16)}';
    final amountInKobo = (totalAmount * 100).toInt();

    final charge = Charge()
      ..amount = amountInKobo
      ..email = email
      ..reference = reference
      ..card = card
      ..metadata = {
        'campaign_id': campaignId,
        'donation_amount': amount,
        'platform_fee': fees['platformFee'],
        'paystack_fee': fees['paystackFee'],
        'donor_name': isAnonymous ? 'Anonymous' : (donorName ?? 'Anonymous'),
        'donor_contact': donorContact ?? '',
        'message': message ?? '',
        'is_anonymous': isAnonymous,
      };

    final response = await _paystack.chargeCard(context, charge: charge);

    if (response.status) {
      return reference;
    } else {
      throw Exception(response.message ?? 'Card charge failed');
    }
  }

  /// Verify transaction status (call after payment)
  /// This is a client-side check - server webhook will create the actual donation
  Future<bool> verifyTransaction(String reference) async {
    try {
      // Query Firestore to see if webhook created the donation
      final querySnapshot = await _firestore
          .collection('donations')
          .where('reference', isEqualTo: reference)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get suggested donation amounts based on campaign target
  List<double> getSuggestedAmounts(Campaign campaign) {
    final target = campaign.targetAmount;

    if (target <= 100) {
      return [10, 20, 50];
    } else if (target <= 500) {
      return [20, 50, 100];
    } else if (target <= 2000) {
      return [50, 100, 200];
    } else if (target <= 10000) {
      return [100, 200, 500];
    } else {
      return [200, 500, 1000];
    }
  }

  /// Format currency amount
  String formatCurrency(double amount) {
    if (amount >= 1000) {
      return 'GH₵${(amount / 1000).toStringAsFixed(1)}k';
    }
    return 'GH₵${amount.toStringAsFixed(0)}';
  }

  /// Get donation statistics for a campaign
  Future<Map<String, dynamic>> getDonationStats(String campaignId) async {
    final querySnapshot = await _firestore
        .collection('donations')
        .where('campaign_id', isEqualTo: campaignId)
        .where('status', isEqualTo: 'successful')
        .get();

    final donations = querySnapshot.docs;
    final totalAmount = donations.fold<double>(
      0,
      (sum, doc) => sum + (doc.data()['amount'] as num).toDouble(),
    );

    final uniqueDonors = donations
        .map((doc) => doc.data()['donor_contact'])
        .where((contact) => contact != null && contact.isNotEmpty)
        .toSet()
        .length;

    return {
      'totalDonations': donations.length,
      'totalAmount': totalAmount,
      'uniqueDonors': uniqueDonors,
      'averageDonation': donations.isEmpty ? 0.0 : totalAmount / donations.length,
    };
  }
}
