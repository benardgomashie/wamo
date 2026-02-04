/// Stub file for flutter_paystack_plus on web
/// This file is used when flutter_paystack_plus is not available (web platform)

import 'package:flutter/material.dart';

class PaystackPop {
  Future<void> initialize({required String publicKey}) async {
    throw UnsupportedError('Paystack is not supported on web');
  }

  Future<CheckoutResponse> chargeCard(
    BuildContext context, {
    required Charge charge,
  }) async {
    throw UnsupportedError('Paystack is not supported on web');
  }

  Future<CheckoutResponse> checkout(
    BuildContext context, {
    required Charge charge,
    CheckoutMethod? method,
  }) async {
    throw UnsupportedError('Paystack is not supported on web');
  }
}

class Charge {
  int? amount;
  String? email;
  String? reference;
  String? currency;
  Map<String, dynamic>? metadata;
  PaymentCard? card;

  Charge();
}

class PaymentCard {
  String? number;
  String? cvc;
  int? expiryMonth;
  int? expiryYear;

  PaymentCard({
    this.number,
    this.cvc,
    this.expiryMonth,
    this.expiryYear,
  });
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
