import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import '../../domain/session_detail_loader.dart';

/// Loaded session detail body (extracted for widget tests and screen reuse).
class SessionDetailView extends StatelessWidget {
  const SessionDetailView({
    super.key,
    required this.snapshot,
    required this.onOpenBuilder,
    this.onSessionActions,
  });

  final SessionDetailSnapshot snapshot;
  final VoidCallback onOpenBuilder;

  /// Optional overflow / sheet entry (kept for backward-compatible tests).
  final VoidCallback? onSessionActions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final event = snapshot.event;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.primary.withValues(alpha: 0.18),
                cs.surfaceContainerHighest,
              ],
            ),
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
            border: Border.all(color: cs.outline.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMEd(l10n.localeName).format(event.day),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                event.customerName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${event.programName} · ${event.sessionLabel}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              if ((snapshot.phase ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    snapshot.phase!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
          ),
          child: Row(
            children: [
              Icon(Icons.fitness_center, size: 18, color: cs.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.sessionDetailExercisesCount(snapshot.exerciseCount),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          onPressed: onOpenBuilder,
          icon: const Icon(Icons.open_in_new),
          label: Text(l10n.sessionDetailOpenBuilder),
        ),
        if (onSessionActions != null) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onSessionActions,
            icon: const Icon(Icons.more_horiz),
            label: Text(l10n.sessionMarkPlanned),
          ),
        ],
      ],
    );
  }
}
