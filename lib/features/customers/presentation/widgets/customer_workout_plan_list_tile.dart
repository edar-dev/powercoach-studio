import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/stitch_m3_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../dashboard/domain/plan_calendar_event.dart';
import '../../../workouts/data/workout_plan_api_model.dart';
import '../../../workouts/domain/workout_plan_list_helpers.dart';
import '../../../workouts/presentation/widgets/workout_plan_lifecycle_pill.dart';
import 'plan_schedule_strip.dart';

class CustomerWorkoutPlanListTile extends StatelessWidget {
  const CustomerWorkoutPlanListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.plan,
    required this.localeName,
    this.onSessionTap,
    this.onSessionLongPress,
    this.onTap,
    this.onCreateFollowUp,
    this.onDuplicate,
    this.onSaveAsTemplate,
    this.onArchive,
    this.onUnarchive,
    this.onMarkCompleted,
    this.onDelete,
  });

  final String title;
  final String subtitle;
  final WorkoutPlanApiModel plan;
  final String localeName;
  final void Function(PlanCalendarEvent event)? onSessionTap;
  final Future<void> Function(PlanCalendarEvent event)? onSessionLongPress;
  final VoidCallback? onTap;
  final VoidCallback? onCreateFollowUp;
  final VoidCallback? onDuplicate;
  final VoidCallback? onSaveAsTemplate;
  final VoidCallback? onArchive;
  final VoidCallback? onUnarchive;
  final VoidCallback? onMarkCompleted;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
            border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    WorkoutPlanLifecyclePill(plan: plan),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    PlanScheduleStrip(
                      plan: plan,
                      localeName: localeName,
                      onSessionTap: onSessionTap,
                      onSessionLongPress: onSessionLongPress,
                    ),
                  ],
                ),
              ),
              if (onCreateFollowUp != null ||
                  onDuplicate != null ||
                  onSaveAsTemplate != null ||
                  onArchive != null ||
                  onUnarchive != null ||
                  onMarkCompleted != null ||
                  onDelete != null)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: cs.onSurfaceVariant,
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 0),
                  onSelected: (value) {
                    HapticFeedback.mediumImpact();
                    switch (value) {
                      case 'follow_up':
                        onCreateFollowUp?.call();
                      case 'duplicate':
                        onDuplicate?.call();
                      case 'template':
                        onSaveAsTemplate?.call();
                      case 'archive':
                        onArchive?.call();
                      case 'unarchive':
                        onUnarchive?.call();
                      case 'complete':
                        onMarkCompleted?.call();
                      case 'delete':
                        onDelete?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    if (onCreateFollowUp != null)
                      PopupMenuItem(
                        value: 'follow_up',
                        child: Text(l10n.workoutCreateNewFromThis),
                      ),
                    if (onDuplicate != null)
                      PopupMenuItem(
                        value: 'duplicate',
                        child: Text(l10n.workoutDuplicateAction),
                      ),
                    if (onSaveAsTemplate != null)
                      PopupMenuItem(
                        value: 'template',
                        child: Text(l10n.workoutTemplatesSaveAsTemplate),
                      ),
                    if (onArchive != null && !isArchivedPlan(plan))
                      PopupMenuItem(
                        value: 'archive',
                        child: Text(l10n.workoutPlanArchiveAction),
                      ),
                    if (onUnarchive != null && isArchivedPlan(plan))
                      PopupMenuItem(
                        value: 'unarchive',
                        child: Text(l10n.workoutPlanUnarchiveAction),
                      ),
                    if (onMarkCompleted != null && !isArchivedPlan(plan))
                      PopupMenuItem(
                        value: 'complete',
                        child: Text(l10n.workoutPlanCompleteAction),
                      ),
                    if (onDelete != null)
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(l10n.workoutDelete),
                      ),
                  ],
                ),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
