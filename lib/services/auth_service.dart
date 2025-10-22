import 'dart:convert';
import 'package:auth_final/models/auth_response.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:9090/auth';

  // Register user
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
