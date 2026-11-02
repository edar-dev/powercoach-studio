import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_diary_header.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  testWidgets('desktop header owns single Diario & Storico heading', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        locale: const Locale('it'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: WorkoutDiaryHeader(onRecord: () {}),
        ),
      ),
    );

    expect(find.text('Diario & Storico'), findsOneWidget);
    expect(find.text('Storico'), findsNothing);
    expect(find.byIcon(Icons.arrow_back), findsNothing);
    expect(find.text('Registra Sessione'), findsOneWidget);
  });

  testWidgets('phone header owns single Diario & Storico heading', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        locale: const Locale('it'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: WorkoutDiaryHeader(onRecord: () {}),
        ),
      ),
    );

    expect(find.text('Diario & Storico'), findsOneWidget);
    expect(find.text('Storico'), findsNothing);
  });
}
