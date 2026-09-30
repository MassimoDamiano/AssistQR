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

    final passwordInput = find.descendant(
      of: find.byKey(const Key('passwordField')),
      matching: find.byType(EditableText),
    );
    EditableText passwordField = tester.widget(passwordInput);
    expect(passwordField.obscureText, isTrue);

    await tester.tap(find.byKey(const Key('passwordVisibilityButton')));
    await tester.pump();

    passwordField = tester.widget(passwordInput);
    expect(passwordField.obscureText, isFalse);
  });

  testWidgets('abre el formulario de registro de estudiantes', (tester) async {
    await tester.pumpWidget(const AssistQrApp());

    await tester.ensureVisible(find.text('Registrate'));
    await tester.tap(find.text('Registrate'));
    await tester.pumpAndSettle();

    expect(find.text('Registrate en AssistQR'), findsOneWidget);
    expect(find.byKey(const Key('firstNameField')), findsOneWidget);
    expect(find.byKey(const Key('lastNameField')), findsOneWidget);
    expect(find.byKey(const Key('registerEmailField')), findsOneWidget);
    expect(find.byKey(const Key('registerPasswordField')), findsOneWidget);
    expect(find.byKey(const Key('confirmPasswordField')), findsOneWidget);
  });

  testWidgets('valida los campos obligatorios del registro', (tester) async {
    await tester.pumpWidget(const AssistQrApp());

    await tester.ensureVisible(find.text('Registrate'));
    await tester.tap(find.text('Registrate'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('registerButton')));
    await tester.tap(find.byKey(const Key('registerButton')));
    await tester.pump();

    expect(find.text('Ingresá tu nombre'), findsOneWidget);
    expect(find.text('Ingresá tu apellido'), findsOneWidget);
    expect(find.text('Ingresá tu correo electrónico'), findsOneWidget);
    expect(find.text('Ingresá una contraseña'), findsOneWidget);
    expect(find.text('Repetí tu contraseña'), findsOneWidget);
  });
}
