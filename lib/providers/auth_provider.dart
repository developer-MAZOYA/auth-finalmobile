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
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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
        // _user = response.user;

        await StorageService.saveToken(response.token);
        //  await StorageService.saveUser(response.user);

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

// Add this method to test Google Sign-In separately
  Future<void> testGoogleSignIn() async {
    try {
      print('🧪 Testing Google Sign-In configuration...');

      final GoogleSignIn googleSignIn = GoogleSignIn();
      final account = await googleSignIn.signIn();

      if (account != null) {
        print('✅ Google Sign-In test successful: ${account.email}');
        final auth = await account.authentication;
        print('✅ Access Token: ${auth.accessToken != null ? "YES" : "NO"}');
        print('✅ ID Token: ${auth.idToken != null ? "YES" : "NO"}');
      } else {
        print('❌ Google Sign-In test: User cancelled');
      }
    } catch (e) {
      print('❌ Google Sign-In test failed: $e');
      if (e is PlatformException) {
        print('❌ Error Code: ${e.code}');
        print('❌ Error Message: ${e.message}');
      }
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
      print(
          '📱 Access Token: ${googleAuth.accessToken != null ? "Received" : "NULL"}');
      print('📱 ID Token: ${googleAuth.idToken != null ? "Received" : "NULL"}');

      final response = await AuthService.loginWithGoogle(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      if (response != null) {
        _token = response.token;
        // _user = response.user;

        await StorageService.saveToken(response.token);
        //  await StorageService.saveUser(response.user);

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ ========== GOOGLE SIGN-IN ERROR ==========');
      print('❌ Exception Type: ${e.runtimeType}');
      print('❌ Full Exception: $e');

      // Specifically handle PlatformException
      if (e is PlatformException) {
        print('❌ PlatformException Code: ${e.code}');
        print('❌ PlatformException Message: ${e.message}');
        print('❌ PlatformException Details: ${e.details}');

        // Set user-friendly error message based on the code
        switch (e.code) {
          case 'sign_in_failed':
            _error =
                'Google Sign-In configuration error. Check your Google Cloud Console setup.';
            break;
          case 'sign_in_required':
            _error = 'Please sign in to your Google account.';
            break;
          case 'network_error':
            _error = 'Network error. Please check your internet connection.';
            break;
          case 'invalid_account':
            _error =
                'Invalid Google account. Please try with a different account.';
            break;
          case 'internal_error':
            _error = 'Internal error. Please try again.';
            break;
          case 'developer_error':
            _error =
                'Developer error. Check app configuration in Google Cloud Console.';
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

      print('❌ Error message shown to user: $_error');
      print('❌ ========== END ERROR ==========');

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
        // _user = response.user;

        await StorageService.saveToken(response.token);
        // await StorageService.saveUser(response.user);

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
}
