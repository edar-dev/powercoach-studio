import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/stitch_m3_theme.dart';
import '../../data/workout_plan_api_model.dart';
import '../../domain/workout_plan_list_helpers.dart';

class WorkoutPlanLifecyclePill extends StatelessWidget {
  const WorkoutPlanLifecyclePill({super.key, required this.plan});

  final WorkoutPlanApiModel plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final archived = isArchivedPlan(plan);
    final completed = completedAtForPlan(plan) != null || isEndedPlan(plan);
    final active = isActivePlan(plan);
    final (label, color) = archived
        ? (l10n.workoutPlanStatusArchived, cs.onSurfaceVariant)
        : completed
        ? (l10n.workoutPlanStatusCompleted, cs.tertiary)
        : active
        ? (l10n.workoutPlanStatusActive, StitchM3Theme.accent)
        : (l10n.workoutPlanStatusDraft, cs.primary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
