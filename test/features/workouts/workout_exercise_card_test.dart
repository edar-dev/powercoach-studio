import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_exercise_card.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

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
  testWidgets(
    'shows set note inline and hides exercise note placeholder',
    (tester) async {
      var expanded = true;
      final exercise = Exercise(
        id: 'ex1',
        name: 'Good Morning',
        sets: '3',
        reps: '5',
        rpe: '@9',
        note: '',
        setDetails: [
          const ExerciseSet(
            sets: '3',
            reps: '5',
            rpe: '@9',
            note: 'Fermo 2"',
          ),
        ],
      );

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) {
              final theme = Theme.of(context);
              return WorkoutExerciseCard(
                theme: theme,
                colorScheme: theme.colorScheme,
                exercise: exercise,
                expanded: expanded,
                onExpandedChanged: (value) =>
                    setState(() => expanded = value),
              );
            },
          ),
        ),
      );

      expect(find.text('Fermo 2"'), findsOneWidget);
      expect(find.text('Aggiungi nota…'), findsNothing);
      // Expanded: header prescription hidden; set row still shows it.
      expect(find.text('3x5 @9'), findsOneWidget);
    },
  );

  testWidgets(
    'collapsed shows prescription; expanded hides header duplicate',
    (tester) async {
      var expanded = false;
      final exercise = Exercise(
        id: 'ex1',
        name: 'Good Morning',
        sets: '3',
        reps: '5',
        rpe: '@9',
        setDetails: [
          const ExerciseSet(sets: '3', reps: '5', rpe: '@9'),
        ],
      );

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) {
              final theme = Theme.of(context);
              return WorkoutExerciseCard(
                theme: theme,
                colorScheme: theme.colorScheme,
                exercise: exercise,
                expanded: expanded,
                onExpandedChanged: (value) =>
                    setState(() => expanded = value),
              );
            },
          ),
        ),
      );

      expect(find.text('3x5 @9'), findsOneWidget);

      await tester.tap(find.text('Good Morning'));
      await tester.pump();
      expect(expanded, isTrue);
      // Still one: set row only (header prescription hidden).
      expect(find.text('3x5 @9'), findsOneWidget);
      expect(find.text('Aggiungi nota…'), findsOneWidget);
    },
  );

  testWidgets(
    'shows exercise-level note when present',
    (tester) async {
      final exercise = Exercise(
        id: 'ex1',
        name: 'Squat',
        sets: '3',
        reps: '5',
        rpe: '@8',
        note: 'Brace hard',
        setDetails: [
          const ExerciseSet(sets: '3', reps: '5', rpe: '@8'),
        ],
      );

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              final theme = Theme.of(context);
              return WorkoutExerciseCard(
                theme: theme,
                colorScheme: theme.colorScheme,
                exercise: exercise,
                expanded: true,
                onExpandedChanged: (_) {},
              );
            },
          ),
        ),
      );

      expect(find.text('Brace hard'), findsOneWidget);
      expect(find.text('Aggiungi nota…'), findsNothing);
    },
  );
}
