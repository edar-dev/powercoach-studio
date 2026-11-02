import 'package:flutter/material.dart';

import '../../../../core/theme/stitch_m3_theme.dart';

/// Today schedule row on the coach dashboard.
class DashboardScheduleCard extends StatelessWidget {
  const DashboardScheduleCard({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.time,
    required this.period,
    required this.clientName,
    required this.programName,
    required this.onTap,
    this.statusLabel,
    this.statusColor,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final String time;
  final String period;
  final String clientName;
  final String programName;
  final VoidCallback onTap;
  final String? statusLabel;
  final Color? statusColor;

  @override
  Widget build(BuildContext context) {
    final chipLabel = statusLabel;
    final chipColor = statusColor ?? colorScheme.primary;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    period,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            clientName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (chipLabel != null && chipLabel.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: chipColor.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(
                                StitchM3Theme.radiusMd,
                              ),
                              border: Border.all(
                                color: chipColor.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Text(
                              chipLabel,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: chipColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      programName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
