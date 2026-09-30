import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/settings/presentation/widgets/settings_backup_module.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<void> pumpModule(
    WidgetTester tester, {
    required SettingsBackupModule child,
    Locale locale = const Locale('en'),
    Size surfaceSize = const Size(390, 844),
  }) async {
    await tester.binding.setSurfaceSize(surfaceSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.light,
        darkTheme: StitchM3Theme.dark,
        themeMode: ThemeMode.dark,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: SingleChildScrollView(child: child),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows persist hint and invokes dismiss callback', (tester) async {
    var dismissed = false;

    await pumpModule(
      tester,
      child: SettingsBackupModule(
        onExportBackup: () {},
        onImportBackup: () {},
        onUploadCloudBackup: () {},
        onRestoreCloudBackup: () {},
        showStoragePersistHint: true,
        onDismissStoragePersistHint: () => dismissed = true,
      ),
    );

    expect(
      find.textContaining('browser may clear local data'),
      findsOneWidget,
    );
    expect(find.text('Dismiss'), findsOneWidget);

    await tester.tap(find.text('Dismiss'));
    await tester.pump();
    expect(dismissed, isTrue);
  });

  testWidgets('auto cloud SwitchListTile calls onAutoCloudToggle',
      (tester) async {
    bool? toggledTo;

    await pumpModule(
      tester,
      child: SettingsBackupModule(
        onExportBackup: () {},
        onImportBackup: () {},
        onUploadCloudBackup: () {},
        onRestoreCloudBackup: () {},
        autoCloudEnabled: false,
        onAutoCloudToggle: (value) => toggledTo = value,
      ),
    );

    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();
    expect(toggledTo, isTrue);
  });

  testWidgets('status labels render when timestamps provided', (tester) async {
    await pumpModule(
      tester,
      locale: const Locale('it'),
      child: SettingsBackupModule(
        onExportBackup: () {},
        onImportBackup: () {},
        onUploadCloudBackup: () {},
        onRestoreCloudBackup: () {},
        lastBackupAtLabel: '2026-03-01 10:00',
        lastAutoCloudAtLabel: '2026-03-02 11:00',
        lastCloudSyncAtLabel: '2026-03-03 12:00',
        onPullCloudSync: () {},
      ),
    );

    expect(find.textContaining('2026-03-01 10:00'), findsOneWidget);
    expect(find.textContaining('2026-03-02 11:00'), findsOneWidget);
    expect(find.textContaining('2026-03-03 12:00'), findsOneWidget);
    expect(find.textContaining('Sincronizza da cloud'), findsOneWidget);
    expect(
      find.textContaining('Scarica dati cloud più recenti'),
      findsOneWidget,
    );
  });
}
