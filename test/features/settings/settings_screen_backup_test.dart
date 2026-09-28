import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/settings/presentation/screens/settings_screen.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_macos_notifications_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(registerFakeMacOSNotificationsPlatform);

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('settings shows backup export and import actions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.light,
        darkTheme: StitchM3Theme.dark,
        themeMode: ThemeMode.dark,
        locale: const Locale('it'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const SettingsScreen(),
      ),
    );

    // First frame schedules post-frame bootstrap; then await loading.
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // Prefer bounded pumps over pumpAndSettle (hub may keep transient work).
    for (var i = 0; i < 20; i++) {
      if (find.text('Esporta backup').evaluate().isNotEmpty) break;
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.text('Backup offline & Cloud'), findsAtLeastNWidgets(1));
    expect(find.text('Esporta backup'), findsOneWidget);
    expect(find.text('Importa backup'), findsOneWidget);
    expect(
      find.textContaining('Non è una sincronizzazione automatica'),
      findsOneWidget,
    );
  });
}
