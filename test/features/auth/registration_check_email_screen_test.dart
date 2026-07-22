import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/auth/presentation/screens/registration_check_email_screen.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: StitchM3Theme.light,
    darkTheme: StitchM3Theme.dark,
    themeMode: ThemeMode.dark,
    locale: const Locale('it'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('shows email and resend action', (tester) async {
    await tester.pumpWidget(
      _wrap(const RegistrationCheckEmailScreen(email: 'coach@example.com')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Controlla la tua email'), findsWidgets);
    expect(find.textContaining('coach@example.com'), findsOneWidget);
    expect(find.text('Reinvia email di conferma'), findsOneWidget);
    expect(find.text('Vai al login'), findsOneWidget);
  });
}
