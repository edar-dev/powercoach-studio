import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/workout_plan_api_model.dart';
import '../../domain/workout_plan_list_helpers.dart';

/// Compact archived badge only — draft/active/completed chrome removed (Wave F).
class WorkoutPlanLifecyclePill extends StatelessWidget {
  const WorkoutPlanLifecyclePill({super.key, required this.plan});

  final WorkoutPlanApiModel plan;

  @override
  Widget build(BuildContext context) {
    if (!isArchivedPlan(plan)) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final color = cs.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        l10n.workoutPlanStatusArchived,
        style: theme.textTheme.labelSmall?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
