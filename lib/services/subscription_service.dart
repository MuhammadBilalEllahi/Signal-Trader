import 'package:dio/dio.dart';
import 'package:tradingapp/shared/client/ApiClient.dart';

class SubscriptionService {
  final ApiClient  _apiService = ApiClient();

  Future<List<dynamic>> getStripePlans() async {
    try {
      final response = await _apiService.get('/stripe/prices');
      return response;
    } catch (e) {
      throw Exception('Failed to fetch plans: $e');
    }
  }

  Future<dynamic> createSubscription(String priceId) async {
    try {
      final response = await _apiService.post('/stripe/create-subscription', {
        'priceId': priceId,
      });
      return response;
    } catch (e) {
      throw Exception('Failed to create subscription: $e');
    }
  }

  Future<dynamic> getSubscriptionStatus() async {
    try {
      final response = await _apiService.get('/subscriptions/user');
      return response;
    } catch (e) {
      throw Exception('Failed to fetch subscription status: $e');
    }
  }
} 