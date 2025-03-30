import 'package:flutter/material.dart';
import 'package:tradingapp/shared/client/ApiClient.dart';

class SignalsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _signals = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  bool _isInitialized = false;
  int _currentIndex = 0;
  String? _error;

  List<Map<String, dynamic>> get signals => _signals;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  bool get isInitialized => _isInitialized;
  int get currentIndex => _currentIndex;

  Future<void> initializeSignals() async {
    if (_isInitialized) return;
    await fetchSignals(refresh: true);
    _isInitialized = true;
  }

  Future<void> fetchSignals({bool refresh = false, int? index}) async {
    if (_isLoading || (!_hasMore && !refresh)) return;

    _isLoading = true;
    notifyListeners();

    try {
      final apiClient = ApiClient();
      final response = await apiClient.get("signals/paginated?pageId=${refresh ? 1 : _currentPage}&pageSize=5");

      if (response != null && response.containsKey("signals")) {
        //debugPrint("response -----------signals ${response['signals']}");
        List<Map<String, dynamic>> newSignals = List<Map<String, dynamic>>.from(response["signals"]);

        if (refresh) {
          _signals = newSignals;
          _currentPage = 2;
          if (index != null) {
            _currentIndex = index;
          } else {
            _currentIndex = 0;
          }
        } else {
          _signals.addAll(newSignals);
          _currentPage++;
        }

        _hasMore = newSignals.length == 5;
      }
    } catch (e) {
      //debugPrint("Error fetching signals: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addNewSignal(Map<String, dynamic> signal) {
    _signals.insert(0, signal);
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    if (index >= 0 && index < _signals.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void clearSignals() {
    // Reset all signals data to initial state
    _isLoading = false;
    _error = null;
    // Add any other signals-specific data that needs to be cleared
    notifyListeners();
  }
} 