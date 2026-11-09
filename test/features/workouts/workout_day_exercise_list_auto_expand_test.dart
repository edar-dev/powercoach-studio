import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/session_exercise_editor_card.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_day_exercise_list.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_superset_block.dart';
import 'package:powercoach_studio/features/workouts/presentation/workout_builder_session_controller.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

Exercise _ex(
  String id,
  String name, {
  String? supersetGroupId,
}) {
  return Exercise(
    id: id,
    name: name,
    sets: '3',
    reps: '5',
    rpe: '100kg',
    setDetails: const [
      ExerciseSet(sets: '3', reps: '5', rpe: '100kg'),
    ],
    supersetGroupId: supersetGroupId,
  );
}

WorkoutRoutine _routine(List<Exercise> exercises) {
  return WorkoutRoutine.empty().copyWith(
    phases: [
      WorkoutRoutine.defaultPhase(
        weeks: [
          Week(
            id: 'w1',
            name: 'Settimana 1',
            days: [
              Day(id: 'd1', name: 'Giorno A', exercises: exercises),
            ],
          ),
        ],
      ),
    ],
  );
}

WorkoutDayExerciseList _list({
  required WorkoutBuilderSessionController session,
  required Day day,
}) {
  return WorkoutDayExerciseList(
    theme: StitchM3Theme.dark,
    colorScheme: StitchM3Theme.dark.colorScheme,
    session: session,
    weekIndex: 0,
    dayIndex: 0,
    day: day,
    sessionEditStyle: true,
    onAddExercise: (_, _) {},
    onDuplicateExercise: (_, _, _) {},
    onRemoveExercise: (_, _, _) {},
    onMoveExercise: (_, _, _, {required up}) {},
    onMoveExerciseWithinSuperset: (_, _, _, {required up}) {},
    onUpdateExercise: (
      _,
      _,
      _, {
      name,
      sets,
      reps,
      rpe,
      note,
      shortName,
      prescriptionScope,
      setDetails,
      maximalRef,
      bool clearMaximalRef = false,
    }) {},
    onAddSetToExercise: (_, _, _) {},
    onUpdateExerciseSet: (
      _,
      _,
      _,
      _, {
      line,
      sets,
      reps,
      rpe,
      note,
    }) {},
    onRemoveExerciseSet: (_, _, _, _) {},
    onAssignToSuperset: (_, _, _, _) {},
    onRemoveFromSuperset: (_, _, _) {},
    onAddExerciseToSuperset: (_, _, _) {},
  );
}

void main() {
  testWidgets(
    'auto-expands newly added standalone exercise and collapses prior',
    (tester) async {
      final first = _ex('e1', 'Squat');
      final second = _ex('e2', 'Bench');
      var day = Day(id: 'd1', name: 'Giorno A', exercises: [first]);
      final session = WorkoutBuilderSessionController(
        routine: _routine(day.exercises),
      );
      addTearDown(session.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: StitchM3Theme.light,
          darkTheme: StitchM3Theme.dark,
          themeMode: ThemeMode.dark,
          locale: const Locale('it'),
          supportedLocales: const [Locale('it'), Locale('en')],
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Expanded(child: _list(session: session, day: day)),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          day = day.copyWith(
                            exercises: [...day.exercises, second],
                          );
                        });
                      },
                      child: const Text('add-exercise'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      var cards = tester
          .widgetList<SessionExerciseEditorCard>(
            find.byType(SessionExerciseEditorCard),
          )
          .toList();
      expect(cards, hasLength(1));
      expect(cards.single.expanded, isTrue);

      await tester.tap(find.text('add-exercise'));
      await tester.pumpAndSettle();

      cards = tester
          .widgetList<SessionExerciseEditorCard>(
            find.byType(SessionExerciseEditorCard),
          )
          .toList();
      expect(cards, hasLength(2));
      final byId = {
        for (final c in cards) c.exercise.id: c,
      };
      expect(byId['e1']!.expanded, isFalse);
      expect(byId['e2']!.expanded, isTrue);
      expect(find.text('Aggiungi blocco'), findsOneWidget);
    },
  );

  testWidgets(
    'auto-expands newly added exercise when day started empty',
    (tester) async {
      final added = _ex('e-new', 'Deadlift');
      var day = const Day(id: 'd1', name: 'Giorno A', exercises: []);
      final session = WorkoutBuilderSessionController(
        routine: _routine(const []),
      );
      addTearDown(session.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: StitchM3Theme.light,
          darkTheme: StitchM3Theme.dark,
          themeMode: ThemeMode.dark,
          locale: const Locale('it'),
          supportedLocales: const [Locale('it'), Locale('en')],
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Expanded(child: _list(session: session, day: day)),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          day = day.copyWith(exercises: [added]);
                        });
                      },
                      child: const Text('add-exercise'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SessionExerciseEditorCard), findsNothing);

      await tester.tap(find.text('add-exercise'));
      await tester.pumpAndSettle();

      final card = tester.widget<SessionExerciseEditorCard>(
        find.byType(SessionExerciseEditorCard),
      );
      expect(card.exercise.id, 'e-new');
      expect(card.expanded, isTrue);
    },
  );

  testWidgets(
    'auto-expands superset block when exercise added to group',
    (tester) async {
      final first = _ex('e1', 'Squat');
      final inGroup = _ex('e2', 'Bench', supersetGroupId: 'ss1');
      var day = Day(id: 'd1', name: 'Giorno A', exercises: [first]);
      final session = WorkoutBuilderSessionController(
        routine: _routine(day.exercises),
      );
      addTearDown(session.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: StitchM3Theme.light,
          darkTheme: StitchM3Theme.dark,
          themeMode: ThemeMode.dark,
          locale: const Locale('it'),
          supportedLocales: const [Locale('it'), Locale('en')],
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Expanded(child: _list(session: session, day: day)),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          day = day.copyWith(
                            exercises: [...day.exercises, inGroup],
                          );
                        });
                      },
                      child: const Text('add-to-superset'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('add-to-superset'));
      await tester.pumpAndSettle();

      final cards = tester
          .widgetList<SessionExerciseEditorCard>(
            find.byType(SessionExerciseEditorCard),
          )
          .toList();
      // Standalone e1 collapses; e2 lives inside the expanded superset block.
      expect(
        cards.where((c) => c.exercise.id == 'e1').single.expanded,
        isFalse,
      );
      final block = tester.widget<WorkoutSupersetBlock>(
        find.byType(WorkoutSupersetBlock),
      );
      expect(block.expanded, isTrue);
      expect(block.supersetGroupId, 'ss1');
    },
  );
}
