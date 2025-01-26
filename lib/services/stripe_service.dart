import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:stripe_test_app/constants/constants.dart';

class StripeService {
  StripeService._privateConstructor();

  static final StripeService instance = StripeService._privateConstructor();

  Future<Map<String, dynamic>> _createPaymentIntent(int amount) async {
    try {
      const url = "https://api.stripe.com/v1/payment_intents";
      final response = await Dio().post(
        url,
        data: {
          'amount': (amount * 100).toString(), // Amount in cents
          'currency': 'usd',
          'payment_method_types[]': 'card',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $stripeSecretKey',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );
      return response.data;
    } catch (e) {
      print("Error creating payment intent: $e");
      throw Exception("Failed to create payment intent.");
    }
  }

  Future<void> initPaymentSheet(int amount) async {
    try {
      // Step 1: Create Payment Intent
      final intentData = await _createPaymentIntent(amount);

      // Step 2: Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: intentData['client_secret'],
          merchantDisplayName: 'Your Business Name',
          style: ThemeMode.light,
        ),
      );
    } catch (e) {
      print("Error initializing payment sheet: $e");
      throw Exception("Failed to initialize payment sheet.");
    }
  }

  Future<void> presentPaymentSheet() async {
    try {
      // Present the payment sheet
      await Stripe.instance.presentPaymentSheet();
      print("Payment successful!");
    } catch (e) {
      print("Error presenting payment sheet: $e");
      throw Exception("Payment failed or was canceled.");
    }
  }
}
