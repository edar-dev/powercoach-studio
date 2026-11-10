import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/exercise_prescription_scope.dart';
import 'package:powercoach_studio/features/workouts/domain/maximal_ref.dart';
import 'package:powercoach_studio/features/workouts/domain/mobility_session_presentation.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('it'));

  test('empty section name displays Sezione N on synthetic day', () {
    const view = MobilitySectionSessionView(
      section: MobilitySection(id: 's1', name: ''),
      sectionIndex: 0,
      items: [],
    );
    final day = view.toPresentationDay(l10n);
    expect(day.id, 's1');
    expect(day.name, 'Sezione 1');
    expect(day.exercises, isEmpty);
  });

  test('custom section name is preserved on synthetic day', () {
    const view = MobilitySectionSessionView(
      section: MobilitySection(id: 's2', name: 'Warm-up'),
      sectionIndex: 1,
      items: [],
    );
    expect(view.toPresentationDay(l10n).name, 'Warm-up');
  });

  test('mobility item ↔ presentation exercise full prescription round-trip', () {
    const item = MobilityItem(
      id: 'i1',
      title: 'World Greatest Stretch',
      subtitle: 'hold end range',
      shortTitle: 'WGS',
      sectionId: 's1',
      customExerciseId: 'lib_1',
      sets: '3',
      reps: '30s',
      rpe: '8',
      setDetails: [
        ExerciseSet(sets: '3', reps: '30s', rpe: '8', note: 'set note'),
      ],
      prescriptionScope: ExercisePrescriptionScope.allWeeks,
      maximalRef: MaximalRef.measurement(lift: MaximalLift.squat),
    );
    final ex = mobilityItemToPresentationExercise(item);
    expect(ex.id, 'i1');
    expect(ex.name, 'World Greatest Stretch');
    expect(ex.note, 'hold end range');
    expect(ex.shortName, 'WGS');
    expect(ex.sets, '3');
    expect(ex.reps, '30s');
    expect(ex.rpe, '8');
    expect(ex.setDetails, hasLength(1));
    expect(ex.setDetails!.single.reps, '30s');
    expect(ex.setDetails!.single.note, 'set note');
    expect(ex.prescriptionScope, ExercisePrescriptionScope.allWeeks);
    expect(ex.maximalRef?.lift, MaximalLift.squat);
    expect(ex.customExerciseId, 'lib_1');

    final patched = applyPresentationExerciseToItem(
      ex.copyWith(
        name: 'Updated',
        note: 'hold',
        shortName: 'U',
        sets: '2',
        reps: '20s',
        rpe: '7',
        setDetails: const [
          ExerciseSet(sets: '2', reps: '20s', rpe: '7'),
        ],
        prescriptionScope: ExercisePrescriptionScope.perWeek,
        clearMaximalRef: true,
      ),
      item,
      clearMaximalRef: true,
    );
    expect(patched.id, 'i1');
    expect(patched.sectionId, 's1');
    expect(patched.title, 'Updated');
    expect(patched.subtitle, 'hold');
    expect(patched.shortTitle, 'U');
    expect(patched.sets, '2');
    expect(patched.reps, '20s');
    expect(patched.rpe, '7');
    expect(patched.setDetails, hasLength(1));
    expect(patched.setDetails!.single.reps, '20s');
    expect(patched.prescriptionScope, ExercisePrescriptionScope.perWeek);
    expect(patched.maximalRef, isNull);
    expect(patched.customExerciseId, 'lib_1');
  });

  test('toPresentationDay maps items to synthetic exercises', () {
    const view = MobilitySectionSessionView(
      section: MobilitySection(id: 's1', name: 'Sezione 1'),
      sectionIndex: 0,
      items: [
        MobilityItem(
          id: 'i1',
          title: 'A',
          subtitle: 'sub',
          shortTitle: 'a',
          sectionId: 's1',
          sets: '3',
          reps: '30s',
        ),
        MobilityItem(
          id: 'i2',
          title: 'B',
          subtitle: '',
          sectionId: 's1',
        ),
      ],
    );
    final day = view.toPresentationDay(l10n);
    expect(day.exercises, hasLength(2));
    expect(day.exercises[0].name, 'A');
    expect(day.exercises[0].note, 'sub');
    expect(day.exercises[0].sets, '3');
    expect(day.exercises[0].reps, '30s');
    expect(day.exercises[1].name, 'B');
  });

  test('note-only edit does not persist seeded empty setDetails on legacy', () {
    const legacy = MobilityItem(
      id: 'i1',
      title: 'Cat-cow',
      subtitle: '10 reps',
      sectionId: 's1',
    );
    final seeded = mobilityItemToPresentationExercise(legacy);
    expect(seeded.setDetails, isNotEmpty);
    expect(mobilitySetDetailsAreMeaningful(seeded.setDetails), isFalse);

    final patched = applyPresentationExerciseToItem(
      seeded.copyWith(note: 'slow breaths'),
      legacy,
    );
    expect(patched.subtitle, 'slow breaths');
    expect(patched.setDetails, isNull);
    expect(patched.sets, isEmpty);
    expect(patched.reps, isEmpty);
  });

  test('mobilityItemPreviewDetail prefers prescription then subtitle', () {
    const withRx = MobilityItem(
      id: 'i1',
      title: 'WGS',
      subtitle: 'note',
      shortTitle: 'W',
      sectionId: 's1',
      setDetails: [ExerciseSet(sets: '3', reps: '30s')],
    );
    expect(mobilityItemPreviewDetail(withRx), contains('30s'));

    const legacy = MobilityItem(
      id: 'i2',
      title: 'WGS',
      subtitle: 'hold',
      shortTitle: 'W',
      sectionId: 's1',
    );
    expect(mobilityItemPreviewDetail(legacy), 'hold');

    const shortOnly = MobilityItem(
      id: 'i3',
      title: 'WGS',
      subtitle: '',
      shortTitle: 'W',
      sectionId: 's1',
    );
    expect(mobilityItemPreviewDetail(shortOnly), 'W');
  });

  test('isUnsetMobilitySectionName covers empty and legacy defaults', () {
    expect(isUnsetMobilitySectionName(''), isTrue);
    expect(isUnsetMobilitySectionName('  '), isTrue);
    expect(isUnsetMobilitySectionName('Sezione 1'), isTrue);
    expect(isUnsetMobilitySectionName('Section 2'), isTrue);
    expect(isUnsetMobilitySectionName('Warm-up'), isFalse);
  });
}
