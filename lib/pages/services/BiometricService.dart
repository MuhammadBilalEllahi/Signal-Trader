import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService extends ChangeNotifier {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<bool> checkBiometricStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool('biometric_lock_enabled') ?? false;
      
      if (!isEnabled) {
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }

      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access the app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      _isAuthenticated = didAuthenticate;
      notifyListeners();
      return didAuthenticate;
    } catch (e) {
      _isAuthenticated = true;  // Fallback to allow access if biometric fails
      notifyListeners();
      return true;
    }
  }

  void resetAuthentication() {
    _isAuthenticated = false;
    notifyListeners();
  }
} 