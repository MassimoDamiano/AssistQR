import 'package:assistqr/features/classes/models/teacher_class_summary.dart';
import 'package:assistqr/features/classes/models/class_session.dart';
import 'package:assistqr/features/classes/models/create_class_request.dart';
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

  test('crea una clase y expone la respuesta', () async {
    final createdClass = _createdClass();
    final provider = ClassProvider(
      classService: _FakeClassService(const [], createdClass: createdClass),
    );

    final success = await provider.createClass(_request(), 'token');

    expect(success, isTrue);
    expect(provider.createdClass, same(createdClass));
    expect(provider.createErrorMessage, isNull);
    expect(provider.isCreating, isFalse);
  });

  test('expone el error al crear una clase', () async {
    final provider = ClassProvider(
      classService: _FakeClassService.error('No se pudo crear'),
    );

    final success = await provider.createClass(_request(), 'token');

    expect(success, isFalse);
    expect(provider.createdClass, isNull);
    expect(provider.createErrorMessage, 'No se pudo crear');
    expect(provider.isCreating, isFalse);
  });
}

CreateClassRequest _request() {
  return CreateClassRequest(
    subjectId: 10,
    sessionDate: DateTime(2026, 10, 8),
    startTime: (hour: 18, minute: 0),
    endTime: (hour: 20, minute: 0),
    latitude: -31.4201,
    longitude: -64.1888,
    allowedRadiusMeters: 50,
  );
}

ClassSession _createdClass() {
  return ClassSession(
    id: 42,
    subjectId: 10,
    sessionDate: DateTime(2026, 10, 8),
    startTime: '18:00:00',
    endTime: '20:00:00',
    latitude: -31.4201,
    longitude: -64.1888,
    allowedRadiusMeters: 50,
    status: '',
  );
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
  _FakeClassService(this._classes, {this.createdClass}) : _error = null;

  _FakeClassService.error(this._error)
    : _classes = const [],
      createdClass = null;

  final List<TeacherClassSummary> _classes;
  final String? _error;
  final ClassSession? createdClass;

  @override
  Future<List<TeacherClassSummary>> getClasses(String accessToken) async {
    if (_error != null) {
      throw Exception(_error);
    }
    return _classes;
  }

  @override
  Future<ClassSession> createClass(
    CreateClassRequest request,
    String accessToken,
  ) async {
    if (_error != null) {
      throw Exception(_error);
    }
    return createdClass!;
  }
}
