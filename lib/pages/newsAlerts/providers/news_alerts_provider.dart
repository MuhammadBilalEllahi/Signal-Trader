import 'package:flutter/material.dart';

class NewsAlertsProvider extends ChangeNotifier {
  int _currentReelIndex = 0;

  int get currentReelIndex => _currentReelIndex;

  void setCurrentReelIndex(int index) {
    _currentReelIndex = index;
    notifyListeners();
  }
} 