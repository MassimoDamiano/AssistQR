import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/network/api_constants.dart';
import '../models/class_session.dart';
import '../models/create_class_request.dart';
import '../models/teacher_class_summary.dart';

class ClassService {
  static const _timeout = Duration(seconds: 12);

  Future<List<TeacherClassSummary>> getClasses(String accessToken) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/classes');
    final response = await http
        .get(uri, headers: _headers(accessToken))
        .timeout(_timeout, onTimeout: _throwConnectionError);

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return json
          .map(
            (item) =>
                TeacherClassSummary.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false);
    }

    _throwClassesError(response.statusCode);
  }

  Future<ClassSession> createClass(
    CreateClassRequest request,
    String accessToken,
  ) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/classes');
    final response = await http
        .post(
          uri,
          headers: _headers(accessToken),
          body: jsonEncode(request.toJson()),
        )
        .timeout(_timeout, onTimeout: _throwConnectionError);

    if (response.statusCode == 201) {
      final json =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ClassSession.fromJson(json);
    }

    switch (response.statusCode) {
      case 400:
        throw Exception(
          'Revisá la fecha, los horarios, la ubicación y el radio permitido.',
        );
      case 401:
        throw Exception('La sesión venció. Volvé a iniciar sesión.');
      case 403:
        throw Exception('No tenés permisos para crear clases en esta materia.');
      case 404:
        throw Exception('La materia ya no existe.');
      case 409:
        throw Exception('No se pueden crear clases en una materia inactiva.');
      default:
        throw Exception(
          'El servidor no pudo crear la clase. Código: ${response.statusCode}',
        );
    }
  }

  Map<String, String> _headers(String accessToken) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }

  Never _throwConnectionError() {
    throw Exception(
      'No se pudo conectar con el servidor. Verificá que el backend esté encendido.',
    );
  }

  Never _throwClassesError(int statusCode) {
    if (statusCode == 401) {
      throw Exception('La sesión venció. Volvé a iniciar sesión.');
    }
    if (statusCode == 403) {
      throw Exception('No tenés permisos para consultar las clases.');
    }
    throw Exception('No se pudieron cargar las clases. Código: $statusCode');
  }
}
