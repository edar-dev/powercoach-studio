import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/auth/access_waitlist.dart';
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
      body: SizedBox(width: 560, height: 2000, child: child),
    ),
  );
}

Future<void> _pumpRegistration(
  WidgetTester tester, {
  RegistrationScreen screen = const RegistrationScreen(),
}) async {
  await tester.binding.setSurfaceSize(const Size(800, 2200));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(_wrap(screen));
  await tester.pumpAndSettle();
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
    testWidgets('shows invite-only headline, login CTA, and waitlist form',
        (tester) async {
      await _pumpRegistration(tester);

      expect(find.text('Accesso solo su invito'), findsOneWidget);
      expect(find.text('Hai già un invito? Accedi'), findsOneWidget);
      expect(find.text('Accesso su invito'), findsWidgets);
      expect(find.textContaining('codici promo Pro'), findsOneWidget);
      expect(find.text('Richiedi accesso'), findsOneWidget);
      expect(find.text('Invia richiesta'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));
    });

    testWidgets('submits waitlist and shows success', (tester) async {
      var called = false;
      await _pumpRegistration(
        tester,
        screen: RegistrationScreen(
          onRequestAccess: ({
            required String email,
            String? name,
            String? note,
          }) async {
            called = true;
            expect(email.trim(), 'coach@studio.it');
            expect(name?.trim(), 'Ada');
            expect(note?.trim(), 'Beta');
            return const AccessWaitlistResult();
          },
        ),
      );

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'coach@studio.it');
      await tester.enterText(fields.at(1), 'Ada');
      await tester.enterText(fields.at(2), 'Beta');
      final submit = find.text('Invia richiesta');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();

      expect(called, isTrue);
      expect(
        find.text('Richiesta inviata. Ti contatteremo via email con l\'invito.'),
        findsWidgets,
      );
    });

    testWidgets('shows already-pending snackbar', (tester) async {
      await _pumpRegistration(
        tester,
        screen: RegistrationScreen(
          onRequestAccess: ({
            required String email,
            String? name,
            String? note,
          }) async {
            return const AccessWaitlistResult(alreadyPending: true);
          },
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, 'a@b.co');
      final submit = find.text('Invia richiesta');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();

      expect(
        find.text('Hai già una richiesta in attesa per questa email.'),
        findsOneWidget,
      );
    });
  });
}
