import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/customers/data/models/customer_exercise_record.dart';
import 'package:powercoach_studio/features/customers/domain/customer_progress_metrics.dart';
import 'package:powercoach_studio/features/dashboard/domain/plan_calendar_event.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_api_model.dart';
import 'package:powercoach_studio/features/workouts/domain/session_execution.dart';
import 'package:powercoach_studio/features/workouts/domain/session_execution_service.dart';

void main() {
  final now = DateTime(2026, 6, 15);
  final t = DateTime(2020, 1, 1);

  WorkoutPlanApiModel plan(String id) => WorkoutPlanApiModel(
    id: id,
    customerId: 'c1',
    userId: 'coach',
    name: 'Block A',
    planData: '{"weeks":[]}',
    createdAt: t,
    updatedAt: t,
  );

  SessionExecutionEntry execution({
    required PlanSessionStatus status,
    required DateTime sessionDate,
  }) {
    return SessionExecutionEntry(
      planId: 'p1',
      customerId: 'c1',
      planName: 'Block A',
      execution: SessionExecution(
        sessionKey: '0-0',
        weekIndex: 0,
        dayIndex: 0,
        sessionDate: sessionDate,
        status: status,
        completedAt: sessionDate,
      ),
    );
  }

  test('build returns no-data snapshot when inputs are empty', () {
    final snapshot = CustomerProgressMetrics.build(
      customerId: 'c1',
      plans: const [],
      exerciseRecords: const [],
      allExecutions: const [],
      now: now,
    );
    expect(snapshot.hasAnyData, isFalse);
    expect(snapshot.adherencePercent, isNull);
  });

  test('build computes adherence and recent PR highlights', () {
    final snapshot = CustomerProgressMetrics.build(
      customerId: 'c1',
      plans: [plan('p1')],
      exerciseRecords: [
        CustomerExerciseRecord(
          id: 'r1',
          customerId: 'c1',
          customExerciseId: 'ex-squat',
          exerciseName: 'Squat',
          value: 120,
          unit: 'kg',
          recordedAt: DateTime(2026, 6, 1),
          createdAt: t,
          updatedAt: t,
        ),
      ],
      allExecutions: [
        execution(
          status: PlanSessionStatus.completed,
          sessionDate: DateTime(2026, 6, 14),
        ),
        execution(
          status: PlanSessionStatus.skipped,
          sessionDate: DateTime(2026, 6, 12),
        ),
      ],
      now: now,
    );

    expect(snapshot.hasAnyData, isTrue);
    expect(snapshot.adherencePercent, closeTo(0.5, 0.001));
    expect(snapshot.completedSessions30d, 1);
    expect(snapshot.skippedSessions30d, 1);
    expect(snapshot.recentPrs, hasLength(1));
    expect(snapshot.recentPrs.first.exerciseName, 'Squat');
    expect(snapshot.lastSessionDate, DateTime(2026, 6, 14));
  });
}
