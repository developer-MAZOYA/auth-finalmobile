import 'package:auth_final/models/user_model.dart';

class AuthResponse {
  final String token;
  final User user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    if (json['token'] == null) {
      throw Exception('Token is missing in auth response');
    }

    final token = json['token'] as String;

    return AuthResponse(
      token: token,
      // Create user from token instead of separate user object
      user: User.fromToken(token),
    );
  }

  @override
  String toString() {
    return 'AuthResponse(token: $token, user: $user)';
  }
}
