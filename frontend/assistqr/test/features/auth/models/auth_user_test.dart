import 'package:assistqr/features/auth/models/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('crea un usuario con su nombre desde la respuesta de la API', () {
    final user = AuthUser.fromJson({
      'id': 10,
      'firstName': 'Ana',
      'lastName': 'Pérez',
      'email': 'ana@example.com',
      'role': 'STUDENT',
    });

    expect(user.id, 10);
    expect(user.firstName, 'Ana');
    expect(user.lastName, 'Pérez');
    expect(user.email, 'ana@example.com');
    expect(user.role, 'STUDENT');
  });
}
