import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:powercoach_studio/core/locale/app_locale_controller.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/settings/presentation/screens/localization_settings_screen.dart';
import 'package:powercoach_studio/features/settings/presentation/widgets/settings_child_shell.dart';
import 'package:powercoach_studio/features/settings/presentation/widgets/settings_hub_nav.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('it');
    await initializeDateFormatting('en');
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await AppLocaleController.instance.load();
    await AppLocaleController.instance.setLocale(const Locale('it'));
  });

  test('format preview uses Italian separators and Monday first day', () {
    final preview = LocalizationFormatPreview.forLanguageCode(
      'it',
      now: DateTime(2026, 11, 2),
    );
    expect(preview.livePreviewLine.contains('kg'), isTrue);
    expect(preview.livePreviewLine.contains(','), isTrue);
    expect(preview.dateFormatLabel.startsWith('DD/MM/YYYY'), isTrue);
    expect(preview.numberFormatLabel.contains('1.234,56'), isTrue);
    expect(preview.firstDayLabel.toLowerCase(), contains('luned'));
    expect(preview.systemTimezoneLabel.contains('GMT'), isTrue);
  });

  test('format preview uses English separators and Sunday first day', () {
    final preview = LocalizationFormatPreview.forLanguageCode(
      'en',
      now: DateTime(2026, 11, 2),
    );
    expect(preview.livePreviewLine.contains('1,250.5'), isTrue);
    expect(preview.dateFormatLabel.startsWith('MM/DD/YYYY'), isTrue);
    expect(preview.numberFormatLabel.contains('1,234.56'), isTrue);
    expect(preview.firstDayLabel.toLowerCase(), contains('sunday'));
  });

  testWidgets('localization screen shows preview and language cards', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        locale: const Locale('it'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const LocalizationSettingsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SettingsChildShell), findsOneWidget);
    expect(find.text('Localizzazione UI'), findsWidgets);
    expect(find.text('ANTEPRIMA LIVE'), findsOneWidget);
    expect(find.text('Italiano'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Formati regionali'), findsOneWidget);
    expect(find.text('Fuso di sistema'), findsOneWidget);

    // Dirty until Apply when switching language.
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Applica localizzazione'), findsOneWidget);
    expect(find.text('Annulla'), findsOneWidget);

    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();
    expect(find.text('Applica localizzazione'), findsNothing);
  });

  testWidgets('wide child shell shows hub nav with language selected', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        locale: const Locale('it'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SettingsChildShell(
          activeSection: SettingsHubSection.language,
          title: 'Localizzazione UI',
          body: const Center(child: Text('body')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SettingsHubNav), findsOneWidget);
    expect(find.text('Lingua e formato'), findsOneWidget);
    expect(find.text('body'), findsOneWidget);
  });
}
