import 'package:flutter/foundation.dart';

class ApiConstants {
  // static String baseUrl = 'https://trading-server-production.up.railway.app/';
  static String baseUrl = 'http://192.168.1.10:8080/';
  // _getBaseUrl();

  static String _getBaseUrl() {
    if (kDebugMode) {
      return 'http://192.168.1.10:8080/';
    } else if (kReleaseMode) {
      return 'https://trading-server-production.up.railway.app/';
    } else if (kProfileMode) {
      return 'http://0.0.0.0:8080/';
    }
    return 'https://trading-server-production.up.railway.app/';
  }

  static String signals = 'signals';
  static String adminCreateSignal = 'signals/admin/create';
  static String signalsHistory = 'signals/history';
  static String signalsFavourite = 'signals/favourite';
  static String signalsFavourites = 'signals/favorites';

  static String newsAlerts = 'news-alerts';
  static String newsAlertsLive = 'news-alerts/live';
  static String newsAlertsPaginated = 'news-alerts/all-paginated';
}