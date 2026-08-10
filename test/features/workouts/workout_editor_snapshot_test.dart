import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/dashboard/domain/plan_calendar_event.dart';
import 'package:powercoach_studio/features/workouts/domain/session_execution.dart';
import 'package:powercoach_studio/features/workouts/presentation/workout_editor_snapshot.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';

void main() {
  test('snapshot remains clean when inputs match baseline', () {
    final routine = WorkoutRoutine.empty().copyWith(name: 'Plan A');
    final saved = buildWorkoutEditorSnapshot(
      routine: routine,
      planName: 'Plan A',
      initialWeekNumber: 1,
      phase: 'Hypertrophy',
      tags: 'upper',
      notes: 'intro block',
    );

    final current = buildWorkoutEditorSnapshot(
      routine: routine,
      planName: 'Plan A',
      initialWeekNumber: 1,
      phase: 'Hypertrophy',
      tags: 'upper',
      notes: 'intro block',
    );

    expect(
      isWorkoutEditorDirty(savedSnapshot: saved, currentSnapshot: current),
      isFalse,
    );
  });

  test('snapshot detects plan metadata changes', () {
    final routine = WorkoutRoutine.empty().copyWith(name: 'Plan A');
    final saved = buildWorkoutEditorSnapshot(
      routine: routine,
      planName: 'Plan A',
      initialWeekNumber: 1,
      phase: 'Strength',
    );
    final current = buildWorkoutEditorSnapshot(
      routine: routine,
      planName: 'Plan A',
      initialWeekNumber: 2,
      phase: 'Strength',
    );

    expect(
      isWorkoutEditorDirty(savedSnapshot: saved, currentSnapshot: current),
      isTrue,
    );
  });

  test('snapshot detects routine structure changes', () {
    final baseline = WorkoutRoutine.empty().copyWith(
      name: 'Plan B',
      weeks: const [],
    );
    final updated = baseline.copyWith(
      weeks: [
        const Week(
          id: 'w1',
          name: 'Week 1',
          days: [Day(id: 'd1', name: 'Day 1', exercises: [])],
        ),
      ],
    );

    final saved = buildWorkoutEditorSnapshot(
      routine: baseline,
      planName: 'Plan B',
      initialWeekNumber: 1,
    );
    final current = buildWorkoutEditorSnapshot(
      routine: updated,
      planName: 'Plan B',
      initialWeekNumber: 1,
    );

    expect(
      isWorkoutEditorDirty(savedSnapshot: saved, currentSnapshot: current),
      isTrue,
    );
  });

  test('routine fingerprint detects set and session execution changes', () {
    final baseline = WorkoutRoutine.empty().copyWith(
      weeks: [
        const Week(
          id: 'w1',
          name: 'Week 1',
          days: [
            Day(
              id: 'd1',
              name: 'Day 1',
              exercises: [
                Exercise(
                  id: 'e1',
                  name: 'Squat',
                  sets: '1',
                  reps: '5',
                  rpe: '',
                  setDetails: [ExerciseSet(reps: '5')],
                ),
              ],
            ),
          ],
        ),
      ],
    );
    final updated = baseline.copyWith(
      weeks: [
        Week(
          id: 'w1',
          name: 'Week 1',
          days: [
            Day(
              id: 'd1',
              name: 'Day 1',
              exercises: [
                const Exercise(
                  id: 'e1',
                  name: 'Squat',
                  sets: '1',
                  reps: '6',
                  rpe: '',
                  setDetails: [ExerciseSet(reps: '6')],
                ),
              ],
            ),
          ],
        ),
      ],
      sessionExecutions: {
        '0-0': SessionExecution(
          sessionKey: '0-0',
          weekIndex: 0,
          dayIndex: 0,
          sessionDate: DateTime(2026, 6, 1),
          status: PlanSessionStatus.completed,
        ),
      },
    );

    expect(
      buildWorkoutRoutineFingerprint(updated),
      isNot(buildWorkoutRoutineFingerprint(baseline)),
    );
  });

  test('routine fingerprint detects day coaching note changes', () {
    final baseline = WorkoutRoutine.empty().copyWith(
      weeks: [
        const Week(
          id: 'w1',
          name: 'Week 1',
          days: [Day(id: 'd1', name: 'Day 1', exercises: [])],
        ),
      ],
    );
    final updated = baseline.copyWith(
      weeks: [
        const Week(
          id: 'w1',
          name: 'Week 1',
          days: [
            Day(
              id: 'd1',
              name: 'Day 1',
              exercises: [],
              coachingNote: 'Warm up thoroughly',
            ),
          ],
        ),
      ],
    );

    expect(
      buildWorkoutRoutineFingerprint(updated),
      isNot(buildWorkoutRoutineFingerprint(baseline)),
    );
  });

  test('routine fingerprint detects check-in RPE/pain changes', () {
    final baseline = WorkoutRoutine.empty().copyWith(
      sessionExecutions: {
        '0-0': SessionExecution(
          sessionKey: '0-0',
          weekIndex: 0,
          dayIndex: 0,
          sessionDate: DateTime(2026, 6, 1),
          status: PlanSessionStatus.completed,
        ),
      },
    );
    final updated = baseline.copyWith(
      sessionExecutions: {
        '0-0': SessionExecution(
          sessionKey: '0-0',
          weekIndex: 0,
          dayIndex: 0,
          sessionDate: DateTime(2026, 6, 1),
          status: PlanSessionStatus.completed,
          sessionRpe: 8,
          painLevel: 2,
          painLocation: 'left knee',
        ),
      },
    );

    expect(
      buildWorkoutRoutineFingerprint(updated),
      isNot(buildWorkoutRoutineFingerprint(baseline)),
    );
  });
}
