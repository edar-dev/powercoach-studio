// Widget tests for PowerCoach Studio UI (no Supabase/plugins required).
// For full e2e with navigation and auth, run integration_test (requires .env and device).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:powercoach_studio/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:powercoach_studio/features/auth/presentation/screens/login_screen.dart';
import 'package:powercoach_studio/features/auth/presentation/screens/registration_screen.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';
import 'package:powercoach_studio/theme/stitch_m3_theme.dart';

Widget _wrapWithApp(Widget child) {
  return MaterialApp(
    theme: StitchM3Theme.light,
    darkTheme: StitchM3Theme.dark,
    themeMode: ThemeMode.dark,
    locale: const Locale('it'),
    supportedLocales: const [Locale('it'), Locale('en')],
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          height: 800,
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  group('Auth screens UI', () {
    testWidgets('Login screen shows form and links', (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithApp(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Accedi'), findsWidgets);
      expect(find.text('Email'), findsWidgets);
      expect(find.text('Password'), findsWidgets);
      expect(find.text('Password dimenticata?'), findsOneWidget);
      expect(find.text('Registrati'), findsOneWidget);
    });

    testWidgets('Login validation shows error when submit empty', (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithApp(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Accedi'));
      await tester.pumpAndSettle();

      expect(
        find.text('Inserisci un\'email valida.').evaluate().isNotEmpty ||
            find.text('Inserisci la password.').evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('Registration screen shows form', (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithApp(const RegistrationScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Registrati'), findsWidgets);
      expect(find.text('Email'), findsWidgets);
      expect(find.text('Password'), findsWidgets);
      expect(find.text('Conferma password'), findsOneWidget);
    });

    testWidgets('Forgot password screen shows form and back link', (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithApp(const ForgotPasswordScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Reimposta password'), findsOneWidget);
      expect(find.text('Invia link'), findsOneWidget);
      expect(find.text('Torna al login'), findsOneWidget);
    });
  });

}
