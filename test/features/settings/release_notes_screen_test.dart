import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/constants/app_info.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/settings/presentation/screens/release_notes_screen.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  testWidgets('release notes screen shows title and installed version', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.light,
        darkTheme: StitchM3Theme.dark,
        themeMode: ThemeMode.dark,
        locale: const Locale('it'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const ReleaseNotesScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Novità'), findsOneWidget);
    expect(
      find.text('Versione installata: $kAppVersionLabel'),
      findsOneWidget,
    );
    expect(find.textContaining('1.0.7'), findsWidgets);
  });
}
