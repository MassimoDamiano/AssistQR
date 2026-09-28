import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/network/api_constants.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class AuthService {
  Future<LoginResponse> login(LoginRequest request) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/auth/login');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final json =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      return LoginResponse.fromJson(json);
    }

    if (response.statusCode == 401) {
      throw Exception('Correo o contraseña incorrectos');
    }

    throw Exception(
      'No se pudo iniciar sesión. Código: ${response.statusCode}',
    );
  }
}
