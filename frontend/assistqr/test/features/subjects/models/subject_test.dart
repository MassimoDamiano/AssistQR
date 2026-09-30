import 'package:assistqr/features/subjects/models/subject.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('crea una materia desde la respuesta de la API', () {
    final subject = Subject.fromJson({
      'id': 7,
      'name': 'Programación I',
      'description': 'Introducción a la programación',
      'teacherId': 3,
      'isActive': true,
    });

    expect(subject.id, 7);
    expect(subject.name, 'Programación I');
    expect(subject.description, 'Introducción a la programación');
    expect(subject.teacherId, 3);
    expect(subject.isActive, isTrue);
  });

  test('acepta una descripción nula', () {
    final subject = Subject.fromJson({
      'id': 8,
      'name': 'Base de Datos',
      'description': null,
      'teacherId': 3,
      'isActive': false,
    });

    expect(subject.description, isNull);
    expect(subject.isActive, isFalse);
  });
}
