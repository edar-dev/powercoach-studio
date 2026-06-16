import '../../dashboard/domain/plan_calendar_event.dart';
import '../data/workout_plan_repository.dart';import 'session_execution_service.dart';

/// Aggregated coach KPIs for a rolling time window.
class CoachStatsSnapshot {
  const CoachStatsSnapshot({
    required this.adherenceRate,
    required this.completedSessions,
    required this.skippedSessions,
    required this.activeClients,
    required this.periodDays,
  });

  /// Share of completed sessions among logged sessions (completed + skipped).
  final double? adherenceRate;
  final int completedSessions;
  final int skippedSessions;
  final int activeClients;
  final int periodDays;

  int get loggedSessions => completedSessions + skippedSessions;
}

class CoachStatsLoader {
  CoachStatsLoader({
    WorkoutPlanRepository? repository,
    SessionExecutionService? executionService,
  }) : _repository = repository ?? WorkoutPlanRepository(),
       _executions = executionService ?? SessionExecutionService();

  final WorkoutPlanRepository _repository;
  final SessionExecutionService _executions;

  Future<CoachStatsSnapshot> load({int periodDays = 7}) async {
    final plans = await _repository.getAll();
    final entries = await _executions.listAll(plans: plans);
    return computeCoachStats(
      entries: entries,
      periodDays: periodDays,
    );
  }

  /// Pure aggregation used by [load] and unit tests.
  static CoachStatsSnapshot computeCoachStats({
    required List<SessionExecutionEntry> entries,
    required int periodDays,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final from = DateTime(clock.year, clock.month, clock.day)
        .subtract(Duration(days: periodDays - 1));
    final to = DateTime(clock.year, clock.month, clock.day);

    var completed = 0;
    var skipped = 0;
    final activeCustomerIds = <String>{};

    for (final entry in entries) {
      final sessionDate = entry.execution.sessionDate;
      if (sessionDate.isBefore(from) || sessionDate.isAfter(to)) continue;

      if (entry.execution.status == PlanSessionStatus.completed) {
        completed++;
        activeCustomerIds.add(entry.customerId);
      } else if (entry.execution.status == PlanSessionStatus.skipped) {
        skipped++;
        activeCustomerIds.add(entry.customerId);
      }
    }

    final logged = completed + skipped;
    final adherence = logged == 0 ? null : completed / logged;

    return CoachStatsSnapshot(
      adherenceRate: adherence,
      completedSessions: completed,
      skippedSessions: skipped,
      activeClients: activeCustomerIds.length,
      periodDays: periodDays,
    );
  }
}
