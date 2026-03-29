import 'package:flutter/material.dart';

class AuthLoginProvider with ChangeNotifier {
  String? _role;
  bool _isLoggedIn = false;

  String? get role => _role;
  bool get isLoggedIn => _isLoggedIn;

  // Set user role after login
  void setRole(String newRole) {
    _role = newRole;
    _isLoggedIn = true;
    notifyListeners();
  }

  // Reset on logout
  void clearAuthData() {
    _role = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
