import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
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

  test('mobility item ↔ presentation exercise round-trip', () {
    const item = MobilityItem(
      id: 'i1',
      title: 'World Greatest Stretch',
      subtitle: '3x30s',
      shortTitle: 'WGS',
      sectionId: 's1',
      customExerciseId: 'lib_1',
    );
    final ex = mobilityItemToPresentationExercise(item);
    expect(ex.id, 'i1');
    expect(ex.name, 'World Greatest Stretch');
    expect(ex.note, '3x30s');
    expect(ex.shortName, 'WGS');
    expect(ex.sets, isEmpty);
    expect(ex.reps, isEmpty);
    expect(ex.rpe, isEmpty);
    expect(ex.setDetails, isEmpty);
    expect(ex.customExerciseId, 'lib_1');

    final patched = applyPresentationExerciseToItem(
      ex.copyWith(name: 'Updated', note: 'hold', shortName: 'U'),
      item,
    );
    expect(patched.id, 'i1');
    expect(patched.sectionId, 's1');
    expect(patched.title, 'Updated');
    expect(patched.subtitle, 'hold');
    expect(patched.shortTitle, 'U');
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
    expect(day.exercises[1].name, 'B');
  });

  test('isUnsetMobilitySectionName covers empty and legacy defaults', () {
    expect(isUnsetMobilitySectionName(''), isTrue);
    expect(isUnsetMobilitySectionName('  '), isTrue);
    expect(isUnsetMobilitySectionName('Sezione 1'), isTrue);
    expect(isUnsetMobilitySectionName('Section 2'), isTrue);
    expect(isUnsetMobilitySectionName('Warm-up'), isFalse);
  });
}
