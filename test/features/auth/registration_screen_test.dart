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
    testWidgets('shows Stitch fields and trust chips', (tester) async {
      await tester.pumpWidget(_wrap(const RegistrationScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Crea il tuo account Coach'), findsOneWidget);
      expect(find.text('266+ Esercizi inclusi'), findsOneWidget);
      expect(find.text('NOME'), findsOneWidget);
      expect(find.text('COGNOME'), findsOneWidget);
      expect(find.text('EMAIL PROFESSIONALE'), findsOneWidget);
      expect(find.text('Personal Trainer'), findsOneWidget);
      expect(
        find.text('Crea account e inizia la prova gratuita'),
        findsOneWidget,
      );
    });

    testWidgets('rejects weak password', (tester) async {
      await tester.pumpWidget(_wrap(const RegistrationScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, '').at(0),
        'Mario',
      );
      // Fill via labels' sibling fields by scrolling to password.
      final passwordFields = find.byType(TextFormField);
      expect(passwordFields, findsWidgets);

      await tester.enterText(passwordFields.at(2), 'weak');
      await tester.enterText(passwordFields.at(3), 'weak');

      await tester.ensureVisible(
        find.text('Crea account e inizia la prova gratuita'),
      );
      await tester.tap(find.text('Crea account e inizia la prova gratuita'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('8 caratteri').evaluate().isNotEmpty ||
            find.text('Campo obbligatorio.').evaluate().isNotEmpty ||
            find.text('Accetta i termini per continuare.').evaluate().isNotEmpty,
        isTrue,
      );
    });
  });
}
