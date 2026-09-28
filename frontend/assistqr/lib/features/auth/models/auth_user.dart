class AuthUser {
  final int id;
  final String email;
  final String role;

  const AuthUser({required this.id, required this.email, required this.role});

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }
}
