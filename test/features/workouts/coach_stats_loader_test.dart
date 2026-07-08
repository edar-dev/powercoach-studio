import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/dashboard/domain/plan_calendar_event.dart';
import 'package:powercoach_studio/features/workouts/domain/coach_stats_loader.dart';
import 'package:powercoach_studio/features/workouts/domain/session_execution.dart';
import 'package:powercoach_studio/features/workouts/domain/session_execution_service.dart';

void main() {
  final now = DateTime(2026, 6, 15);

  SessionExecutionEntry entry({
    required String customerId,
    required PlanSessionStatus status,
    required DateTime sessionDate,
  }) {
    return SessionExecutionEntry(
      planId: 'plan-1',
      customerId: customerId,
      planName: 'Strength',
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

  test('computeCoachStats returns null adherence when no logged sessions', () {
    final snapshot = CoachStatsLoader.computeCoachStats(
      entries: const [],
      periodDays: 7,
      now: now,
    );
    expect(snapshot.adherenceRate, isNull);
    expect(snapshot.completedSessions, 0);
    expect(snapshot.skippedSessions, 0);
    expect(snapshot.activeClients, 0);
  });

  test('computeCoachStats counts adherence and active clients in window', () {
    final snapshot = CoachStatsLoader.computeCoachStats(
      entries: [
        entry(
          customerId: 'c1',
          status: PlanSessionStatus.completed,
          sessionDate: DateTime(2026, 6, 14),
        ),
        entry(
          customerId: 'c1',
          status: PlanSessionStatus.skipped,
          sessionDate: DateTime(2026, 6, 13),
        ),
        entry(
          customerId: 'c2',
          status: PlanSessionStatus.completed,
          sessionDate: DateTime(2026, 6, 10),
        ),
        entry(
          customerId: 'c3',
          status: PlanSessionStatus.completed,
          sessionDate: DateTime(2026, 5, 1),
        ),
      ],
      periodDays: 7,
      now: now,
    );

    expect(snapshot.completedSessions, 2);
    expect(snapshot.skippedSessions, 1);
    expect(snapshot.adherenceRate, closeTo(2 / 3, 0.001));
    expect(snapshot.activeClients, 2);
    expect(snapshot.dailyCompleted, hasLength(7));
    final june14 = snapshot.dailyCompleted.firstWhere(
      (point) => point.date == DateTime(2026, 6, 14),
    );
    expect(june14.completedCount, 1);
  });

  test('computeCoachStats builds daily completed buckets', () {
    final snapshot = CoachStatsLoader.computeCoachStats(
      entries: [
        entry(
          customerId: 'c1',
          status: PlanSessionStatus.completed,
          sessionDate: DateTime(2026, 6, 14),
        ),
        entry(
          customerId: 'c1',
          status: PlanSessionStatus.completed,
          sessionDate: DateTime(2026, 6, 14),
        ),
      ],
      periodDays: 7,
      now: now,
    );

    final targetDay = snapshot.dailyCompleted.firstWhere(
      (point) => point.date == DateTime(2026, 6, 14),
    );
    expect(targetDay.completedCount, 2);
  });
}
