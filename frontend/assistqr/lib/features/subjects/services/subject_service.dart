import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/network/api_constants.dart';
import '../models/subject.dart';

class SubjectService {
  Future<List<Subject>> getSubjects(String accessToken) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/subjects');
    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;

      return json
          .map((item) => Subject.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    }

    if (response.statusCode == 401) {
      throw Exception('La sesión venció. Volvé a iniciar sesión.');
    }

    if (response.statusCode == 403) {
      throw Exception('No tenés permisos para consultar las materias.');
    }

    throw Exception(
      'No se pudieron cargar las materias. Código: ${response.statusCode}',
    );
  }
}
