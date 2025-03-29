import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tradingapp/shared/client/ApiClient.dart';

class ProfileProvider extends ChangeNotifier {
  Map<String, dynamic>? _profileData;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  Map<String, dynamic>? get profileData => _profileData;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  Future<void> initializeProfile() async {
    if (_isInitialized) return;
    await fetchProfileData();
    _isInitialized = true;
  }

  Future<void> fetchProfileData() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final apiClient = ApiClient();
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        final response = await apiClient.get("user/profile");
        if (response != null) {
          _profileData = Map<String, dynamic>.from(response);
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateProfile(Map<String, dynamic> newData) {
    _profileData = {...?_profileData, ...newData};
    notifyListeners();
  }

  void clearProfile() {
    // Reset all profile data to initial state
    _isLoading = false;
    _error = null;
    // Add any other profile-specific data that needs to be cleared
    notifyListeners();
  }
} 