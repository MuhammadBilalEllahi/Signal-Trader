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

  String _getPaymentStatusString(PaymentIntentsStatus status) {
    switch (status) {
      case PaymentIntentsStatus.Succeeded:
        return 'succeeded';
      case PaymentIntentsStatus.Processing:
        return 'processing';
      case PaymentIntentsStatus.RequiresPaymentMethod:
        return 'requires_payment_method';
      case PaymentIntentsStatus.RequiresConfirmation:
        return 'requires_confirmation';
      case PaymentIntentsStatus.RequiresAction:
        return 'requires_action';
      case PaymentIntentsStatus.Canceled:
        return 'canceled';
      default:
        return 'unknown';
    }
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

        // Get payment details after successful payment
        final paymentIntent = await Stripe.instance.retrievePaymentIntent(response['clientSecret']);
        
        if (paymentIntent.status == PaymentIntentsStatus.Succeeded) {
          // Get transaction details
          final transactionDetails = {
            'paymentIntentId': paymentIntent.id,
            'amount': paymentIntent.amount,
            'currency': paymentIntent.currency,
            'status': _getPaymentStatusString(paymentIntent.status),
            'created': paymentIntent.created,
            'paymentMethodId': paymentIntent.paymentMethodId,
          };

          // Post to /user/paid with transaction details
          final paidResponse = await _apiClient.post('user-subscribes/user/paid', {
            'transactionDetails': transactionDetails,
          });

          if (paidResponse['success']) {
            return {
              'success': true, 
              'transactionId': paidResponse['transactionId'],
              'transactionDetails': transactionDetails
            };
          } else {
            return {'success': false, 'error': paidResponse['error']};
          }
        } else {
          return {'success': false, 'error': 'Payment was not successful'};
        }
      }
      return {'success': false, 'error': 'Failed to initialize payment'};
      
    } catch (e) {
      debugPrint("Payment Error: $e");
      // Post to /user/failed if there is an exception
      final failedResponse = await _apiClient.post('user-subscribes/user/failed', {
        'error': e.toString()
      });
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getTransactionHistory() async {
    try {
      final response = await _apiClient.get('user-subscribes/user/transactions');
      return response;
    } catch (e) {
      debugPrint("Get Transaction History Error: $e");
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getCurrentSubscription() async {
    try {
      final response = await _apiClient.get('user-subscribes/user/current-subscription');
      return response;
    } catch (e) {
      debugPrint("Get Current Subscription Error: $e");
      return {'success': false, 'error': e.toString()};
    }
  }
}
