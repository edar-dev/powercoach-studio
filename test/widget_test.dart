// Widget tests for PowerCoach Studio UI (no Supabase/plugins required).
// Login smoke tests live in test/features/auth/login_screen_test.dart.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:powercoach_studio/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:powercoach_studio/features/auth/presentation/screens/registration_screen.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

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
