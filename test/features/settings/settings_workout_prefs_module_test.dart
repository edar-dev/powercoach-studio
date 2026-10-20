import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/settings/presentation/widgets/settings_workout_prefs_module.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpModule(
    WidgetTester tester, {
    required double selected,
    required ValueChanged<double> onChanged,
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: SettingsWorkoutPrefsModule(
              maximalWeightRoundingKg: selected,
              onRoundingChanged: onChanged,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows three rounding options and reports selection',
      (tester) async {
    double? changedTo;
    await pumpModule(
      tester,
      selected: 2.5,
      onChanged: (kg) => changedTo = kg,
    );

    expect(find.text('0.5 kg'), findsOneWidget);
    expect(find.text('1 kg'), findsOneWidget);
    expect(find.text('2.5 kg'), findsOneWidget);

    await tester.tap(find.text('0.5 kg'));
    await tester.pumpAndSettle();
    expect(changedTo, 0.5);
  });

  testWidgets('Italian locale uses comma decimal labels', (tester) async {
    await pumpModule(
      tester,
      selected: 2.5,
      onChanged: (_) {},
      locale: const Locale('it'),
    );

    expect(find.text('0,5 kg'), findsOneWidget);
    expect(find.text('2,5 kg'), findsOneWidget);
  });
}
