import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/auth/presentation/screens/registration_screen.dart';
import 'package:powercoach_studio/features/auth/utils/registration_password_rules.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: StitchM3Theme.light,
    darkTheme: StitchM3Theme.dark,
    themeMode: ThemeMode.dark,
    locale: const Locale('it'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(
      body: Center(
        child: SizedBox(width: 560, height: 1600, child: child),
      ),
    ),
  );
}

void main() {
  group('RegistrationPasswordRules', () {
    test('requires length, digit, and special', () {
      expect(RegistrationPasswordRules.isValid('short1!'), isFalse);
      expect(RegistrationPasswordRules.isValid('longenough'), isFalse);
      expect(RegistrationPasswordRules.isValid('longenough1'), isFalse);
      expect(RegistrationPasswordRules.isValid('longenough!'), isFalse);
      expect(RegistrationPasswordRules.isValid('longenough1!'), isTrue);
    });

    test('strength score increases with criteria', () {
      expect(RegistrationPasswordRules.strengthScore(''), 0);
      expect(RegistrationPasswordRules.strengthScore('abcdefgh'), greaterThan(0));
      expect(
        RegistrationPasswordRules.strengthScore('Abcdefgh1!xx'),
        greaterThanOrEqualTo(3),
      );
    });
  });

  group('RegistrationScreen', () {
    testWidgets('shows invite-only headline and login CTA', (tester) async {
      await tester.pumpWidget(_wrap(const RegistrationScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Accesso solo su invito'), findsOneWidget);
      expect(find.text('Hai già un invito? Accedi'), findsOneWidget);
      expect(find.text('Accesso su invito'), findsWidgets);
      expect(find.textContaining('codici promo Pro'), findsOneWidget);
      expect(find.byType(TextFormField), findsNothing);
    });
  });
}
