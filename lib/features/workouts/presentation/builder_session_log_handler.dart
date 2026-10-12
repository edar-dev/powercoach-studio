import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../dashboard/domain/plan_calendar_event.dart';
import '../data/workout_routine_model.dart';
import '../domain/plan_session_status_service.dart';
import '../domain/session_execution.dart';
import '../domain/session_execution_service.dart';
import 'widgets/session_log_sheet.dart';

/// Opens the session log sheet for the workout builder Training tab / app bar
/// and persists completion with `source: 'workout_builder'`.
class BuilderSessionLogHandler {
  BuilderSessionLogHandler({
    SessionExecutionService? executionService,
    PlanSessionStatusService? statusService,
    Future<SessionLogResult?> Function({
      required BuildContext context,
      required List<Exercise> plannedExercises,
      List<ExecutedExercise>? initialExercises,
      String initialNotes,
    })?
    showLogSheet,
  }) : _executionService = executionService ?? SessionExecutionService(),
       _statusService = statusService ?? PlanSessionStatusService(),
       _showLogSheet = showLogSheet ?? showSessionLogSheet;

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
    required String planId,
    required int weekIndex,
    required int dayIndex,
    required List<Exercise> plannedExercises,
  }) async {
    final l10n = AppLocalizations.of(context);

    try {
      final sessionKey = WorkoutRoutine.sessionKey(weekIndex, dayIndex);
      final existing = await _executionService.get(
        planId: planId,
        sessionKey: sessionKey,
      );
      if (!context.mounted) return false;

      final logResult = await _showLogSheet(
        context: context,
        plannedExercises: plannedExercises,
        initialExercises: existing?.exercises,
        initialNotes: existing?.notes ?? '',
      );
      if (logResult == null || !context.mounted) return false;

      await _statusService.setSessionStatus(
        planId: planId,
        weekIndex: weekIndex,
        dayIndex: dayIndex,
        status: PlanSessionStatus.completed,
        exercises: logResult.exercises,
        notes: logResult.notes,
        source: 'workout_builder',
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
