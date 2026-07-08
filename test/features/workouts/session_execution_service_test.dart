import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/dashboard/domain/plan_calendar_event.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_api_model.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/session_execution.dart';
import 'package:powercoach_studio/features/workouts/domain/session_execution_service.dart';

void main() {
  WorkoutPlanApiModel planWithExecutions(Map<String, dynamic> executions) {
    final routine = {
      'name': 'Test',
      'mobilitySections': [],
      'mobilityItems': [],
      'weeks': [],
      'sessionExecutions': executions,
    };
    final now = DateTime(2026, 6, 15);
    return WorkoutPlanApiModel(
      id: 'plan-1',
      customerId: 'cust-1',
      userId: 'u1',
      name: 'Test plan',
      planData: jsonEncode(routine),
      createdAt: now,
      updatedAt: now,
    );
  }

  test('adherenceRateForPlan returns completed ratio in range', () {
    final service = SessionExecutionService();
    final plan = planWithExecutions({
      '0-0': SessionExecution(
        sessionKey: '0-0',
        weekIndex: 0,
        dayIndex: 0,
        sessionDate: DateTime(2026, 6, 10),
        status: PlanSessionStatus.completed,
      ).toJson(),
      '0-1': SessionExecution(
        sessionKey: '0-1',
        weekIndex: 0,
        dayIndex: 1,
        sessionDate: DateTime(2026, 6, 12),
        status: PlanSessionStatus.skipped,
      ).toJson(),
    });

    final rate = service.adherenceRateForPlan(
      plan,
      from: DateTime(2026, 6, 1),
      to: DateTime(2026, 6, 30),
    );
    expect(rate, closeTo(0.5, 0.001));
  });

  test('adherenceRateForPlan returns null when no executions', () {
    final service = SessionExecutionService();
    expect(service.adherenceRateForPlan(planWithExecutions({})), isNull);
  });

  test('WorkoutRoutine round-trips sessionExecutions in planData', () {
    final execution = SessionExecution(
      sessionKey: '0-0',
      weekIndex: 0,
      dayIndex: 0,
      sessionDate: DateTime(2026, 6, 10),
      status: PlanSessionStatus.completed,
      exercises: const [
        ExecutedExercise(exerciseId: 'e1', name: 'Squat', completed: true),
      ],
    );
    final routine = WorkoutRoutine.empty().copyWith(
      sessionExecutions: {'0-0': execution},
    );
    final restored = WorkoutRoutine.fromJson(routine.toJson());
    expect(restored.sessionExecutions, hasLength(1));
    expect(restored.sessionExecutions['0-0']!.exercises.first.name, 'Squat');
  });

  test('upsertStatusStub persists exercise sets in planData', () async {
    final execution = SessionExecution(
      sessionKey: '0-0',
      weekIndex: 0,
      dayIndex: 0,
      sessionDate: DateTime(2026, 6, 10),
      status: PlanSessionStatus.completed,
      exercises: const [
        ExecutedExercise(
          exerciseId: 'e1',
          name: 'Squat',
          completed: true,
          sets: [
            ExecutedSet(reps: '5', load: '100', completed: true),
          ],
        ),
      ],
    );
    final json = execution.toJson();
    final restored = SessionExecution.fromJson(json);
    expect(restored.exercises.first.sets.first.reps, '5');
    expect(restored.exercises.first.sets.first.load, '100');
  });
}
