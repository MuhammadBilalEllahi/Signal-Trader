import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tradingapp/shared/client/ApiClient.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  Future<dynamic> createSubscription(String priceId, String productId) async {
    final response = await _apiClient.post('user-subscribes/user/pay-plan/$priceId/$productId', {});
    return response;
  }
}
