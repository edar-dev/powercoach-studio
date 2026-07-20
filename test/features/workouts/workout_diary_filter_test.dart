import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/dashboard/domain/plan_calendar_event.dart';
import 'package:powercoach_studio/features/workouts/domain/session_execution.dart';
import 'package:powercoach_studio/features/workouts/domain/session_execution_service.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_diary_filter.dart';

SessionExecutionEntry _entry({
  required String planId,
  required String sessionKey,
  required String customerId,
}) {
  return SessionExecutionEntry(
    planId: planId,
    customerId: customerId,
    planName: 'Plan',
    execution: SessionExecution(
      sessionKey: sessionKey,
      weekIndex: 0,
      dayIndex: 0,
      sessionDate: DateTime(2026, 6, 10),
      status: PlanSessionStatus.completed,
    ),
  );
}

void main() {
  test('filterDiaryEntries filters by planId and sessionKey', () {
    final entries = [
      _entry(planId: 'p1', sessionKey: '0-0', customerId: 'c1'),
      _entry(planId: 'p1', sessionKey: '0-1', customerId: 'c1'),
      _entry(planId: 'p2', sessionKey: '0-0', customerId: 'c2'),
    ];

    final byPlan = filterDiaryEntries(entries, planId: 'p1');
    expect(byPlan, hasLength(2));

    final bySession = filterDiaryEntries(
      entries,
      planId: 'p1',
      sessionKey: '0-1',
    );
    expect(bySession, hasLength(1));
    expect(bySession.single.execution.sessionKey, '0-1');
  });
}
