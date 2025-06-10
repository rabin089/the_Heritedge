

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLoginProvider with ChangeNotifier {
  String? _role;
  bool _isLoggedIn = false;

  String? get role => _role;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> setRole(String newRole) async {
    _role = newRole;
    _isLoggedIn = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('roles_for_users', newRole);
    notifyListeners();
  }

  Future<void> loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    _role = prefs.getString('roles_for_users');
    _isLoggedIn = _role != null;
    notifyListeners();
  }

  Future<void> clearAuthData() async {
    _role = null;
    _isLoggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('roles_for_users');
    notifyListeners();
  }
}
