import 'package:assistqr/features/classes/models/teacher_class_summary.dart';
import 'package:assistqr/features/classes/providers/class_provider.dart';
import 'package:assistqr/features/classes/services/class_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('filtra las clases cargadas por materia', () async {
    final service = _FakeClassService([
      _classSummary(classSessionId: 1, subjectId: 10),
      _classSummary(classSessionId: 2, subjectId: 20),
      _classSummary(classSessionId: 3, subjectId: 10),
    ]);
    final provider = ClassProvider(classService: service);

    await provider.loadClasses('token');

    final subjectClasses = provider.classesForSubject(10);
    expect(subjectClasses.map((item) => item.classSessionId), [1, 3]);
    expect(provider.errorMessage, isNull);
    expect(provider.isLoading, isFalse);
  });

  test('expone el error del servicio y limpia el listado', () async {
    final provider = ClassProvider(
      classService: _FakeClassService.error('Error del servidor'),
    );

    await provider.loadClasses('token');

    expect(provider.classes, isEmpty);
    expect(provider.errorMessage, 'Error del servidor');
    expect(provider.isLoading, isFalse);
  });
}

TeacherClassSummary _classSummary({
  required int classSessionId,
  required int subjectId,
}) {
  return TeacherClassSummary(
    classSessionId: classSessionId,
    subjectId: subjectId,
    subjectName: 'Materia $subjectId',
    sessionDate: DateTime(2026, 10, 6),
    startTime: '18:00:00',
    endTime: '20:00:00',
    attendanceCount: 0,
    status: 'SCHEDULED',
  );
}

class _FakeClassService extends ClassService {
  _FakeClassService(this._classes) : _error = null;

  _FakeClassService.error(this._error) : _classes = const [];

  final List<TeacherClassSummary> _classes;
  final String? _error;

  @override
  Future<List<TeacherClassSummary>> getClasses(String accessToken) async {
    if (_error != null) {
      throw Exception(_error);
    }
    return _classes;
  }
}
