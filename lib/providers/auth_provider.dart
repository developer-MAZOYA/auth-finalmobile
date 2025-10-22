import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _token = await StorageService.getToken();
    _user = await StorageService.getUser();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthService.login(
        email: email,
        password: password,
      );

      if (response != null) {
        _token = response.token;
        _user = response.user;

        await StorageService.saveToken(response.token);
        await StorageService.saveUser(response.user);

        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthService.register(
        name: name,
        email: email,
        password: password,
      );

      if (response != null) {
        _token = response.token;
        _user = response.user;

        await StorageService.saveToken(response.token);
        await StorageService.saveUser(response.user);

        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    _error = null;
    await StorageService.clearAuthData();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
