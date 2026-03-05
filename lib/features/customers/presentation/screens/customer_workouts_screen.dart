import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/stitch_m3_theme.dart';

/// Lista workout del cliente – route /customers/:id/workouts.
/// Placeholder: dati mock; quando l'API sarà disponibile si caricheranno i workout reali.
class CustomerWorkoutsScreen extends StatelessWidget {
  const CustomerWorkoutsScreen({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cs.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.mediumImpact();
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/customers');
            }
          },
        ),
        title: Text(
          'Workouts',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _WorkoutListCard(
            theme: theme,
            cs: cs,
            title: 'Heavy Upper Body A',
            subtitle: 'Yesterday • 65 mins',
            badge: 'Completed',
            trailing: 'NEW PR',
            highlight: true,
          ),
          const SizedBox(height: 12),
          _WorkoutListCard(
            theme: theme,
            cs: cs,
            title: 'Leg Day Focus',
            subtitle: '3 days ago • 72 mins',
            badge: 'Completed',
            trailing: '14,200 KG VOLUME',
            highlight: false,
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'More workouts will appear here when the API is connected.',
              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutListCard extends StatelessWidget {
  const _WorkoutListCard({
    required this.theme,
    required this.cs,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.trailing,
    required this.highlight,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final String title;
  final String subtitle;
  final String badge;
  final String trailing;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: StitchM3Theme.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
                  ),
                  child: Text(
                    badge,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: StitchM3Theme.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (highlight)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: StitchM3Theme.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
              ),
              child: Text(
                trailing,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: StitchM3Theme.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            Text(
              trailing,
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 24),
        ],
      ),
    );
  }
}
