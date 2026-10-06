import 'package:assistqr/features/attendance/screens/attendance_placeholder_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('aclara que asistencias todavía no está integrada', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: AttendancePlaceholderScreen()),
    );

    expect(find.text('Asistencias próximamente'), findsOneWidget);
    expect(find.textContaining('no ofrece endpoints'), findsOneWidget);
    expect(find.textContaining('datos simulados'), findsOneWidget);
  });
}
