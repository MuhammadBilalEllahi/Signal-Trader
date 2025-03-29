import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tradingapp/shared/client/ApiClient.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

class StripeService {
  static final StripeService _instance = StripeService._internal();
  final ApiClient _apiClient = ApiClient();

  factory StripeService() => _instance;

  StripeService._internal();

  Future<void> initialize() async {
    final publishableKey = dotenv.env['random_pub_key'];
    if (publishableKey == null) {
      throw Exception('Stripe publishable key not found in environment variables');
    }
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }

  Future<Map<String, dynamic>> createSubscription(String priceId, String productId) async {
    try {
      // First create subscription in backend
      final response = await _apiClient.post('user-subscribes/user/pay-plan/$priceId/$productId', {});
      
      if (response['proceedTOPaymentPage']) {
        // Get the client secret from the subscription
        final subscriptionResponse = await _apiClient.post('stripe/create-subscription', {
          'priceId': priceId,
          'productId': productId,
        });

        // Initialize payment sheet
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: subscriptionResponse['clientSecret'],
            merchantDisplayName: 'Trading App',
            style: ThemeMode.system,
          ),
        );

        // Present payment sheet
        await Stripe.instance.presentPaymentSheet();

        return {'success': true};
      }
      
      return {'success': false, 'error': 'Failed to initialize payment'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<void> handlePaymentSuccess() async {
    // Handle any post-payment success logic
  }
}
