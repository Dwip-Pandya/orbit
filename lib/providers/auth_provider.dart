import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:screen_protector/screen_protector.dart';

class AuthProvider extends ChangeNotifier {
  bool _isFirstLaunch = true;
  bool _isAuthenticated = false;
  String? _masterPassword;
  bool _biometricEnabled = false;
  bool _screenshotProtection = true;
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool get isFirstLaunch => _isFirstLaunch;
  bool get isAuthenticated => _isAuthenticated;
  bool get biometricEnabled => _biometricEnabled;
  bool get screenshotProtection => _screenshotProtection;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _masterPassword = prefs.getString('master_password');
    _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    _screenshotProtection = prefs.getBool('screenshot_protection') ?? true;
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

  Future<bool> authenticateWithBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
      if (!canCheck) return false;

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Unlock Orbit Vault',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );

      if (didAuthenticate) {
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Biometric error: $e');
    }
    return false;
  }

  Future<void> toggleBiometric(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', enabled);
    _biometricEnabled = enabled;
    notifyListeners();
  }

  Future<void> toggleScreenshotProtection(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('screenshot_protection', enabled);
    _screenshotProtection = enabled;
    if (enabled) {
      await ScreenProtector.preventScreenshotOn();
    } else {
      await ScreenProtector.preventScreenshotOff();
    }
    notifyListeners();
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

