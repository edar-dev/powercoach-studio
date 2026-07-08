import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/domain/exercise_prescription_scope.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/exercise_prescription_scope_selector.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_superset_panel.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: StitchM3Theme.light,
    darkTheme: StitchM3Theme.dark,
    themeMode: ThemeMode.dark,
    locale: const Locale('it'),
    supportedLocales: const [Locale('it'), Locale('en')],
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('WorkoutSupersetPanel renders heading and add action', (
    tester,
  ) async {
    var added = false;
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            final theme = Theme.of(context);
            return WorkoutSupersetPanel(
              theme: theme,
              colorScheme: theme.colorScheme,
              onAddExercise: () => added = true,
              children: const [Text('Squat')],
            );
          },
        ),
      ),
    );

    expect(find.text('SUPER SET'), findsOneWidget);
    expect(find.text('Squat'), findsOneWidget);
    await tester.tap(find.text('Aggiungi esercizio'));
    expect(added, isTrue);
  });

  testWidgets('WorkoutSupersetPanel manage action opens editor callback', (
    tester,
  ) async {
    var managed = false;
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            final theme = Theme.of(context);
            return WorkoutSupersetPanel(
              theme: theme,
              colorScheme: theme.colorScheme,
              prescriptionSummary: '3 × 12',
              onOpenEditor: () => managed = true,
              onAddExercise: () {},
              children: const [Text('Curl'), Text('French press')],
            );
          },
        ),
      ),
    );

    expect(find.text('3 × 12'), findsOneWidget);
    await tester.tap(find.text('Gestisci'));
    expect(managed, isTrue);
  });

  testWidgets('ExercisePrescriptionScopeSelector toggles scope', (
    tester,
  ) async {
    var scope = ExercisePrescriptionScope.perWeek;
    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) => ExercisePrescriptionScopeSelector(
            value: scope,
            onChanged: (value) => setState(() => scope = value),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(scope, ExercisePrescriptionScope.allWeeks);
  });
}
