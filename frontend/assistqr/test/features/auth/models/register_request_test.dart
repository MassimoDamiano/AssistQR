import 'package:assistqr/features/auth/models/register_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializa los campos esperados por la API', () {
    const request = RegisterRequest(
      firstName: 'Ana',
      lastName: 'Pérez',
      email: 'ana@example.com',
      password: 'secreto123',
    );

    expect(request.toJson(), {
      'firstName': 'Ana',
      'lastName': 'Pérez',
      'email': 'ana@example.com',
      'password': 'secreto123',
    });
  });
}
