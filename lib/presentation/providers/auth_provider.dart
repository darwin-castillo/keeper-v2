import 'package:flutter/foundation.dart';

/// Minimal authentication state for the MVP.
///
/// In production this would delegate to an auth repository (token storage,
/// refresh, biometric unlock). Here it validates non-empty credentials and
/// exposes the authenticated driver id consumed by [RouteProvider].
class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _driverId;
  String? _driverName;
  String? _error;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get driverId => _driverId;
  String? get driverName => _driverName;
  String? get error => _error;

  Future<bool> login(String username, String password) async {
    _error = null;
    if (username.trim().isEmpty || password.trim().isEmpty) {
      _error = 'Ingresa tu usuario y contraseña.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    // Simulated secure auth latency (replace with real API call).
    await Future<void>.delayed(const Duration(milliseconds: 700));

    _driverId = 'driver-${username.trim().toLowerCase()}';
    _driverName = username.trim();
    _isAuthenticated = true;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  void logout() {
    _isAuthenticated = false;
    _driverId = null;
    _driverName = null;
    _error = null;
    notifyListeners();
  }
}
