import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../core/routing/app_paths.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/dashboard_snapshot_loader.dart';
import '../../domain/dashboard_snapshot.dart';
import '../../../settings/presentation/backup_onboarding_prompt.dart';
import 'package:powercoach_studio/core/backup/web_persistence_coordinator.dart';
import 'package:powercoach_studio/core/billing/billing_alert_banner.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/backup_reminder_banner.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_coach_tools_section.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_attention_section.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_drawer.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_hero_metrics.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_no_plan_section.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_shortcuts_section.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_stale_plans_section.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_summary_footer.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_surface_card.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_today_section.dart';

import '../today_session_log_handler.dart';

/// Coach Dashboard — command center for "what to do today" plus summary stats.
class CoachDashboardScreen extends StatefulWidget {
  const CoachDashboardScreen({super.key, this.loadSnapshot});

  /// When set (tests), skips repositories and returns this future instead.
  final Future<DashboardSnapshot> Function(String unknownClientLabel)?
  loadSnapshot;

  @override
  State<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

class _CoachDashboardScreenState extends State<CoachDashboardScreen> {
  final DashboardSnapshotLoader _loader = DashboardSnapshotLoader();
  final TodaySessionLogHandler _todaySessionLogHandler =
      TodaySessionLogHandler();
  DashboardSnapshot? _snapshot;
  bool _loading = true;
  bool _backupOnboardingScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadStats();
    });
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    final l10n = AppLocalizations.of(context);
    final unknown = l10n.dashboardUnknownClient;
    final DashboardSnapshot snap;
    if (widget.loadSnapshot != null) {
      snap = await widget.loadSnapshot!(unknown);
    } else {
      snap = await _loader.load(
        unknownClientLabel: unknown,
        untitledWorkoutLabel: l10n.dashboardUntitledWorkout,
      );
    }
    if (!mounted) return;
    setState(() {
      _snapshot = snap;
      _loading = false;
    });
    if (!_backupOnboardingScheduled && widget.loadSnapshot == null) {
      _backupOnboardingScheduled = true;
      final migrated = await WebPersistenceCoordinator.instance
          .maybeRunCoachEntitiesMigrationIfNeeded(context);
      if (!mounted) return;
      if (migrated) {
        await _reloadStatsAfterRecovery();
        if (!mounted) return;
      }
      final restored = await WebPersistenceCoordinator.instance
          .maybeShowCloudRecoveryIfNeeded(context);
      if (!mounted) return;
      if (restored) {
        // Reload stats after replace-all restore so the dashboard is not empty.
        await _reloadStatsAfterRecovery();
        if (!mounted) return;
      }
      await maybeShowBackupOnboardingIfNeeded(context);
    }
  }

  Future<void> _reloadStatsAfterRecovery() async {
    final l10n = AppLocalizations.of(context);
    final snap = await _loader.load(
      unknownClientLabel: l10n.dashboardUnknownClient,
      untitledWorkoutLabel: l10n.dashboardUntitledWorkout,
    );
    if (!mounted) return;
    setState(() {
      _snapshot = snap;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final snap = _snapshot;
    final todaySubtitle = DateFormat(
      'EEEE, d MMMM',
      l10n.localeName,
    ).format(DateTime.now());

    return Scaffold(
      backgroundColor: cs.surfaceContainerHighest,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: cs.surface,
        title: Row(
          children: [
            Flexible(
              child: Text(
                l10n.dashboardTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: StitchM3Theme.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
                border: Border.all(
                  color: StitchM3Theme.accent.withValues(alpha: 0.22),
                ),
              ),
              child: Text(
                l10n.dashboardCoachStudioBadge,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: StitchM3Theme.accent,
                ),
              ),
            ),
          ],
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              HapticFeedback.mediumImpact();
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              HapticFeedback.mediumImpact();
              navigateTo(context, AppPaths.personalInfo);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: cs.outline, height: 1),
        ),
      ),
      drawer: const DashboardDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BillingAlertBanner(),
              const BackupReminderBanner(),
              if (_loading && snap == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                if (snap != null && snap.hasError) ...[
                  DashboardSurfaceCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.error_outline, color: cs.error, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.dashboardLoadError,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (snap != null && !snap.hasError) ...[
                  DashboardHeroMetrics(
                    theme: theme,
                    colorScheme: cs,
                    l10n: l10n,
                    snapshot: snap,
                    loading: _loading,
                  ),
                  const SizedBox(height: 24),
                  Semantics(
                    container: true,
                    label: l10n.dashboardSemanticTodayList,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DashboardSectionHeader(
                          title: l10n.dashboardSectionToday,
                          subtitle: todaySubtitle,
                          actionLabel: l10n.dashboardSeeAll,
                          onAction: () {
                            HapticFeedback.mediumImpact();
                            navigateTo(context, '/dashboard/calendar');
                          },
                        ),
                        const SizedBox(height: 12),
                        DashboardTodaySection(
                          theme: theme,
                          colorScheme: cs,
                          l10n: l10n,
                          snapshot: snap,
                          loading: _loading,
                          onSessionTap: (item) async {
                            final ok = await _todaySessionLogHandler.logSession(
                              context: context,
                              item: item,
                            );
                            if (ok && mounted) await _loadStats();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (snap != null) ...[
                  const DashboardCoachToolsSection(),
                  const SizedBox(height: 24),
                ],
                if (snap != null && !snap.hasError) ...[
                  Semantics(
                    container: true,
                    label: l10n.dashboardSemanticAttentionList,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DashboardSectionHeader(
                          title: l10n.dashboardSectionAttention,
                        ),
                        const SizedBox(height: 12),
                        DashboardAttentionSection(
                          theme: theme,
                          colorScheme: cs,
                          l10n: l10n,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Semantics(
                    container: true,
                    label: l10n.dashboardSemanticNoPlanList,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DashboardSectionHeader(
                          title: l10n.dashboardSectionCustomersNoPlan,
                          badge: snap.customersWithoutPlan.isEmpty
                              ? l10n.dashboardNoPlanAllAssignedBadge
                              : null,
                          badgeTone: DashboardSectionBadgeTone.success,
                        ),
                        const SizedBox(height: 12),
                        DashboardNoPlanSection(
                          theme: theme,
                          colorScheme: cs,
                          l10n: l10n,
                          snapshot: snap,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Semantics(
                    container: true,
                    label: l10n.dashboardSemanticStaleList,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DashboardSectionHeader(
                          title: l10n.dashboardSectionStalePlans,
                          badge: l10n.dashboardStaleWindowBadge(kStalePlanDays),
                        ),
                        const SizedBox(height: 12),
                        DashboardStalePlansSection(
                          theme: theme,
                          colorScheme: cs,
                          l10n: l10n,
                          snapshot: snap,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  DashboardShortcutsSection(
                    theme: theme,
                    colorScheme: cs,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 24),
                ],
                DashboardSummaryFooter(
                  theme: theme,
                  colorScheme: cs,
                  l10n: l10n,
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.dashboardOfflineFooter,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
