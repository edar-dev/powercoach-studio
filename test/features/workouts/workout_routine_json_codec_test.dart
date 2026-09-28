import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
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

  test('decodeDay ignores legacy coachingNote key', () {
    final legacyDayJson = {
      'id': 'd1',
      'name': 'Day A',
      'exercises': <Map<String, dynamic>>[],
      'coachingNote': 'Keep tempo slow on eccentrics',
    };
    final day = decodeDay(legacyDayJson);
    expect(encodeDay(day).containsKey('coachingNote'), isFalse);
  });

  test('encodeDay never writes coachingNote', () {
    const day = Day(
      id: 'd1',
      name: 'Day A',
      exercises: [],
    );
    expect(encodeDay(day).containsKey('coachingNote'), isFalse);
  });

  test('decodeDay ignores legacy densityBlocks key', () {
    final legacyDayJson = {
      'id': 'd1',
      'name': 'Day A',
      'exercises': [
        {
          'id': 'e1',
          'name': 'Squat',
          'sets': '3',
          'reps': '10',
          'rpe': '',
          'note': '',
          'supersetGroupId': 'ss_123',
        },
      ],
      'densityBlocks': {
        'ss_123': {
          'type': 'circuit',
          'rounds': 3,
          'restSeconds': 90,
        },
      },
    };
    final day = decodeDay(legacyDayJson);
    expect(day.id, 'd1');
    expect(day.exercises.single.supersetGroupId, 'ss_123');
    expect(encodeDay(day).containsKey('densityBlocks'), isFalse);
  });

  test('encodeDay never writes densityBlocks', () {
    const day = Day(
      id: 'd1',
      name: 'Day A',
      exercises: [],
    );
    expect(encodeDay(day).containsKey('densityBlocks'), isFalse);
  });

  test('round-trip drops legacy densityBlocks from envelope', () {
    final payload = {
      'schemaVersion': workoutRoutineJsonSchemaVersion,
      'format': workoutRoutineJsonFormat,
      'routine': {
        'name': 'Plan',
        'mobilitySections': <Map<String, dynamic>>[],
        'mobilityItems': <Map<String, dynamic>>[],
        'phases': [
          {
            'id': 'phase_default',
            'name': 'General',
            'weeks': [
              {
                'id': 'w1',
                'name': 'Week 1',
                'days': [
                  {
                    'id': 'd1',
                    'name': 'Day A',
                    'exercises': [
                      {
                        'id': 'e1',
                        'name': 'Squat',
                        'sets': '3',
                        'reps': '10',
                        'rpe': '',
                        'note': '',
                        'supersetGroupId': 'ss_123',
                      },
                    ],
                    'densityBlocks': {
                      'ss_123': {'type': 'emom', 'intervalSeconds': 60},
                    },
                  },
                ],
              },
            ],
          },
        ],
      },
    };
    final restored = decodeWorkoutRoutineJson(jsonEncode(payload));
    final day = restored.weeks.single.days.single;
    expect(day.exercises.single.supersetGroupId, 'ss_123');
    final reencoded = encodeWorkoutRoutine(restored);
    final reencodedDay =
        (((reencoded['phases'] as List).first as Map)['weeks'] as List)
                .first as Map;
    final dayJson = (reencodedDay['days'] as List).first as Map;
    expect(dayJson.containsKey('densityBlocks'), isFalse);
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
