/// Stub file for flutter_paystack on web
/// This file is used when flutter_paystack is not available (web platform)

class PaystackPlugin {
  Future<void> initialize({required String publicKey}) async {
    throw UnsupportedError('Paystack is not supported on web');
  }

  Future<CheckoutResponse> checkout(
    BuildContext context, {
    required Charge charge,
    required CheckoutMethod method,
    bool fullscreen = false,
  }) async {
    throw UnsupportedError('Paystack is not supported on web');
  }
}

class Charge {
  String? email;
  double? amount;
  String? reference;
  Map<String, dynamic>? metadata;

  Charge();
}

class CheckoutResponse {
  bool status = false;
  String? message;
  String? reference;

  CheckoutResponse({this.status = false, this.message, this.reference});
}

enum CheckoutMethod {
  card,
  selectable,
}

// Stub for BuildContext (will use Flutter's actual BuildContext)
typedef BuildContext = dynamic;
