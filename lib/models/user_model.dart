import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart'; // Add this package

class User {
  final String id;
  final String email;
  final String? name;

  User({
    required this.id,
    required this.email,
    this.name,
  });

  // Factory constructor to create User from JWT token
  factory User.fromToken(String token) {
    try {
      // Decode the JWT token
      final decodedToken = JwtDecoder.decode(token);

      // Extract user information from token claims
      return User(
        id: decodedToken['id']?.toString() ??
            decodedToken['sub']?.toString() ??
            decodedToken['userId']?.toString() ??
            '',
        email: decodedToken['email']?.toString() ??
            decodedToken['username']?.toString() ??
            '',
        name: decodedToken['name']?.toString() ??
            decodedToken['fullName']?.toString(),
      );
    } catch (e) {
      throw Exception('Failed to decode user from token: $e');
    }
  }

  // Keep existing fromJson for API responses that include user data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
    };
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name)';
  }
}
