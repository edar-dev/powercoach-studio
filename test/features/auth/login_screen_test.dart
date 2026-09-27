import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/auth/presentation/screens/login_screen.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

Widget _wrapWithApp(Widget child) {
  return MaterialApp(
    theme: StitchM3Theme.light,
    darkTheme: StitchM3Theme.dark,
    themeMode: ThemeMode.dark,
    locale: const Locale('it'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(
      body: Center(
        child: SizedBox(width: 480, height: 1200, child: child),
      ),
    ),
  );
}

void main() {
  group('LoginScreen', () {
    testWidgets('shows Stitch dark copy and navigation links', (tester) async {
      await tester.pumpWidget(_wrapWithApp(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Bentornato, Coach!'), findsOneWidget);
      expect(find.text('Accedi al workspace'), findsOneWidget);
      expect(find.text('EMAIL O NOME UTENTE'), findsOneWidget);
      expect(find.text('PASSWORD'), findsWidgets);
      expect(find.text('Password dimenticata?'), findsOneWidget);
      expect(find.text('Registrati gratis'), findsOneWidget);
      expect(find.text('Coach / Trainer'), findsOneWidget);
      expect(find.text('Atleta'), findsOneWidget);
    });

    testWidgets('shows validation errors when submitted empty', (tester) async {
      await tester.pumpWidget(_wrapWithApp(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Accedi al workspace'));
      await tester.tap(find.text('Accedi al workspace'));
      await tester.pumpAndSettle();

      expect(
        find.text('Inserisci un\'email valida.').evaluate().isNotEmpty ||
            find.text('Inserisci la password.').evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('athlete role shows unavailable snackbar', (tester) async {
      await tester.pumpWidget(_wrapWithApp(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Atleta'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('accesso atleta', findRichText: true),
        findsOneWidget,
      );
    });
  });
}
