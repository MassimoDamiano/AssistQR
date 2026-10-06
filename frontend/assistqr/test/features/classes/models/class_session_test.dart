import 'package:assistqr/features/classes/models/class_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('crea una clase desde la respuesta de la API', () {
    final classSession = ClassSession.fromJson({
      'id': 42,
      'subjectId': 7,
      'sessionDate': '2026-10-08',
      'startTime': '08:05:00',
      'endTime': '10:30:00',
      'latitude': -31.4201,
      'longitude': -64.1888,
      'allowedRadiusMeters': 50,
      'status': '',
    });

    expect(classSession.id, 42);
    expect(classSession.subjectId, 7);
    expect(classSession.sessionDate, DateTime(2026, 10, 8));
    expect(classSession.latitude, -31.4201);
    expect(classSession.allowedRadiusMeters, 50);
  });
}
