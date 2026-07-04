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
    required this.onSessionActions,
  });

  final SessionDetailSnapshot snapshot;
  final VoidCallback onOpenBuilder;
  final VoidCallback onSessionActions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final event = snapshot.event;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
              border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.yMMMEd(l10n.localeName).format(event.day),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event.customerName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
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
                  const SizedBox(height: 6),
                  Text(
                    snapshot.phase!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
            ),
            child: Text(
              l10n.sessionDetailExercisesCount(snapshot.exerciseCount),
              style: theme.textTheme.titleSmall?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onOpenBuilder,
            icon: const Icon(Icons.open_in_new),
            label: Text(l10n.sessionDetailOpenBuilder),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onSessionActions,
            icon: const Icon(Icons.check_circle_outline),
            label: Text(l10n.sessionMarkPlanned),
          ),
        ],
      ),
    );
  }
}
