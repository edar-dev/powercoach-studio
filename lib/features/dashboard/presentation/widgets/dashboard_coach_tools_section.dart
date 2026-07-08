import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import '../../domain/dashboard_coach_tools_hints.dart';
import 'dashboard_section_header.dart';

/// Quick entry points to workout diary and coach stats from the dashboard hub.
class DashboardCoachToolsSection extends StatefulWidget {
  const DashboardCoachToolsSection({
    super.key,
    this.loadHints,
  });

  /// When set (tests), skips repositories and returns this future instead.
  final Future<DashboardCoachToolsHints> Function()? loadHints;

  @override
  State<DashboardCoachToolsSection> createState() =>
      _DashboardCoachToolsSectionState();
}

class _DashboardCoachToolsSectionState extends State<DashboardCoachToolsSection> {
  DashboardCoachToolsHints? _hints;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadHints();
    });
  }

  Future<void> _loadHints() async {
    final hints = widget.loadHints != null
        ? await widget.loadHints!()
        : await loadDashboardCoachToolsHints();
    if (!mounted) return;
    setState(() => _hints = hints);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hints = _hints;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardSectionHeader(title: l10n.dashboardCoachToolsTitle),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _CoachToolActionCard(
                theme: theme,
                colorScheme: cs,
                icon: Icons.menu_book_outlined,
                title: l10n.dashboardDiaryAction,
                subtitle: hints == null
                    ? '—'
                    : l10n.dashboardDiarySubtitle(hints.loggedSessions30d),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  navigateTo(context, workoutDiaryPath());
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CoachToolActionCard(
                theme: theme,
                colorScheme: cs,
                icon: Icons.insights_outlined,
                title: l10n.dashboardStatsAction,
                subtitle: hints == null || hints.adherence7dPercent == null
                    ? '—'
                    : l10n.dashboardStatsSubtitle(hints.adherence7dPercent!),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  navigateTo(context, '/workouts/stats');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CoachToolActionCard extends StatelessWidget {
  const _CoachToolActionCard({
    required this.theme,
    required this.colorScheme,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: StitchM3Theme.accent, size: 22),
              const SizedBox(height: 10),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
