import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/training_session_edit_sheet.dart';
import 'package:powercoach_studio/features/workouts/presentation/workout_builder_session_controller.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

WorkoutRoutine _routineWithExercise() {
  return WorkoutRoutine.empty().copyWith(
    phases: [
      WorkoutRoutine.defaultPhase(
        weeks: const [
          Week(
            id: 'w1',
            name: 'Settimana 1',
            days: [
              Day(
                id: 'd1',
                name: 'Giorno A',
                exercises: [
                  Exercise(
                    id: 'e1',
                    name: 'Squat',
                    sets: '3',
                    reps: '5',
                    rpe: '100kg',
                    setDetails: [
                      ExerciseSet(sets: '3', reps: '5', rpe: '100kg'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

Widget _wrap(
  Widget child, {
  required Size size,
  EdgeInsets padding = EdgeInsets.zero,
}) {
  return MaterialApp(
    theme: StitchM3Theme.light,
    darkTheme: StitchM3Theme.dark,
    themeMode: ThemeMode.dark,
    locale: const Locale('it'),
    supportedLocales: const [Locale('it'), Locale('en')],
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: MediaQuery(
      data: MediaQueryData(size: size, padding: padding),
      child: child,
    ),
  );
}

TrainingSessionEditBody _body(
  BuildContext context,
  WorkoutBuilderSessionController session,
  Day day,
) {
  final theme = Theme.of(context);
  return TrainingSessionEditBody(
    theme: theme,
    cs: theme.colorScheme,
    session: session,
    day: day,
    globalWeekIndex: 0,
    dayIndex: 0,
    onRenameDay: () {},
    onDeleteDay: () {},
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
    onClose: () {},
  );
}

void main() {
  testWidgets('phone session edit pins Salva modifiche in sticky footer', (
    tester,
  ) async {
    const phone = Size(390, 844);
    await tester.binding.setSurfaceSize(phone);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final session = WorkoutBuilderSessionController(
      routine: _routineWithExercise(),
    );
    final day = session.routine.weeks.first.days.first;

    await tester.pumpWidget(
      _wrap(
        size: phone,
        Builder(builder: (context) => _body(context, session, day)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Salva modifiche'), findsOneWidget);
    expect(find.text('Aggiungi esercizio da libreria'), findsOneWidget);
    expect(find.text('Crea Superset / Circuito'), findsOneWidget);
    // Header Cancel should be hidden on phone sticky path.
    expect(find.text('Annulla'), findsNothing);
  });

  testWidgets('phone sticky footer absorbs home-indicator padding', (
    tester,
  ) async {
    const phone = Size(390, 844);
    const homeIndicator = EdgeInsets.only(bottom: 34);
    await tester.binding.setSurfaceSize(phone);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final session = WorkoutBuilderSessionController(
      routine: _routineWithExercise(),
    );
    final day = session.routine.weeks.first.days.first;

    await tester.pumpWidget(
      _wrap(
        size: phone,
        padding: homeIndicator,
        Builder(builder: (context) => _body(context, session, day)),
      ),
    );
    await tester.pumpAndSettle();

    final saveLabel = find.text('Salva modifiche');
    expect(saveLabel, findsOneWidget);
    // Header Cancel stays off the sticky phone path.
    expect(find.text('Annulla'), findsNothing);

    // Footer padding includes safe-area bottom so the CTA clears the gesture bar.
    final footerPadding = tester.widgetList<Padding>(find.byType(Padding)).where(
      (p) {
        final value = p.padding;
        return value is EdgeInsets &&
            value.left == 16 &&
            value.right == 16 &&
            value.bottom >= 10 + homeIndicator.bottom;
      },
    );
    expect(footerPadding, isNotEmpty);

    // Geometric: Salva label clears the home-indicator band.
    final saveRect = tester.getRect(saveLabel);
    expect(saveRect.bottom, lessThanOrEqualTo(phone.height - 34));
    // Sticky CTA uses FilledButton.icon with minimumSize height 48; find the
    // nearest Material ink response / sized box via the check icon chrome.
    expect(find.byIcon(Icons.check), findsWidgets);
    final checkIcon = find.descendant(
      of: find.byWidgetPredicate(
        (w) =>
            w is SizedBox &&
            w.width == double.infinity,
      ),
      matching: find.byIcon(Icons.check),
    );
    expect(checkIcon, findsOneWidget);
    final ctaBox = find.ancestor(
      of: checkIcon,
      matching: find.byWidgetPredicate(
        (w) => w is SizedBox && w.width == double.infinity,
      ),
    );
    expect(tester.getSize(ctaBox.first).height, greaterThanOrEqualTo(48));
  });

  testWidgets('phone landscape keeps sticky Salva with compact header', (
    tester,
  ) async {
    const landscapePhone = Size(844, 390);
    await tester.binding.setSurfaceSize(landscapePhone);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final session = WorkoutBuilderSessionController(
      routine: _routineWithExercise(),
    );
    final day = session.routine.weeks.first.days.first;

    await tester.pumpWidget(
      _wrap(
        size: landscapePhone,
        Builder(builder: (context) => _body(context, session, day)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Salva modifiche'), findsOneWidget);
    // Metrics bar is hidden in landscape compact mode (no 4-tile strip).
    expect(find.byIcon(Icons.grid_view_rounded), findsNothing);
    expect(find.byIcon(Icons.timer_outlined), findsNothing);
    expect(find.text('Annulla'), findsNothing);
  });

  testWidgets('desktop session edit keeps header Salva modifiche', (
    tester,
  ) async {
    const desktop = Size(1200, 900);
    await tester.binding.setSurfaceSize(desktop);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final session = WorkoutBuilderSessionController(
      routine: _routineWithExercise(),
    );
    final day = session.routine.weeks.first.days.first;

    await tester.pumpWidget(
      _wrap(
        size: desktop,
        Builder(builder: (context) => _body(context, session, day)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Salva modifiche'), findsOneWidget);
    expect(find.text('Annulla'), findsOneWidget);
  });
}
