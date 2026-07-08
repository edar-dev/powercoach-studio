import '../../workouts/data/workout_plan_repository.dart';
import '../../workouts/domain/coach_stats_loader.dart';
import '../../workouts/domain/session_execution_service.dart';
import 'plan_calendar_event.dart';

/// Lightweight local counts for coach hub discoverability cards.
class DashboardCoachToolsHints {
  const DashboardCoachToolsHints({
    required this.loggedSessions30d,
    this.adherence7dPercent,
  });

  final int loggedSessions30d;
  final int? adherence7dPercent;
}

DashboardCoachToolsHints computeDashboardCoachToolsHints({
  required List<SessionExecutionEntry> entries,
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();
  final today = DateTime(clock.year, clock.month, clock.day);
  final from30 = today.subtract(const Duration(days: 29));

  var logged30 = 0;
  for (final entry in entries) {
    final day = DateTime(
      entry.execution.sessionDate.year,
      entry.execution.sessionDate.month,
      entry.execution.sessionDate.day,
    );
    if (day.isBefore(from30) || day.isAfter(today)) continue;
    if (entry.execution.status == PlanSessionStatus.planned) continue;
    logged30++;
  }

  final stats = CoachStatsLoader.computeCoachStats(
    entries: entries,
    periodDays: 7,
    now: clock,
  );
  final adherence = stats.adherenceRate == null
      ? null
      : (stats.adherenceRate! * 100).round();

  return DashboardCoachToolsHints(
    loggedSessions30d: logged30,
    adherence7dPercent: adherence,
  );
}

Future<DashboardCoachToolsHints> loadDashboardCoachToolsHints({
  SessionExecutionService? executionService,
  WorkoutPlanRepository? planRepository,
  DateTime? now,
}) async {
  final repository = planRepository ?? WorkoutPlanRepository();
  final executions = executionService ?? SessionExecutionService();
  final plans = await repository.getAll();
  final entries = await executions.listAll(plans: plans);
  return computeDashboardCoachToolsHints(entries: entries, now: now);
}
