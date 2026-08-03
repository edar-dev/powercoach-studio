import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

/// Minimal expandable card used across the workout builder.
///
/// Collapsed: [title] + optional [summary]. Expanded: [expandedChild].
/// Only the header toggles expansion so controls in [expandedChild] stay interactive.
class WorkoutExpandableCard extends StatelessWidget {
  const WorkoutExpandableCard({
    super.key,
    required this.title,
    required this.expanded,
    required this.onExpandedChanged,
    this.summary,
    this.leading,
    this.trailing,
    this.expandedChild,
    this.accentBorder = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  });

  final Widget title;
  final String? summary;
  final bool expanded;
  final ValueChanged<bool> onExpandedChanged;
  final Widget? leading;
  final Widget? trailing;
  final Widget? expandedChild;
  final bool accentBorder;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final radius = BorderRadius.circular(StitchM3Theme.radiusLg);

    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: cs.outline.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (accentBorder)
                Container(width: 4, color: StitchM3Theme.accent),
              Expanded(
                child: Padding(
                  padding: padding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (leading != null) ...[
                            // Keep drag handles outside the expand InkWell.
                            leading!,
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: InkWell(
                              onTap: () => onExpandedChanged(!expanded),
                              borderRadius: BorderRadius.circular(
                                StitchM3Theme.radiusMd,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          title,
                                          if (summary != null &&
                                              summary!.trim().isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              summary!,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: cs.onSurfaceVariant,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      expanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      size: 22,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (trailing != null) trailing!,
                        ],
                      ),
                      if (expanded && expandedChild != null) ...[
                        const SizedBox(height: 10),
                        expandedChild!,
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
