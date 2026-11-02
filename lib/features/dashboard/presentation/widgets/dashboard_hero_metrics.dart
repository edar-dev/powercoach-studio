import 'package:flutter/material.dart';

import '../../../../core/theme/stitch_m3_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/dashboard_snapshot.dart';
import 'dashboard_surface_card.dart';

/// Three-tile KPI strip at the top of the coach dashboard (Stitch hero metrics).
class DashboardHeroMetrics extends StatelessWidget {
  const DashboardHeroMetrics({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.l10n,
    required this.snapshot,
    required this.loading,
    this.attentionExtraCount = 0,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;
  final DashboardSnapshot? snapshot;
  final bool loading;

  /// Extra attention items (e.g. actionable data-quality findings).
  final int attentionExtraCount;

  @override
  Widget build(BuildContext context) {
    final showPlaceholder = loading && snapshot == null;
    final clients = showPlaceholder ? '–' : '${snapshot?.clientCount ?? 0}';
    final sessionsToday =
        showPlaceholder ? '–' : '${snapshot?.todayItems.length ?? 0}';
    final attentionCount = showPlaceholder
        ? null
        : (snapshot?.stalePlans.length ?? 0) +
            (snapshot?.customersWithoutPlan.length ?? 0) +
            attentionExtraCount;
    final attentionValue = attentionCount == null ? '–' : '$attentionCount';
    final attentionOk = attentionCount != null && attentionCount == 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 640;
        final tiles = [
          _HeroMetricTile(
            theme: theme,
            colorScheme: colorScheme,
            label: l10n.dashboardMetricActiveClients,
            value: clients,
            icon: Icons.groups_outlined,
            iconTint: StitchM3Theme.accent,
          ),
          _HeroMetricTile(
            theme: theme,
            colorScheme: colorScheme,
            label: l10n.dashboardMetricSessionsToday,
            value: sessionsToday,
            icon: Icons.event_available_outlined,
            iconTint: colorScheme.secondary,
          ),
          _HeroMetricTile(
            theme: theme,
            colorScheme: colorScheme,
            label: l10n.dashboardMetricPendingReviews,
            value: attentionValue,
            valueColor: attentionOk ? StitchM3Theme.success : null,
            icon: attentionOk
                ? Icons.check_circle_outline
                : Icons.warning_amber_outlined,
            iconTint: attentionOk
                ? StitchM3Theme.success
                : StitchM3Theme.warning,
          ),
        ];

        if (wide) {
          return Row(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: tiles[i]),
              ],
            ],
          );
        }

        // Narrow: first two side-by-side, third full width.
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: tiles[0]),
                const SizedBox(width: 12),
                Expanded(child: tiles[1]),
              ],
            ),
            const SizedBox(height: 12),
            tiles[2],
          ],
        );
      },
    );
  }
}

class _HeroMetricTile extends StatelessWidget {
  const _HeroMetricTile({
    required this.theme,
    required this.colorScheme,
    required this.label,
    required this.value,
    required this.icon,
    required this.iconTint,
    this.valueColor,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final String label;
  final String value;
  final Color? valueColor;
  final IconData icon;
  final Color iconTint;

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconTint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
              border: Border.all(color: iconTint.withValues(alpha: 0.22)),
            ),
            child: Icon(icon, size: 20, color: iconTint),
          ),
        ],
      ),
    );
  }
}
