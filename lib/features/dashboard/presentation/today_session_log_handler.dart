import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../workouts/data/workout_plan_repository.dart';
import '../../workouts/data/workout_routine_model.dart';
import '../../workouts/domain/plan_session_status_service.dart';
import '../../workouts/domain/session_execution.dart';
import '../../workouts/domain/session_execution_service.dart';
import '../../workouts/presentation/widgets/session_log_sheet.dart';
import '../domain/dashboard_snapshot.dart';
import '../domain/plan_calendar_event.dart';

/// Opens the session log sheet for a dashboard "Today" row and persists
/// completion (same path as calendar / schedule detail completed logging).
class TodaySessionLogHandler {
  TodaySessionLogHandler({
    WorkoutPlanRepository? planRepository,
    SessionExecutionService? executionService,
    PlanSessionStatusService? statusService,
    Future<SessionLogResult?> Function({
      required BuildContext context,
      required List<Exercise> plannedExercises,
      List<ExecutedExercise>? initialExercises,
      String initialNotes,
    })?
    showLogSheet,
  }) : _planRepo = planRepository ?? WorkoutPlanRepository(),
       _executionService =
           executionService ??
           SessionExecutionService(repository: planRepository),
       _statusService =
           statusService ??
           PlanSessionStatusService(
             repository: planRepository,
             executionService: executionService,
           ),
       _showLogSheet = showLogSheet ?? showSessionLogSheet;

  final WorkoutPlanRepository _planRepo;
  final SessionExecutionService _executionService;
  final PlanSessionStatusService _statusService;
  final Future<SessionLogResult?> Function({
    required BuildContext context,
    required List<Exercise> plannedExercises,
    List<ExecutedExercise>? initialExercises,
    String initialNotes,
  })
  _showLogSheet;

  /// Returns true when the session was saved successfully.
  Future<bool> logSession({
    required BuildContext context,
    required DashboardTodayItem item,
  }) async {
    final l10n = AppLocalizations.of(context);

    try {
      final plan = await _planRepo.getById(item.planId);
      if (!context.mounted) return false;
      if (plan == null) {
        _showError(context, l10n);
        return false;
      }

      final routine = plan.routine;
      if (item.weekIndex < 0 ||
          item.weekIndex >= routine.weeks.length ||
          item.dayIndex < 0 ||
          item.dayIndex >= routine.weeks[item.weekIndex].days.length) {
        _showError(context, l10n);
        return false;
      }

      final day = routine.weeks[item.weekIndex].days[item.dayIndex];
      final sessionKey = WorkoutRoutine.sessionKey(
        item.weekIndex,
        item.dayIndex,
      );
      final existing = await _executionService.get(
        planId: item.planId,
        sessionKey: sessionKey,
      );
      if (!context.mounted) return false;

      final logResult = await _showLogSheet(
        context: context,
        plannedExercises: day.exercises,
        initialExercises: existing?.exercises,
        initialNotes: existing?.notes ?? '',
      );
      if (logResult == null || !context.mounted) return false;

      await _statusService.setSessionStatus(
        planId: item.planId,
        weekIndex: item.weekIndex,
        dayIndex: item.dayIndex,
        status: PlanSessionStatus.completed,
        sessionDate: item.date,
        exercises: logResult.exercises,
        notes: logResult.notes,
        source: 'dashboard_today',
      );
      if (!context.mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutBuilderLogSessionSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return true;
    } catch (_) {
      if (!context.mounted) return false;
      _showError(context, l10n);
      return false;
    }
  }

  void _showError(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.calendarUpdateError),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
      ),
    );
  }
}
