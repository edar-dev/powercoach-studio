import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/stitch_m3_theme.dart';
import '../../../../l10n/app_localizations.dart';

class WorkoutPlanTemplateListTile extends StatelessWidget {
  const WorkoutPlanTemplateListTile({
    super.key,
    required this.title,
    required this.updatedAgo,
    required this.summaryText,
    required this.onTap,
    required this.onEdit,
    required this.onAssign,
    required this.onDuplicate,
    required this.onDelete,
    this.phase,
  });

  final String title;
  final String updatedAgo;
  final String summaryText;
  final String? phase;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onAssign;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final cleanPhase = phase?.trim();
    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
            border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.bookmark_outline, color: StitchM3Theme.accent),
              const SizedBox(width: 12),
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
                    Text(
                      summaryText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      updatedAgo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    if (cleanPhase != null && cleanPhase.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: StitchM3Theme.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          cleanPhase,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: StitchM3Theme.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: cs.onSurfaceVariant),
                onSelected: (value) {
                  HapticFeedback.mediumImpact();
                  switch (value) {
                    case 'edit':
                      onEdit();
                    case 'assign':
                      onAssign();
                    case 'dup':
                      onDuplicate();
                    case 'del':
                      onDelete();
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(l10n.workoutTemplatesEdit),
                  ),
                  PopupMenuItem(
                    value: 'assign',
                    child: Text(l10n.workoutTemplatesAssign),
                  ),
                  PopupMenuItem(
                    value: 'dup',
                    child: Text(l10n.workoutTemplatesDuplicate),
                  ),
                  PopupMenuItem(
                    value: 'del',
                    child: Text(l10n.workoutTemplatesDelete),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
