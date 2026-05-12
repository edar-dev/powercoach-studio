import 'package:flutter/material.dart';

import 'dashboard_surface_card.dart';

/// Friendly empty state inside a [DashboardSurfaceCard].
class DashboardEmptyPlaceholder extends StatelessWidget {
  const DashboardEmptyPlaceholder({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return DashboardSurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: cs.onSurfaceVariant.withValues(alpha: 0.85)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
