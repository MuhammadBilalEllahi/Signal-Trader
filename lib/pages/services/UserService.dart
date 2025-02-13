import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserService extends ChangeNotifier {
  User? _user; 
  bool _isLoading = true;

  User? get user => _user;
  bool get isLoading => _isLoading;

  // Fetch User Data
  void setUser(User? user) {
    _user = user;
    _isLoading = false;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }


}
