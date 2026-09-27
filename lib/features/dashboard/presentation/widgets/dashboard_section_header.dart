import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

class DashboardSectionHeader extends StatelessWidget {
  const DashboardSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.badge,
    this.badgeTone = DashboardSectionBadgeTone.neutral,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  /// Muted text shown after the title (e.g. weekday date under "Oggi").
  final String? subtitle;
  /// Compact status chip on the trailing side (e.g. "100% assigned").
  final String? badge;
  final DashboardSectionBadgeTone badgeTone;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ),
              if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '· $subtitle',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (badge != null && badge!.trim().isNotEmpty) ...[
          const SizedBox(width: 8),
          _SectionBadge(label: badge!, tone: badgeTone),
        ],
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                color: StitchM3Theme.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

enum DashboardSectionBadgeTone { neutral, success }

class _SectionBadge extends StatelessWidget {
  const _SectionBadge({required this.label, required this.tone});

  final String label;
  final DashboardSectionBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isSuccess = tone == DashboardSectionBadgeTone.success;
    final fg = isSuccess ? StitchM3Theme.success : cs.onSurfaceVariant;
    final bg = isSuccess
        ? StitchM3Theme.success.withValues(alpha: 0.12)
        : cs.onSurface.withValues(alpha: 0.05);
    final border = isSuccess
        ? StitchM3Theme.success.withValues(alpha: 0.22)
        : cs.outline.withValues(alpha: 0.4);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
