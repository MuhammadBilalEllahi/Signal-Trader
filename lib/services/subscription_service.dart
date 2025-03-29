import 'package:dio/dio.dart';
import 'package:tradingapp/shared/client/ApiClient.dart';
import 'package:flutter/foundation.dart';

class SubscriptionService {
  final ApiClient _apiService = ApiClient();

  Future<Map<String, dynamic>> getStripePlans() async {
    try {
      final response = await _apiService.get('/stripe/prices/checkUserSubscribe');
      debugPrint("===========================================================================================================================================================");
      debugPrint("______response   ${response.toString()}");
      
      // Check if response is already a Map
      if (response is Map<String, dynamic>) {
        return {
          'plans': response['data'] ?? [],
          'message': response['message'] ?? 'notSubscribed',
          'subscribedPlanId': response['subscribedPlanId'],
          'subscribedProductId': response['subscribedProductId'],
        };
      }
      
      // If response is not a Map, return empty data
      return {
        'plans': [],
        'message': 'notSubscribed',
        'subscribedPlanId': null,
        'subscribedProductId': null,
      };
    } catch (e) {
      throw Exception('Failed to fetch plans: $e');
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

  bool isPlanSubscribed(Map<String, dynamic> plan, String? subscribedPlanId) {
    return subscribedPlanId != null && plan['id'] == subscribedPlanId;
  }
} 