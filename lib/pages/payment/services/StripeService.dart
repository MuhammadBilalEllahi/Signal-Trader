import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tradingapp/shared/client/ApiClient.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:tradingapp/shared/constants/app_constants.dart';

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
        debugPrint("RESPONSE: ${response}");
        // Initialize payment sheet
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: response['clientSecret'],
            merchantDisplayName: AppConstants.appName,
            style: ThemeMode.system,
          ),
        );

        // Present payment sheet
        await Stripe.instance.presentPaymentSheet();

        // Post to /user/paid only if payment is successful
        final paidResponse = await _apiClient.post('user-subscribes/user/paid', {});
        if (paidResponse['success']) {
          return {'success': true};
        } else {
          return {'success': false, 'error': paidResponse['error']};
        }
      }
      return {'success': false, 'error': 'Failed to initialize payment'};
      
    } catch (e) {
      // Post to /user/failed if there is an exception
      final failedResponse = await _apiClient.post('user-subscribes/user/failed', {});
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<void> handlePaymentSuccess() async {
    // Handle any post-payment success logic
  }
}
