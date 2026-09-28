import '../../dashboard/domain/plan_calendar_event.dart';
import '../../workouts/data/workout_plan_api_model.dart';
import '../../workouts/domain/session_execution_service.dart';
import '../../workouts/domain/workout_plan_list_helpers.dart';

/// Weekly adherence dot for the mini strip (null = no logged session).
class WeeklyAdherenceDot {
  const WeeklyAdherenceDot({this.completed});

  final bool? completed;
}

/// Training progress narrative for a single customer.
class CustomerProgressSnapshot {
  const CustomerProgressSnapshot({
    required this.adherencePercent,
    required this.completedSessions30d,
    required this.skippedSessions30d,
    required this.lastSessionDate,
    required this.last4Weeks,
    required this.hasAnyData,
  });

  final double? adherencePercent;
  final int completedSessions30d;
  final int skippedSessions30d;
  final DateTime? lastSessionDate;
  final List<WeeklyAdherenceDot> last4Weeks;
  final bool hasAnyData;
}

class CustomerProgressMetrics {
  const CustomerProgressMetrics._();

  static CustomerProgressSnapshot build({
    required String customerId,
    required List<WorkoutPlanApiModel> plans,
    required List<SessionExecutionEntry> allExecutions,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final today = DateTime(clock.year, clock.month, clock.day);
    final from30 = today.subtract(const Duration(days: 29));

    final activePlans = plans
        .where((p) => p.customerId == customerId && !isArchivedPlan(p))
        .toList();
    final activePlanIds = activePlans.map((p) => p.id).toSet();

    var completed30 = 0;
    var skipped30 = 0;
    DateTime? lastSession;

    final customerEntries = allExecutions
        .where((e) => e.customerId == customerId)
        .where((e) => activePlanIds.isEmpty || activePlanIds.contains(e.planId))
        .toList();

    for (final entry in customerEntries) {
      final d = entry.execution.sessionDate;
      if (d.isBefore(from30) || d.isAfter(today)) continue;
      if (entry.execution.status == PlanSessionStatus.completed) {
        completed30++;
      } else if (entry.execution.status == PlanSessionStatus.skipped) {
        skipped30++;
      }
    }

    for (final entry in customerEntries) {
      if (entry.execution.status == PlanSessionStatus.planned) continue;
      final d = entry.execution.completedAt ?? entry.execution.sessionDate;
      if (lastSession == null || d.isAfter(lastSession)) {
        lastSession = d;
      }
    }

    final logged30 = completed30 + skipped30;
    final adherence = logged30 == 0 ? null : completed30 / logged30;

    final last4Weeks = List<WeeklyAdherenceDot>.generate(4, (weekOffset) {
      final weekEnd = today.subtract(Duration(days: weekOffset * 7));
      final weekStart = weekEnd.subtract(const Duration(days: 6));
      var weekCompleted = 0;
      var weekSkipped = 0;
      for (final entry in customerEntries) {
        final d = entry.execution.sessionDate;
        if (d.isBefore(weekStart) || d.isAfter(weekEnd)) continue;
        if (entry.execution.status == PlanSessionStatus.completed) {
          weekCompleted++;
        } else if (entry.execution.status == PlanSessionStatus.skipped) {
          weekSkipped++;
        }
      }
      if (weekCompleted == 0 && weekSkipped == 0) {
        return const WeeklyAdherenceDot();
      }
      return WeeklyAdherenceDot(completed: weekCompleted >= weekSkipped);
    }).reversed.toList();

    final hasData = activePlans.isNotEmpty || customerEntries.isNotEmpty;

    return CustomerProgressSnapshot(
      adherencePercent: adherence,
      completedSessions30d: completed30,
      skippedSessions30d: skipped30,
      lastSessionDate: lastSession,
      last4Weeks: last4Weeks,
      hasAnyData: hasData,
    );
  }
}
