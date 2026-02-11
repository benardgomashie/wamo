import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../../app/constants.dart';
import '../utils/app_logger.dart';
import 'payment_service_interface.dart';

/// Mobile payment service using Paystack Payment Links for iOS/Android
/// Uses same approach as web to ensure consistency
class MobilePaymentService implements PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _logScope = 'MobilePaymentService';

  @override
  Future<PaymentResult> processDonation({
    required String campaignId,
    required double amount,
    required String email,
    String? phone,
    String? donorName,
    bool isAnonymous = false,
    dynamic context,
  }) async {
    try {
      // Generate unique reference
      final reference = _generateReference();

      // Convert amount to kobo/pesewas
      final amountInKobo = (amount * 100).toInt();

      // Create payment initialization request
      final response = await http.post(
        Uri.parse('https://api.paystack.co/transaction/initialize'),
        headers: {
          'Authorization': 'Bearer ${AppConstants.paystackSecretKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amountInKobo,
          'email': email,
          'reference': reference,
          'currency': 'GHS',
          'callback_url':
              '${AppConstants.appUrl}/payment/verify?reference=$reference',
          'metadata': {
            'campaign_id': campaignId,
            'donor_name': donorName ?? 'Anonymous',
            'is_anonymous': isAnonymous,
            'phone': phone,
            'platform': 'mobile',
          },
          'channels': ['card', 'mobile_money'], // Enable mobile money
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true) {
          final authorizationUrl = data['data']['authorization_url'];
          final accessCode = data['data']['access_code'];

          // Save pending donation record
          await _saveDonationRecord(
            reference: reference,
            campaignId: campaignId,
            amount: amount,
            email: email,
            phone: phone,
            donorName: donorName,
            isAnonymous: isAnonymous,
            status: 'pending',
            accessCode: accessCode,
          );

          // Launch Paystack payment page
          final uri = Uri.parse(authorizationUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);

            return PaymentResult(
              reference: reference,
              status: 'pending',
              message: 'Redirecting to payment page...',
              metadata: {
                'authorization_url': authorizationUrl,
                'access_code': accessCode,
              },
            );
          } else {
            throw PaymentException('Could not open payment page');
          }
        } else {
          throw PaymentException(
            data['message'] ?? 'Payment initialization failed',
          );
        }
      } else {
        throw PaymentException(
          'Payment API request failed with status ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is PaymentException) {
        rethrow;
      }
      throw PaymentException(
        'An unexpected error occurred during payment initialization',
        originalError: e,
      );
    }
  }

  @override
  Future<PaymentStatus> verifyPayment(String reference) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.paystack.co/transaction/verify/$reference'),
        headers: {
          'Authorization': 'Bearer ${AppConstants.paystackSecretKey}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true) {
          final transactionData = data['data'];
          final status = transactionData['status'];
          final amount = (transactionData['amount'] ?? 0) / 100;
          final currency = transactionData['currency'] ?? 'GHS';
          final paidAt = transactionData['paid_at'] != null
              ? DateTime.parse(transactionData['paid_at'])
              : DateTime.now();

          // Update donation record if successful
          if (status == 'success') {
            await _updateDonationStatus(
              reference: reference,
              status: 'success',
              metadata: transactionData,
            );
          }

          return PaymentStatus(
            reference: reference,
            status: status,
            amount: amount,
            currency: currency,
            paidAt: paidAt,
            metadata: transactionData,
          );
        } else {
          throw PaymentException(
            data['message'] ?? 'Payment verification failed',
          );
        }
      } else {
        throw PaymentException(
          'Verification API request failed with status ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is PaymentException) {
        rethrow;
      }
      throw PaymentException(
        'An unexpected error occurred during payment verification',
        originalError: e,
      );
    }
  }

  /// Save donation record to Firestore
  Future<void> _saveDonationRecord({
    required String reference,
    required String campaignId,
    required double amount,
    required String email,
    String? phone,
    String? donorName,
    required bool isAnonymous,
    required String status,
    String? accessCode,
  }) async {
    try {
      await _firestore.collection('donations').doc(reference).set({
        'reference': reference,
        'campaignId': campaignId,
        'amount': amount,
        'email': email,
        'phone': phone,
        'donorName': isAnonymous ? 'Anonymous' : donorName,
        'isAnonymous': isAnonymous,
        'status': status,
        'paymentMethod': 'mobile',
        'platform': 'mobile',
        'accessCode': accessCode,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      AppLogger.error(
          _logScope, 'Error saving donation record for ref=$reference', e);
    }
  }

  /// Update donation status after verification
  Future<void> _updateDonationStatus({
    required String reference,
    required String status,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final donationRef = _firestore.collection('donations').doc(reference);
      await donationRef.update({
        'status': status,
        'verifiedAt': FieldValue.serverTimestamp(),
        'paymentMetadata': metadata,
      });

      // Update campaign total if successful
      if (status == 'success') {
        final donationDoc = await donationRef.get();
        if (donationDoc.exists) {
          final campaignId = donationDoc.data()?['campaignId'];
          final amount = donationDoc.data()?['amount'];
          if (campaignId != null && amount != null) {
            await _updateCampaignTotal(campaignId, amount);
          }
        }
      }
    } catch (e) {
      AppLogger.error(
          _logScope, 'Error updating donation status for ref=$reference', e);
    }
  }

  /// Update campaign total raised
  Future<void> _updateCampaignTotal(String campaignId, double amount) async {
    final campaignRef = _firestore.collection('campaigns').doc(campaignId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(campaignRef);
      if (snapshot.exists) {
        final currentTotal = (snapshot.data()?['totalRaised'] ?? 0.0) as double;
        final donorCount = (snapshot.data()?['donorCount'] ?? 0) as int;
        transaction.update(campaignRef, {
          'totalRaised': currentTotal + amount,
          'donorCount': donorCount + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  /// Generate unique payment reference
  String _generateReference() {
    return 'WAMO_MOBILE_${DateTime.now().millisecondsSinceEpoch}';
  }
}
