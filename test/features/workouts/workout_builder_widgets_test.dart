import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/training_week_day_panel.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_editor_save_status_indicator.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_plan_details_tab.dart';
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

    testWidgets(
      'TrainingWeekDayPanel shows day coaching note and notifies tap',
      (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          _wrap(
            width: 720,
            Builder(
              builder: (context) {
                final theme = Theme.of(context);
                return TrainingWeekDayPanel(
                  theme: theme,
                  cs: theme.colorScheme,
                  weeks: const [
                    Week(
                      id: 'w1',
                      name: 'Week 1',
                      days: [
                        Day(
                          id: 'd1',
                          name: 'Day A',
                          exercises: [],
                          coachingNote: 'Focus on bracing',
                        ),
                      ],
                    ),
                  ],
                  selectedWeekIndex: 0,
                  selectedDayIndex: 0,
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
                  onEditDayCoachingNote: (_, _) => tapped = true,
                  exerciseListBuilder: (_, _, _, _) => const Text('Exercises'),
                );
              },
            ),
          ),
        );

        expect(find.text('Focus on bracing'), findsOneWidget);
        await tester.tap(find.text('Focus on bracing'));
        await tester.pump();
        expect(tapped, isTrue);
      },
    );

    testWidgets('WorkoutPlanDetailsTab renders metadata and notifies changes', (
      tester,
    ) async {
      var initialWeek = '';
      var metadataChanged = false;
      final initialWeekController = TextEditingController(text: '1');
      final phaseController = TextEditingController(text: 'Strength');
      final tagsController = TextEditingController(text: 'hypertrophy');
      final notesController = TextEditingController(text: 'Coach notes');
      addTearDown(initialWeekController.dispose);
      addTearDown(phaseController.dispose);
      addTearDown(tagsController.dispose);
      addTearDown(notesController.dispose);

      await tester.pumpWidget(
        _wrap(
          WorkoutPlanDetailsTab(
            routine: WorkoutRoutine.empty(),
            editorMode: true,
            initialWeekController: initialWeekController,
            phaseController: phaseController,
            tagsController: tagsController,
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

      await tester.enterText(find.byType(TextField).first, '3');
      await tester.pump();
      expect(initialWeek, '3');

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();
      await tester.enterText(find.text('Strength'), 'Power');
      await tester.pump();
      expect(metadataChanged, isTrue);
    });
  });
}
