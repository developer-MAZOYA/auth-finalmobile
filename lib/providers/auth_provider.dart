import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:auth_final/models/user_model.dart';
import 'package:auth_final/services/auth_service.dart';
import 'package:auth_final/services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  // UPDATED: Add serverClientId to GoogleSignIn configuration
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId:
        '1054959956859-84c10kotk7ij5vk6kt4m8bsk8ai2ircf.apps.googleusercontent.com',
  );

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

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔄 Starting Google Sign-In...');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('❌ Google sign in cancelled by user');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      print('✅ Google user obtained: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print('✅ Google authentication successful');
      print('🔑 Access Token: ${googleAuth.accessToken}');
      print('🔑 ID Token: ${googleAuth.idToken}');

      final response = await AuthService.loginWithGoogle(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
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

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ Google Sign-In error: $e');

      if (e is PlatformException) {
        switch (e.code) {
          case 'sign_in_failed':
            _error = 'Google Sign-In configuration error.';
            break;
          case 'sign_in_required':
            _error = 'Please sign in to your Google account.';
            break;
          case 'network_error':
            _error = 'Network error. Please check your internet connection.';
            break;
          case 'sign_in_canceled':
            _error = 'Google sign in was cancelled.';
            break;
          default:
            _error = 'Google Sign-In failed: ${e.message}';
        }
      } else {
        _error = 'Google Sign-In error: $e';
      }

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
    await _googleSignIn.signOut();
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

  // UPDATED: Test method with client ID
  Future<void> testGoogleSignIn() async {
    try {
      print('🧪 Testing Google Sign-In configuration...');

      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId:
            '1054959956859-84c10kotk7ij5vk6kt4m8bsk8ai2ircf.apps.googleusercontent.com',
      );

      final account = await googleSignIn.signIn();

      if (account != null) {
        print('✅ Google Sign-In test successful: ${account.email}');
        final auth = await account.authentication;
        print(
            '✅ Access Token: ${auth.accessToken != null ? "PRESENT" : "MISSING"}');
        print('✅ ID Token: ${auth.idToken != null ? "PRESENT" : "MISSING"}');

        if (auth.accessToken != null) {
          print(
              '🔑 Access Token (first 20 chars): ${auth.accessToken!.substring(0, 20)}...');
        }
        if (auth.idToken != null) {
          print(
              '🔑 ID Token (first 20 chars): ${auth.idToken!.substring(0, 20)}...');
        }
      } else {
        print('❌ Google Sign-In test: User cancelled');
      }
    } catch (e) {
      print('❌ Google Sign-In test failed: $e');
      if (e is PlatformException) {
        print('❌ Error Code: ${e.code}');
        print('❌ Error Message: ${e.message}');
        print('❌ Error Details: ${e.details}');
      }
    }
  }

  void setError(String s) {}
}
