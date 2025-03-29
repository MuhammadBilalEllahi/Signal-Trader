import 'package:flutter/material.dart';

class NewsAlertsProvider extends ChangeNotifier {
  int _currentReelIndex = 0;
  bool _isLoading = false;
  String? _error;

  int get currentReelIndex => _currentReelIndex;

  void setCurrentReelIndex(int index) {
    _currentReelIndex = index;
    notifyListeners();
  }

  void clearNewsAlerts() {
    // Reset all news alerts data to initial state
    _isLoading = false;
    _error = null;
    // Add any other news alerts-specific data that needs to be cleared
    notifyListeners();
  }
} 