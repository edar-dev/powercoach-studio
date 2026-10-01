import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/training_week_day_panel.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_editor_save_status_indicator.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_plan_details_tab.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_training_tab.dart';
import 'package:powercoach_studio/features/workouts/presentation/workout_builder_session_controller.dart';
import 'package:powercoach_studio/features/workouts/presentation/workout_editor_controller.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

Widget _wrap(Widget child, {double width = 420}) {
  return MaterialApp(
    theme: StitchM3Theme.light,
    darkTheme: StitchM3Theme.dark,
    themeMode: ThemeMode.dark,
    locale: const Locale('it'),
    supportedLocales: const [Locale('it'), Locale('en')],
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(body: SizedBox(width: width, height: 800, child: child)),
  );
}

void main() {
  group('workout builder widgets', () {
    testWidgets('WorkoutEditorSaveStatusIndicator renders save states', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              final theme = Theme.of(context);
              return WorkoutEditorSaveStatusIndicator(
                saveState: WorkoutEditorSaveState.saved,
                l10n: AppLocalizations.of(context),
                colorScheme: theme.colorScheme,
                textTheme: theme.textTheme,
                editorMode: true,
                hasLoadedPlan: true,
              );
            },
          ),
        ),
      );

      expect(find.text('Salvato'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('WorkoutEditorSaveStatusIndicator exposes retry on failure', (
      tester,
    ) async {
      var retried = false;
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              final theme = Theme.of(context);
              return WorkoutEditorSaveStatusIndicator(
                saveState: WorkoutEditorSaveState.failed,
                l10n: AppLocalizations.of(context),
                colorScheme: theme.colorScheme,
                textTheme: theme.textTheme,
                editorMode: true,
                hasLoadedPlan: true,
                onRetry: () => retried = true,
              );
            },
          ),
        ),
      );

      expect(find.text('Salvataggio fallito'), findsOneWidget);
      expect(find.text('Riprova'), findsOneWidget);
      await tester.tap(find.text('Riprova'));
      expect(retried, isTrue);
    });

    testWidgets('TrainingWeekDayPanel calls week and day selection callbacks', (
      tester,
    ) async {
      var selectedWeek = -1;
      var selectedDay = -1;
      final weeks = [
        const Week(
          id: 'w1',
          name: 'Week 1',
          days: [
            Day(id: 'd1', name: 'Day A', exercises: []),
            Day(id: 'd2', name: 'Day B', exercises: []),
          ],
        ),
        const Week(
          id: 'w2',
          name: 'Week 2',
          days: [Day(id: 'd3', name: 'Day C', exercises: [])],
        ),
      ];

      await tester.pumpWidget(
        _wrap(
          width: 720,
          Builder(
            builder: (context) {
              final theme = Theme.of(context);
              return TrainingWeekDayPanel(
                theme: theme,
                cs: theme.colorScheme,
                weeks: weeks,
                selectedWeekIndex: 0,
                selectedDayIndex: 0,
                onSelectWeek: (index) => selectedWeek = index,
                onSelectDay: (index) => selectedDay = index,
                onNewWeek: () {},
                onCloneWeek: (_) {},
                onDeleteWeek: (_) {},
                onEditWeek: (_) {},
                onAddDay: (_) {},
                onEditDay: (_, _) {},
                onDeleteDay: (_, _) {},
                onUpdateScheduledWeekday: (_, _, _) {},
                exerciseListBuilder: (_, _, _, _) => const Text('Exercises'),
              );
            },
          ),
        ),
      );

      // Session-sheet toolbar: open week menu, pick Week 2, then Day B.
      await tester.tap(find.text('Settimana 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(CheckedPopupMenuItem<String>, 'Settimana 2'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Day B'));
      await tester.tap(find.text('Day B'));
      await tester.pump();

      expect(selectedWeek, 1);
      expect(selectedDay, 1);
      expect(find.text('Exercises'), findsOneWidget);
    });

    testWidgets('TrainingWeekDayPanel shows Libero when weekday is null', (
      tester,
    ) async {
      Future<void> pumpPanel({required List<Week> weeks, int dayIndex = 0}) {
        return tester.pumpWidget(
          _wrap(
            width: 720,
            Builder(
              builder: (context) {
                final theme = Theme.of(context);
                return TrainingWeekDayPanel(
                  theme: theme,
                  cs: theme.colorScheme,
                  weeks: weeks,
                  selectedWeekIndex: 0,
                  selectedDayIndex: dayIndex,
                  onSelectWeek: (_) {},
                  onSelectDay: (_) {},
                  onNewWeek: () {},
                  onCloneWeek: (_) {},
                  onDeleteWeek: (_) {},
                  onEditWeek: (_) {},
                  onAddDay: (_) {},
                  onEditDay: (_, _) {},
                  onDeleteDay: (_, _) {},
                  onUpdateScheduledWeekday: (_, _, _) {},
                  exerciseListBuilder: (_, _, _, _) => const Text('Exercises'),
                );
              },
            ),
          ),
        );
      }

      await pumpPanel(
        weeks: [
          const Week(
            id: 'w1',
            name: 'Week 1',
            days: [Day(id: 'd1', name: 'Day A', exercises: [])],
          ),
        ],
      );
      expect(find.text('Libero'), findsOneWidget);

      await pumpPanel(
        weeks: [
          const Week(
            id: 'w1',
            name: 'Week 1',
            days: [
              Day(
                id: 'd1',
                name: 'Day A',
                exercises: [],
                scheduledWeekday: DateTime.wednesday,
              ),
            ],
          ),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('Libero'), findsNothing);
      expect(find.text('mer'), findsOneWidget);
    });

    testWidgets('WorkoutPlanDetailsTab renders dates notes and notifies changes', (
      tester,
    ) async {
      var initialWeek = '';
      var metadataChanged = false;
      final initialWeekController = TextEditingController(text: '1');
      final notesController = TextEditingController(text: 'Coach notes');
      addTearDown(initialWeekController.dispose);
      addTearDown(notesController.dispose);

      await tester.pumpWidget(
        _wrap(
          WorkoutPlanDetailsTab(
            routine: WorkoutRoutine.empty(),
            editorMode: true,
            initialWeekController: initialWeekController,
            notesController: notesController,
            onPickStartDate: () {},
            onPickEndDate: () {},
            onInitialWeekChanged: (value) => initialWeek = value,
            onCurrentWeekChanged: (_) {},
            onMetadataChanged: () => metadataChanged = true,
          ),
        ),
      );

      expect(find.text('Data di inizio'), findsOneWidget);
      expect(find.text('Settimana iniziale'), findsOneWidget);
      expect(find.text('Strength'), findsNothing);

      await tester.enterText(find.byType(TextField).first, '3');
      await tester.pump();
      expect(initialWeek, '3');

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();
      await tester.enterText(find.text('Coach notes'), 'Updated notes');
      await tester.pump();
      expect(metadataChanged, isTrue);
    });

    testWidgets('WorkoutTrainingTab empty phases shows Aggiungi Fase', (
      tester,
    ) async {
      final session = WorkoutBuilderSessionController(
        routine: WorkoutRoutine.empty(),
      );
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              final theme = Theme.of(context);
              return WorkoutTrainingTab(
                theme: theme,
                cs: theme.colorScheme,
                session: session,
                phases: const [],
                selectedPhaseIndex: 0,
                selectedWeekIndex: 0,
                selectedDayIndex: 0,
                onAddPhase: () {},
                onDuplicatePhase: (_) {},
                onEditPhaseSettings: (_) {},
                onDeletePhase: (_) {},
                onSelectPhase: (_) {},
                onNewWeek: () {},
                onCloneWeek: (_) {},
                onDeleteWeek: (_) {},
                onRenameWeek: (_, _) {},
                onAddDay: (_) {},
                onRenameDay: (_, _, _) {},
                onDeleteDay: (_, _) {},
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
                onSelectWeek: (_) {},
                onSelectDay: (_) {},
                onUpdateScheduledWeekday: (_, _, _) {},
              );
            },
          ),
        ),
      );

      expect(find.text('Nessuna fase ancora'), findsOneWidget);
      expect(find.text('Aggiungi Fase'), findsOneWidget);
    });

    testWidgets('WorkoutTrainingTab shows horizontal phase pills and day cards', (
      tester,
    ) async {
      final routine = WorkoutRoutine.empty().copyWith(
        phases: [
          WorkoutRoutine.defaultPhase(
            weeks: const [
              Week(
                id: 'w1',
                name: 'Settimana 1',
                days: [
                  Day(
                    id: 'd1',
                    name: 'Giorno 1',
                    scheduledWeekday: DateTime.monday,
                    exercises: [
                      Exercise(
                        id: 'e1',
                        name: 'Panca piana',
                        sets: '4',
                        reps: '8',
                        rpe: '75kg',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );
      final session = WorkoutBuilderSessionController(routine: routine);
      await tester.pumpWidget(
        _wrap(
          width: 1000,
          Builder(
            builder: (context) {
              final theme = Theme.of(context);
              return WorkoutTrainingTab(
                theme: theme,
                cs: theme.colorScheme,
                session: session,
                phases: routine.phases,
                selectedPhaseIndex: 0,
                selectedWeekIndex: 0,
                selectedDayIndex: 0,
                onAddPhase: () {},
                onDuplicatePhase: (_) {},
                onEditPhaseSettings: (_) {},
                onDeletePhase: (_) {},
                onSelectPhase: (_) {},
                onNewWeek: () {},
                onCloneWeek: (_) {},
                onDeleteWeek: (_) {},
                onRenameWeek: (_, _) {},
                onAddDay: (_) {},
                onRenameDay: (_, _, _) {},
                onDeleteDay: (_, _) {},
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
                onSelectWeek: (_) {},
                onSelectDay: (_) {},
                onUpdateScheduledWeekday: (_, _, _) {},
              );
            },
          ),
        ),
      );

      expect(find.text('FASE 1'), findsOneWidget);
      expect(find.text('Generale'), findsWidgets);
      expect(find.text('Aggiungi Fase'), findsOneWidget);
      expect(find.text('Duplica Fase'), findsOneWidget);
      expect(find.text('Impostazioni Fase'), findsOneWidget);
      expect(find.text('Settimana 1'), findsWidgets);
      expect(find.text('Panca piana'), findsOneWidget);
      expect(find.text('Modifica sessione'), findsOneWidget);
      expect(find.text('Aggiungi Giorno'), findsWidgets);

      await tester.scrollUntilVisible(
        find.text('Modifica sessione'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      await tester.tap(find.text('Modifica sessione'));
      // Phase rail pulse animation prevents pumpAndSettle from completing.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Session editor opens as a fullscreen dialog route, not an inline panel.
      expect(find.textContaining('Modifica Sessione'), findsWidgets);
      expect(find.text('Panca piana'), findsWidgets);
      expect(find.text('Aggiungi esercizio da libreria'), findsOneWidget);
      expect(find.text('Crea Superset / Circuito'), findsOneWidget);
      expect(find.text('Autosalvataggio bozza attivo'), findsOneWidget);
      expect(find.text('Salva modifiche'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('training-add-week')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      expect(find.byKey(const ValueKey('training-add-week')), findsOneWidget);
      expect(find.textContaining('Aggiungi settimana alla fase'), findsOneWidget);

      // No vertical ExpansionTile + week panel chrome.
      expect(find.byType(ExpansionTile), findsNothing);
    });
  });
}
