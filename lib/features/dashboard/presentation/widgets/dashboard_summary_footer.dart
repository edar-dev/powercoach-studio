import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import '../../domain/dashboard_snapshot.dart';
import 'dashboard_stat_card.dart';
import 'dashboard_surface_card.dart';

/// Weekly progress, summary stats, and quick actions on the coach dashboard.
class DashboardSummaryFooter extends StatelessWidget {
  const DashboardSummaryFooter({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.l10n,
    required this.snapshot,
    required this.loading,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;
  final DashboardSnapshot? snapshot;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final showPlaceholder = loading && snapshot == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 20,
                    color: StitchM3Theme.accent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.dashboardWeeklyProgress,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                showPlaceholder ? '–' : '${snapshot?.weeklyUpdates ?? 0}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                l10n.dashboardPlansUpdatedThisWeek,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DashboardStatCard(
                theme: theme,
                colorScheme: colorScheme,
                value: showPlaceholder ? '–' : '${snapshot?.clientCount ?? 0}',
                label: l10n.dashboardTotalClients,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardStatCard(
                theme: theme,
                colorScheme: colorScheme,
                value: showPlaceholder ? '–' : '${snapshot?.activePrograms ?? 0}',
                label: l10n.dashboardActivePrograms,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  navigateTo(context, '/customers/new');
                },
                icon: const Icon(Icons.person_add, size: 20),
                label: Text(l10n.customersAddCustomer),
                style: FilledButton.styleFrom(
                  backgroundColor: StitchM3Theme.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      StitchM3Theme.radiusLg,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  context.push('/workouts/builder');
                },
                icon: const Icon(Icons.fitness_center, size: 20),
                label: Text(l10n.dashboardCreateProgram),
                style: OutlinedButton.styleFrom(
                  foregroundColor: StitchM3Theme.accent,
                  side: const BorderSide(color: StitchM3Theme.accent),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      StitchM3Theme.radiusLg,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
