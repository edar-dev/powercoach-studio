import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../dashboard/domain/calendar_event_loader.dart';
import '../../../dashboard/domain/plan_calendar_event.dart';
import '../../../workouts/data/workout_plan_api_model.dart';

class PlanScheduleStrip extends StatelessWidget {
  const PlanScheduleStrip({
    super.key,
    required this.plan,
    required this.localeName,
    this.onSessionTap,
    this.onSessionLongPress,
    this.onEmptyTap,
  });

  final WorkoutPlanApiModel plan;
  final String localeName;
  final void Function(PlanCalendarEvent event)? onSessionTap;
  final Future<void> Function(PlanCalendarEvent event)? onSessionLongPress;
  final VoidCallback? onEmptyTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final events = CalendarEventLoader.upcomingEventsForPlan(
      plan: plan,
      fromDay: DateTime.now(),
      limit: 4,
    );
    if (events.isEmpty) {
      if (onEmptyTap == null) {
        return const SizedBox.shrink();
      }
      return InkWell(
        onTap: onEmptyTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(
                Icons.event_outlined,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.planScheduleEmptyHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.calendarUpcomingSessions,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final event in events)
              GestureDetector(
                onLongPress: onSessionLongPress == null
                    ? null
                    : () => onSessionLongPress!(event),
                child: InputChip(
                  avatar: Icon(
                    _statusIcon(event.status),
                    size: 16,
                    color: _statusColor(event.status, colorScheme),
                  ),
                  label: Text(
                    '${DateFormat.Md(localeName).format(event.day)} · ${event.sessionLabel}',
                    style: theme.textTheme.labelMedium,
                  ),
                  onPressed: onSessionTap == null
                      ? null
                      : () => onSessionTap!(event),
                ),
              ),
          ],
        ),
      ],
    );
  }

  IconData _statusIcon(PlanSessionStatus status) {
    return switch (status) {
      PlanSessionStatus.completed => Icons.check_circle,
      PlanSessionStatus.skipped => Icons.remove_circle_outline,
      PlanSessionStatus.planned => Icons.schedule,
    };
  }

  Color _statusColor(PlanSessionStatus status, ColorScheme colorScheme) {
    return switch (status) {
      PlanSessionStatus.completed => colorScheme.tertiary,
      PlanSessionStatus.skipped => colorScheme.error,
      PlanSessionStatus.planned => colorScheme.onSurfaceVariant,
    };
  }
}
