import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/network/api_constants.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';

class AuthService {
  Future<LoginResponse> login(LoginRequest request) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/auth/login');

    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(request.toJson()),
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () => throw Exception(
            'No se pudo conectar con el servidor. Verificá que el backend esté encendido.',
          ),
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

  Future<void> register(RegisterRequest request) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/auth/register');

    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(request.toJson()),
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () => throw Exception(
            'No se pudo conectar con el servidor. Verificá que el backend esté encendido.',
          ),
        );

    if (response.statusCode == 201) {
      return;
    }

    if (response.statusCode == 409) {
      throw Exception('Ya existe una cuenta con ese correo');
    }

    if (response.statusCode == 400) {
      throw Exception(_readApiError(response));
    }

    throw Exception(
      'No se pudo crear la cuenta. Código: ${response.statusCode}',
    );
  }

  String _readApiError(http.Response response) {
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is Map<String, dynamic>) {
        final detail = body['detail'];
        if (detail is String && detail.isNotEmpty) {
          return detail;
        }

        final title = body['title'];
        if (title is String && title.isNotEmpty) {
          return title;
        }
      }
    } on FormatException {
      // La API no devolvio JSON; se muestra un mensaje estable al usuario.
    }

    return 'Revisá los datos ingresados e intentá nuevamente';
  }
}
