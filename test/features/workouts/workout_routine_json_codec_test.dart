import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/density_block.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_routine_json_codec.dart';

void main() {
  test('round-trip envelope preserves routine fields', () {
    final routine = WorkoutRoutine.empty().copyWith(name: 'Test Plan');
    final jsonText = encodeWorkoutRoutineJson(routine);
    final restored = decodeWorkoutRoutineJson(jsonText);

    expect(restored.name, 'Test Plan');
    expect(restored.weeks.length, routine.weeks.length);
  });

  test('decodes raw planData object without envelope', () {
    final routine = WorkoutRoutine.empty().copyWith(name: 'Legacy');
    final jsonText = jsonEncode(routine.toJson());
    final restored = decodeWorkoutRoutineJson(jsonText);

    expect(restored.name, 'Legacy');
  });

  test('round-trip preserves session occurrence overrides', () {
    final routine = WorkoutRoutine.empty().copyWith(
      startDate: DateTime(2026, 6, 16),
      sessionOverrides: {'0-0-2026-06-16': const SessionOverride.skipped()},
    );
    final jsonText = encodeWorkoutRoutineJson(routine);
    final restored = decodeWorkoutRoutineJson(jsonText);
    expect(restored.sessionOverrides.containsKey('0-0-2026-06-16'), isTrue);
    expect(
      restored.sessionOverrides['0-0-2026-06-16']?.kind,
      SessionOverrideKind.skipped,
    );
  });

  test('round-trip preserves day coaching note', () {
    final routine = WorkoutRoutine.empty().copyWith(
      weeks: [
        const Week(
          id: 'w1',
          name: 'Week 1',
          days: [
            Day(
              id: 'd1',
              name: 'Day A',
              exercises: [],
              coachingNote: 'Keep tempo slow on eccentrics',
            ),
          ],
        ),
      ],
    );
    final jsonText = encodeWorkoutRoutineJson(routine);
    final restored = decodeWorkoutRoutineJson(jsonText);

    expect(
      restored.weeks.single.days.single.coachingNote,
      'Keep tempo slow on eccentrics',
    );
  });

  test('decodes legacy day JSON without coachingNote as null', () {
    final legacyDayJson = {
      'id': 'd1',
      'name': 'Day A',
      'exercises': <Map<String, dynamic>>[],
    };
    final day = decodeDay(legacyDayJson);
    expect(day.coachingNote, isNull);
  });

  test('encodeDay omits blank coaching note', () {
    const day = Day(
      id: 'd1',
      name: 'Day A',
      exercises: [],
      coachingNote: '   ',
    );
    expect(encodeDay(day).containsKey('coachingNote'), isFalse);
  });

  test('round-trip preserves day densityBlocks', () {
    final routine = WorkoutRoutine.empty().copyWith(
      weeks: [
        Week(
          id: 'w1',
          name: 'Week 1',
          days: [
            Day(
              id: 'd1',
              name: 'Day A',
              exercises: const [
                Exercise(
                  id: 'e1',
                  name: 'Squat',
                  sets: '3',
                  reps: '10',
                  rpe: '',
                  note: '',
                  supersetGroupId: 'ss_123',
                ),
              ],
              densityBlocks: const {
                'ss_123': DensityBlockConfig(
                  type: DensityBlockType.circuit,
                  rounds: 3,
                  restSeconds: 90,
                ),
              },
            ),
          ],
        ),
      ],
    );
    final jsonText = encodeWorkoutRoutineJson(routine);
    final restored = decodeWorkoutRoutineJson(jsonText);
    final day = restored.weeks.single.days.single;
    expect(day.densityBlocks?['ss_123']?.type, DensityBlockType.circuit);
    expect(day.densityBlocks?['ss_123']?.rounds, 3);
    expect(day.densityBlocks?['ss_123']?.restSeconds, 90);
  });

  test('decodes legacy day JSON without densityBlocks as null', () {
    final legacyDayJson = {
      'id': 'd1',
      'name': 'Day A',
      'exercises': <Map<String, dynamic>>[],
    };
    final day = decodeDay(legacyDayJson);
    expect(day.densityBlocks, isNull);
  });

  test('encodeDay omits empty densityBlocks map', () {
    const day = Day(
      id: 'd1',
      name: 'Day A',
      exercises: [],
      densityBlocks: {},
    );
    expect(encodeDay(day).containsKey('densityBlocks'), isFalse);
  });

  test('rejects unsupported schema version', () {
    final payload = {
      'schemaVersion': 99,
      'format': workoutRoutineJsonFormat,
      'routine': WorkoutRoutine.empty().toJson(),
    };
    expect(
      () => decodeWorkoutRoutineJson(jsonEncode(payload)),
      throwsFormatException,
    );
  });

  test('encodes phases and round-trips multi-phase routines', () {
    final routine = WorkoutRoutine.empty().copyWith(
      name: 'Phased',
      phases: [
        const Phase(
          id: 'p1',
          name: 'Accumulo',
          objective: 'Volume',
          weeks: [
            Week(
              id: 'w1',
              name: 'Week 1',
              days: [Day(id: 'd1', name: 'Day A', exercises: [])],
            ),
          ],
        ),
        const Phase(
          id: 'p2',
          name: 'Picco',
          weeks: [
            Week(
              id: 'w2',
              name: 'Week 2',
              days: [Day(id: 'd2', name: 'Day B', exercises: [])],
            ),
          ],
        ),
      ],
    );
    final encoded = encodeWorkoutRoutine(routine);
    expect(encoded.containsKey('phases'), isTrue);
    expect(encoded.containsKey('weeks'), isFalse);
    expect((encoded['phases'] as List), hasLength(2));

    final restored = decodeWorkoutRoutine(encoded);
    expect(restored.phases, hasLength(2));
    expect(restored.phases.first.name, 'Accumulo');
    expect(restored.phases.first.objective, 'Volume');
    expect(restored.weeks, hasLength(2));
    expect(restored.globalWeekIndex(1, 0), 1);
    expect(restored.locateWeek(1)?.phaseIndex, 1);
  });

  test('decodes legacy flat weeks into default General phase', () {
    final legacy = {
      'name': 'Legacy Plan',
      'mobilitySections': <Map<String, dynamic>>[],
      'mobilityItems': <Map<String, dynamic>>[],
      'weeks': [
        {
          'id': 'w1',
          'name': 'Week 1',
          'days': [
            {'id': 'd1', 'name': 'Day A', 'exercises': <Map<String, dynamic>>[]},
          ],
        },
      ],
    };
    final restored = decodeWorkoutRoutine(legacy);
    expect(restored.phases, hasLength(1));
    expect(restored.phases.single.id, kDefaultPhaseId);
    expect(restored.phases.single.name, kDefaultPhaseName);
    expect(restored.weeks.single.id, 'w1');
  });
}
