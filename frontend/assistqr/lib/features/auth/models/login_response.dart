import 'auth_user.dart';

class LoginResponse {
  final String accessToken;
  final String tokenType;
  final DateTime expiresAtUtc;
  final AuthUser user;

  const LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresAtUtc,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String,
      tokenType: json['tokenType'] as String,
      expiresAtUtc: DateTime.parse(json['expiresAtUtc'] as String),
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
