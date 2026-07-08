import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/dashboard/domain/plan_calendar_event.dart';
import 'package:powercoach_studio/features/workouts/domain/session_execution.dart';
import 'package:powercoach_studio/features/workouts/domain/session_execution_service.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_diary_filter.dart';

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

  test('filterDiaryEntries applies customer, date, and status filters', () {
    final entries = [
      entry(
        customerId: 'c1',
        status: PlanSessionStatus.completed,
        sessionDate: DateTime(2026, 6, 14),
      ),
      entry(
        customerId: 'c2',
        status: PlanSessionStatus.skipped,
        sessionDate: DateTime(2026, 6, 13),
      ),
      entry(
        customerId: 'c1',
        status: PlanSessionStatus.completed,
        sessionDate: DateTime(2026, 5, 1),
      ),
    ];

    expect(
      filterDiaryEntries(
        entries,
        customerId: 'c1',
        dateRange: DiaryDateRange.last7,
        statusFilter: DiaryStatusFilter.completed,
        now: now,
      ),
      hasLength(1),
    );

    expect(
      filterDiaryEntries(
        entries,
        statusFilter: DiaryStatusFilter.skipped,
        now: now,
      ),
      hasLength(1),
    );
  });
}
