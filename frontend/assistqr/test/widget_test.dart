import 'package:assistqr/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra el formulario de inicio de sesión', (tester) async {
    await tester.pumpWidget(const AssistQrApp());

    expect(find.text('AssistQR'), findsOneWidget);
    expect(find.byKey(const Key('emailField')), findsOneWidget);
    expect(find.byKey(const Key('passwordField')), findsOneWidget);
    expect(find.byKey(const Key('loginButton')), findsOneWidget);
  });

  testWidgets('valida los campos obligatorios', (tester) async {
    await tester.pumpWidget(const AssistQrApp());

    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pump();

    expect(find.text('Ingresá tu correo electrónico'), findsOneWidget);
    expect(find.text('Ingresá tu contraseña'), findsOneWidget);
  });

  testWidgets('permite mostrar y ocultar la contraseña', (tester) async {
    await tester.pumpWidget(const AssistQrApp());

    TextField passwordField = tester.widget(
      find.byKey(const Key('passwordField')),
    );
    expect(passwordField.obscureText, isTrue);

    await tester.tap(find.byKey(const Key('passwordVisibilityButton')));
    await tester.pump();

    passwordField = tester.widget(find.byKey(const Key('passwordField')));
    expect(passwordField.obscureText, isFalse);
  });
}
