import 'package:flutter/material.dart';
import 'package:tradingapp/shared/client/ApiClient.dart';
import 'package:tradingapp/shared/constants/Constants.dart';

class NewsAlertsService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Map<String, dynamic>>> fetchNewsAlerts({int page = 1, int limit = 10}) async {
    try {
      final response = await _apiClient.get('news-alerts/all-paginated?page=$page&limit=$limit');
      
      //debugPrint("response---- $response");
      if (response != null && response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      print('Error fetching news alerts: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchLiveNewsAlerts() async {
    try {
      final response = await _apiClient.get('news-alerts/live');
      
      if (response != null && response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      print('Error fetching live news alerts: $e');
      return [];
    }
  }

  // Future<void> saveNewsAlert(String newsAlertId) async {
  //   try {
  //     final response = await _apiClient.post('news-alerts/save/$newsAlertId');
  //   } catch (e) {
  //     print('Error saving news alert: $e');
  //   }
  // }

  // Future<void> unsaveNewsAlert(String newsAlertId) async {
  //   try {
  //     final response = await _apiClient.post('news-alerts/unsave/$newsAlertId');
  //   } catch (e) {
  //     print('Error unsaving news alert: $e');
  //   }
  // }

  
} 