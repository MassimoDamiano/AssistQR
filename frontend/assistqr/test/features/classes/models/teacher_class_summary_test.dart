import 'package:assistqr/features/classes/models/teacher_class_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('crea el resumen de una clase desde la API', () {
    final summary = TeacherClassSummary.fromJson({
      'classSessionId': 14,
      'subjectId': 3,
      'subjectName': 'Programación I',
      'sessionDate': '2026-10-06',
      'startTime': '18:00:00',
      'endTime': '20:00:00',
      'attendanceCount': 12,
      'status': 'SCHEDULED',
    });

    expect(summary.classSessionId, 14);
    expect(summary.subjectName, 'Programación I');
    expect(summary.sessionDate, DateTime(2026, 10, 6));
    expect(summary.startTime, '18:00:00');
    expect(summary.attendanceCount, 12);
    expect(summary.isClosed, isFalse);
  });

  test('reconoce una clase cerrada', () {
    final summary = TeacherClassSummary.fromJson({
      'classSessionId': 15,
      'subjectId': 3,
      'subjectName': 'Programación I',
      'sessionDate': '2026-10-06',
      'startTime': '18:00:00',
      'endTime': '20:00:00',
      'attendanceCount': 20,
      'status': 'CLOSED',
    });

    expect(summary.isClosed, isTrue);
  });
}
