import 'package:flutter/material.dart';

import '../../../../core/theme/stitch_m3_theme.dart';
import 'dashboard_surface_card.dart';

/// Success-toned empty state for dashboard audit sections (Stitch positive empties).
class DashboardPositiveEmptyCard extends StatelessWidget {
  const DashboardPositiveEmptyCard({
    super.key,
    required this.message,
    this.hint,
    this.icon = Icons.check_circle_outline,
  });

  final String message;
  final String? hint;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return DashboardSurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: StitchM3Theme.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(StitchM3Theme.radiusXl),
              border: Border.all(
                color: StitchM3Theme.success.withValues(alpha: 0.22),
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: StitchM3Theme.success,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                if (hint != null && hint!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    hint!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
