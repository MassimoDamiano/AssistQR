import 'package:assistqr/features/classes/models/qr_class.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('usa la expiración devuelta por el backend', () {
    final qr = QrClass.fromJson({
      'classSessionId': 42,
      'qrToken': 'token-temporal',
      'qrExpiresAt': '2026-10-06T21:30:00Z',
    });

    expect(qr.classSessionId, 42);
    expect(qr.qrToken, 'token-temporal');
    expect(qr.expiresAtUtc, DateTime.utc(2026, 10, 6, 21, 30));
  });
}
