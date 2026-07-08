import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

/// Summary stat tile on the coach dashboard.
class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.value,
    required this.label,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
