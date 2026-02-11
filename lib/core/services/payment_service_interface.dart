/// Payment service interface for platform-agnostic payment processing
/// Implementations: MobilePaymentService (SDK), WebPaymentService (Payment Links)
abstract class PaymentService {
  /// Initialize payment and return transaction reference
  /// Throws PaymentException if payment fails
  Future<PaymentResult> processDonation({
    required String campaignId,
    required double amount,
    required String email,
    String? phone,
    String? donorName,
    bool isAnonymous = false,
    dynamic context, // BuildContext for mobile, ignored for web
  });

  /// Verify payment status using reference
  Future<PaymentStatus> verifyPayment(String reference);
}

/// Payment result from processDonation
class PaymentResult {
  final String reference;
  final String status; // 'success', 'pending', 'failed'
  final String? message;
  final Map<String, dynamic>? metadata;

  PaymentResult({
    required this.reference,
    required this.status,
    this.message,
    this.metadata,
  });

  bool get isSuccess => status == 'success';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';
}

/// Payment verification status
class PaymentStatus {
  final String reference;
  final String status; // 'success', 'pending', 'failed', 'abandoned'
  final double amount;
  final String currency;
  final DateTime paidAt;
  final Map<String, dynamic>? metadata;

  PaymentStatus({
    required this.reference,
    required this.status,
    required this.amount,
    required this.currency,
    required this.paidAt,
    this.metadata,
  });

  bool get isVerified => status == 'success';
}

/// Custom payment exception
class PaymentException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  PaymentException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'PaymentException: $message ${code != null ? '($code)' : ''}';
}
