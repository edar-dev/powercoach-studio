import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/dashboard/domain/dashboard_coach_tools_hints.dart';
import 'package:powercoach_studio/features/dashboard/domain/plan_calendar_event.dart';
import 'package:powercoach_studio/features/workouts/domain/session_execution.dart';
import 'package:powercoach_studio/features/workouts/domain/session_execution_service.dart';

void main() {
  SessionExecutionEntry entry({
    required String customerId,
    required DateTime sessionDate,
    required PlanSessionStatus status,
  }) {
    return SessionExecutionEntry(
      planId: 'p1',
      customerId: customerId,
      planName: 'Plan',
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

  test('computeDashboardCoachToolsHints counts 30d sessions and 7d adherence', () {
    final now = DateTime(2026, 7, 8);
    final hints = computeDashboardCoachToolsHints(
      now: now,
      entries: [
        entry(
          customerId: 'c1',
          sessionDate: DateTime(2026, 7, 7),
          status: PlanSessionStatus.completed,
        ),
        entry(
          customerId: 'c1',
          sessionDate: DateTime(2026, 7, 6),
          status: PlanSessionStatus.skipped,
        ),
        entry(
          customerId: 'c2',
          sessionDate: DateTime(2026, 6, 1),
          status: PlanSessionStatus.completed,
        ),
      ],
    );

    expect(hints.loggedSessions30d, 2);
    expect(hints.adherence7dPercent, 50);
  });
}
