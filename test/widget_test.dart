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
        // Match login_screen_test harness: 400px overflows auth top bar /
        // password meter rows on the Stitch dark auth layout.
        child: SizedBox(
          width: 480,
          height: 1200,
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

      expect(find.text('Crea il tuo account Coach'), findsOneWidget);
      // AuthDarkTextField uppercases field labels.
      expect(find.text('EMAIL PROFESSIONALE'), findsOneWidget);
      expect(find.text('PASSWORD'), findsWidgets);
      expect(find.text('CONFERMA PASSWORD'), findsOneWidget);
      expect(
        find.text('Crea account e inizia la prova gratuita'),
        findsOneWidget,
      );
    });

    testWidgets('Forgot password screen shows form and back link', (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithApp(const ForgotPasswordScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Reimposta password'), findsOneWidget);
      expect(find.text('Invia link'), findsOneWidget);
      // Header back link + in-form link both use the same copy.
      expect(find.text('Torna al login'), findsAtLeastNWidgets(1));
    });
  });

}
