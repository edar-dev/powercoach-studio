import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_editor_app_bar.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

Future<void> _pumpAppBar(
  WidgetTester tester, {
  required bool showLogSessionAction,
  required bool logSessionEnabled,
  VoidCallback? onLogSession,
  VoidCallback? onLogSessionUnavailable,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: StitchM3Theme.dark,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final l10n = AppLocalizations.of(context);
          return Scaffold(
            appBar: WorkoutEditorAppBar(
              theme: theme,
              colorScheme: theme.colorScheme,
              l10n: l10n,
              editorMode: true,
              loading: false,
              hideExportMenu: true,
              saving: false,
              showManualSaveButton: false,
              onBack: () async {},
              onImportJson: () {},
              onExport: (_) {},
              onSave: () {},
              showLogSessionAction: showLogSessionAction,
              logSessionEnabled: logSessionEnabled,
              onLogSession: onLogSession,
              onLogSessionUnavailable: onLogSessionUnavailable,
            ),
          );
        },
      ),
    ),
  );
}

Finder _logSessionButton() => find.byTooltip('Log session');

void main() {
  testWidgets('log session button present and enabled when logSessionEnabled', (
    tester,
  ) async {
    var logged = false;
    await _pumpAppBar(
      tester,
      showLogSessionAction: true,
      logSessionEnabled: true,
      onLogSession: () => logged = true,
    );

    expect(_logSessionButton(), findsOneWidget);
    expect(find.byIcon(Icons.edit_note_outlined), findsOneWidget);

    await tester.tap(_logSessionButton());
    await tester.pump();
    expect(logged, isTrue);
  });

  testWidgets('log session unavailable path for sandbox / disabled', (
    tester,
  ) async {
    var unavailable = false;
    var logged = false;
    await _pumpAppBar(
      tester,
      showLogSessionAction: true,
      logSessionEnabled: false,
      onLogSession: () => logged = true,
      onLogSessionUnavailable: () => unavailable = true,
    );

    expect(_logSessionButton(), findsOneWidget);
    await tester.tap(_logSessionButton());
    await tester.pump();
    expect(unavailable, isTrue);
    expect(logged, isFalse);
  });

  testWidgets('log session button hidden when showLogSessionAction is false', (
    tester,
  ) async {
    await _pumpAppBar(
      tester,
      showLogSessionAction: false,
      logSessionEnabled: false,
    );

    expect(_logSessionButton(), findsNothing);
    expect(find.byIcon(Icons.edit_note_outlined), findsNothing);
  });
}
