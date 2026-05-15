import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isFirstLaunch = true;
  bool _isAuthenticated = false;
  String? _masterPassword;

  bool get isFirstLaunch => _isFirstLaunch;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _masterPassword = prefs.getString('master_password');
    _isFirstLaunch = _masterPassword == null;
    notifyListeners();
  }

  Future<bool> setupMasterPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('master_password', password);
    _masterPassword = password;
    _isFirstLaunch = false;
    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  Future<bool> unlock(String password) async {
    if (password == _masterPassword) {
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<bool> changeMasterPassword(String oldPassword, String newPassword) async {
    if (oldPassword == _masterPassword) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('master_password', newPassword);
      _masterPassword = newPassword;
      notifyListeners();
      return true;
    }
    return false;
  }
}
