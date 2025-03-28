import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tradingapp/shared/client/ApiClient.dart';

class StripeService {
  static final StripeService _instance = StripeService._internal();
  final ApiClient _apiClient = ApiClient();

  factory StripeService() => _instance;

  StripeService._internal();

  Future<void> initialize() async {
    Stripe.publishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';
    await Stripe.instance.applySettings();
  }

  Future<Map<String, dynamic>> createSubscription(String priceId) async {
    try {
      // Create subscription on backend
      final response = await _apiClient.post('/stripe/create-subscription', {
        'priceId': priceId,
      });

      final subscriptionId = response['subscriptionId'];
      final clientSecret = response['clientSecret'];

      // Confirm payment with Stripe
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
      );

      return {
        'success': true,
        'subscriptionId': subscriptionId,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<void> cancelSubscription(String subscriptionId) async {
    try {
      await _apiClient.post('/stripe/cancel-subscription', {
        'subscriptionId': subscriptionId,
      });
    } catch (e) {
      throw Exception('Failed to cancel subscription: $e');
    }
  }
}
