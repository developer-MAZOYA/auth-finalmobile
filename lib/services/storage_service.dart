import 'dart:convert';

import 'package:auth_final/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'bearerToken';
  static const String _userKey = 'userData';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, user.toJson().toString());
  }

  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      try {
        final userMap = Map<String, dynamic>.from(json.decode(userJson));
        return User.fromJson(userMap);
      } catch (e) {
        print('Error parsing user data: $e');
      }
    }
    return null;
  }

  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
