import 'dart:convert';
import 'package:auth_final/models/auth_response.dart';
import 'package:auth_final/models/user_model.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://192.168.1.190:9292/user';
  //static const String baseUrl = 'http://192.168.1.149:9292/user';
  static const String baseUrl2 = 'http://192.168.1.190:9595';
  //static const String baseUrl2 = 'http://192.168.1.149:9595';

  static Future<AuthResponse?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AuthResponse.fromJson(data);
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

// Add this to your existing AuthService class
  static Future<AuthResponse?> loginWithGoogle({
    required String? accessToken,
    required String? idToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl2/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'provider': 'google',
          'accessToken': accessToken,
          'idToken': idToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AuthResponse(
          token: data['token'],
          user: User.fromJson(data['user']),
        );
      } else {
        throw Exception('Google login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Google login error: $e');
    }
  }

  // Login user
  static Future<AuthResponse?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AuthResponse.fromJson(data);
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  // Verify token (optional - for token validation)
  static Future<bool> verifyToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/verify'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
