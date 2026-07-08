import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../dashboard/domain/plan_calendar_event.dart';
import '../../workouts/domain/plan_session_override_service.dart';
import '../../workouts/domain/plan_session_status_service.dart';
import '../../workouts/presentation/widgets/plan_session_actions_sheet.dart';

/// Applies plan session status/override actions from the customer workouts list.
class CustomerWorkoutPlanSessionHandler {
  CustomerWorkoutPlanSessionHandler({
    PlanSessionStatusService? sessionStatusService,
    PlanSessionOverrideService? sessionOverrideService,
  }) : _sessionStatusService =
           sessionStatusService ?? PlanSessionStatusService(),
       _sessionOverrideService =
           sessionOverrideService ?? PlanSessionOverrideService();

  final PlanSessionStatusService _sessionStatusService;
  final PlanSessionOverrideService _sessionOverrideService;

  /// Returns true when plans should be reloaded after a successful mutation.
  Future<bool> handleSessionLongPress(
    BuildContext context,
    PlanCalendarEvent event,
  ) async {
    final selected = await showPlanSessionActionsSheet(context);
    if (selected == null || !context.mounted) return false;

    final originalDay = event.originalDay ?? event.day;
    try {
      if (selected.startsWith('status_')) {
        final status = switch (selected) {
          'status_completed' => PlanSessionStatus.completed,
          'status_skipped' => PlanSessionStatus.skipped,
          _ => PlanSessionStatus.planned,
        };
        await _sessionStatusService.setSessionStatus(
          planId: event.planId,
          weekIndex: event.weekIndex,
          dayIndex: event.dayIndex,
          status: status,
        );
      } else if (selected == 'override_skip') {
        await _sessionOverrideService.skipSessionOccurrence(
          planId: event.planId,
          weekIndex: event.weekIndex,
          dayIndex: event.dayIndex,
          originalDay: originalDay,
        );
      } else if (selected == 'override_move') {
        final picked = await showDatePicker(
          context: context,
          initialDate: event.day,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100, 12, 31),
        );
        if (picked == null || !context.mounted) return false;
        await _sessionOverrideService.moveSessionOccurrence(
          planId: event.planId,
          weekIndex: event.weekIndex,
          dayIndex: event.dayIndex,
          originalDay: originalDay,
          movedToDate: picked,
        );
      } else if (selected == 'override_clear') {
        await _sessionOverrideService.clearSessionOccurrenceOverride(
          planId: event.planId,
          weekIndex: event.weekIndex,
          dayIndex: event.dayIndex,
          originalDay: originalDay,
        );
      }
      return true;
    } catch (_) {
      if (!context.mounted) return false;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.calendarUpdateError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
      return false;
    }
  }
}
