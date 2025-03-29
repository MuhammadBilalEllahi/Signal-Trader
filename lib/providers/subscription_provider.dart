import 'package:flutter/foundation.dart';
import 'package:tradingapp/services/subscription_service.dart';

class SubscriptionProvider with ChangeNotifier {
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool _isSubscribed = false;
  String? _subscribedPlanId;
  String? _subscribedProductId;
  bool _isLoading = true;
  String? _error;
  DateTime? _lastCheckTime;
  static const _cacheDuration = Duration(minutes: 5);

  bool get isSubscribed => _isSubscribed;
  String? get subscribedPlanId => _subscribedPlanId;
  String? get subscribedProductId => _subscribedProductId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> checkSubscriptionStatus({bool forceRefresh = false}) async {
    // If we have a recent check and don't need to force refresh, return early
    if (!forceRefresh && 
        _lastCheckTime != null && 
        DateTime.now().difference(_lastCheckTime!) < _cacheDuration) {
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _subscriptionService.getStripePlans();
      
      _isSubscribed = response['message'] == 'alreadySubscribed';
      _subscribedPlanId = response['subscribedPlanId'];
      _subscribedProductId = response['subscribedProductId'];
      _lastCheckTime = DateTime.now();
      _isLoading = false;
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshSubscriptionStatus() async {
    await checkSubscriptionStatus(forceRefresh: true);
  }

  bool isPlanSubscribed(Map<String, dynamic> plan) {
    return _subscribedPlanId != null && plan['id'] == _subscribedPlanId;
  }

  void clearSubscription() {
    _isSubscribed = false;
    _subscribedPlanId = null;
    _subscribedProductId = null;
    _lastCheckTime = null;
    notifyListeners();
  }
} 