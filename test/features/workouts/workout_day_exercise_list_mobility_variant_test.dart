import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/exercise_prescription_scope.dart';
import 'package:powercoach_studio/features/workouts/domain/maximal_ref.dart';
import 'package:powercoach_studio/features/workouts/domain/mobility_session_presentation.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/session_exercise_editor_card.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_day_exercise_list.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

MobilityItem _item(
  String id,
  String title, {
  String subtitle = '',
  String shortTitle = '',
}) {
  return MobilityItem(
    id: id,
    title: title,
    subtitle: subtitle,
    shortTitle: shortTitle,
    sectionId: 's1',
  );
}

Day _day(List<MobilityItem> items) {
  return MobilitySectionSessionView(
    section: const MobilitySection(id: 's1', name: ''),
    sectionIndex: 0,
    items: items,
  ).toPresentationDay(lookupAppLocalizations(const Locale('it')));
}

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

WorkoutDayExerciseList _list({
  required Day day,
  void Function(
    int,
    int,
    String, {
    String? name,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
    String? shortName,
    ExercisePrescriptionScope? prescriptionScope,
    List<ExerciseSet>? setDetails,
    MaximalRef? maximalRef,
    bool clearMaximalRef,
  })? onUpdateExercise,
  void Function(int, int)? onAddExercise,
}) {
  return WorkoutDayExerciseList(
    theme: StitchM3Theme.dark,
    colorScheme: StitchM3Theme.dark.colorScheme,
    weekIndex: 0,
    dayIndex: 0,
    day: day,
    variant: SessionListVariant.mobility,
    sessionEditStyle: true,
    onAddExercise: onAddExercise,
    onDuplicateExercise: (_, _, _) {},
    onRemoveExercise: (_, _, _) {},
    onMoveExercise: (_, _, _, {required up}) {},
    onMoveExerciseWithinSuperset: (_, _, _, {required up}) {},
    onUpdateExercise: onUpdateExercise ??
        (
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
    'mobility variant expands first item and shows inline TextFields',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          _list(
            day: _day([
              _item('i1', 'WGS', subtitle: '3x30s', shortTitle: 'WGS'),
            ]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final cards = tester
          .widgetList<SessionExerciseEditorCard>(
            find.byType(SessionExerciseEditorCard),
          )
          .toList();
      expect(cards, hasLength(1));
      expect(cards.single.variant, SessionExerciseEditorVariant.mobility);
      expect(cards.single.expanded, isTrue);
      expect(find.byType(TextField), findsNWidgets(3));
    },
  );

  testWidgets('single expand: expanding second collapses first', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        _list(
          day: _day([
            _item('i1', 'First'),
            _item('i2', 'Second'),
          ]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    var cards = tester
        .widgetList<SessionExerciseEditorCard>(
          find.byType(SessionExerciseEditorCard),
        )
        .toList();
    expect(cards[0].expanded, isTrue);
    expect(cards[1].expanded, isFalse);

    await tester.tap(find.text('Second'));
    await tester.pumpAndSettle();

    cards = tester
        .widgetList<SessionExerciseEditorCard>(
          find.byType(SessionExerciseEditorCard),
        )
        .toList();
    expect(cards[0].expanded, isFalse);
    expect(cards[1].expanded, isTrue);
  });

  testWidgets('editing title updates via onUpdateExercise callback', (
    tester,
  ) async {
    String? updatedId;
    String? updatedName;
    await tester.pumpWidget(
      _wrap(
        _list(
          day: _day([_item('i1', 'WGS')]),
          onUpdateExercise: (
            _,
            _,
            id, {
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
          }) {
            updatedId = id;
            updatedName = name;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Updated WGS');
    await tester.pump(const Duration(milliseconds: 500));

    expect(updatedId, 'i1');
    expect(updatedName, 'Updated WGS');
  });

  testWidgets('auto-expands newly added item and collapses prior', (
    tester,
  ) async {
    var items = [_item('i1', 'First')];
    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                Expanded(child: _list(day: _day(items))),
                TextButton(
                  onPressed: () {
                    setState(() {
                      items = [...items, _item('i2', 'Second')];
                    });
                  },
                  child: const Text('add-item'),
                ),
              ],
            );
          },
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

    await tester.tap(find.text('add-item'));
    await tester.pumpAndSettle();

    cards = tester
        .widgetList<SessionExerciseEditorCard>(
          find.byType(SessionExerciseEditorCard),
        )
        .toList();
    expect(cards, hasLength(2));
    expect(cards[0].expanded, isFalse);
    expect(cards[1].expanded, isTrue);
  });

  testWidgets('empty state Add CTA invokes onAddExercise', (tester) async {
    var added = false;
    await tester.pumpWidget(
      _wrap(
        _list(
          day: _day(const []),
          onAddExercise: (_, _) => added = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SessionDayBottomCtas), findsOneWidget);
    await tester.tap(find.text('Aggiungi esercizio da libreria'));
    await tester.pump();
    expect(added, isTrue);
  });

  testWidgets('populated list shows library CTA that invokes onAddExercise', (
    tester,
  ) async {
    var added = false;
    await tester.pumpWidget(
      _wrap(
        _list(
          day: _day([_item('i1', 'WGS')]),
          onAddExercise: (_, _) => added = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SessionDayBottomCtas), findsOneWidget);
    await tester.tap(find.text('Aggiungi esercizio da libreria'));
    await tester.pump();
    expect(added, isTrue);
  });

  testWidgets('mobility variant hides set table and add-set controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        _list(
          day: _day([_item('i1', 'WGS', subtitle: 'hold')]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(lookupAppLocalizations(const Locale('it')).workoutBuilderAddSet), findsNothing);
    expect(find.byType(TextField), findsNWidgets(3));
  });
}
