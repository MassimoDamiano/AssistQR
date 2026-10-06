import 'package:assistqr/features/classes/models/create_class_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializa la clase con el formato esperado por la API', () {
    final request = CreateClassRequest(
      subjectId: 7,
      sessionDate: DateTime(2026, 10, 8),
      startTime: (hour: 8, minute: 5),
      endTime: (hour: 10, minute: 30),
      latitude: -31.4201,
      longitude: -64.1888,
      allowedRadiusMeters: 50,
    );

    expect(request.toJson(), {
      'subjectId': 7,
      'sessionDate': '2026-10-08',
      'startTime': '08:05:00',
      'endTime': '10:30:00',
      'latitude': -31.4201,
      'longitude': -64.1888,
      'allowedRadiusMeters': 50,
    });
  });
}
