import 'package:flutter/material.dart';

import '../../../../core/theme/stitch_m3_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/workout_plan_api_model.dart';
import '../../domain/workout_template_list_helpers.dart';
import '../../domain/workout_template_preview_helpers.dart';

class WorkoutPlanTemplatePreviewContent extends StatelessWidget {
  const WorkoutPlanTemplatePreviewContent({
    super.key,
    required this.template,
    required this.summary,
    required this.previewWeeks,
    required this.onEdit,
    required this.onAssign,
  });

  final WorkoutPlanApiModel template;
  final TemplateSummary summary;
  final List<TemplatePreviewWeek> previewWeeks;
  final VoidCallback onEdit;
  final VoidCallback onAssign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          template.name.trim().isEmpty
              ? l10n.customerUnnamedPlan
              : template.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.workoutTemplatesStructureSummary(
            summary.weekCount,
            summary.dayCount,
            summary.exerciseCount,
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        if (previewWeeks.isEmpty)
          Text(
            l10n.workoutTemplatesPreviewEmpty,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          )
        else
          ...previewWeeks.map(
            (week) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      week.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...week.days.map(
                      (day) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              day.name,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ...day.exercises.map(
                              (exercise) => Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text(
                                  '\u2022 $exercise',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                            if (day.remainingExercises > 0)
                              Text(
                                l10n.workoutTemplatesPreviewExercisesMore(
                                  day.remainingExercises,
                                ),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onEdit,
                child: Text(l10n.workoutTemplatesEdit),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: onAssign,
                child: Text(l10n.workoutTemplatesAssign),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
