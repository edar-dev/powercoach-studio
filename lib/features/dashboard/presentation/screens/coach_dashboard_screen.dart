import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../core/auth/supabase_bootstrap.dart';
import '../../../../core/billing/billing_alert_banner.dart';
import '../../../../core/backup/web_persistence_coordinator.dart';
import '../../../../core/data_quality/data_quality.dart';
import '../../../../core/routing/app_navigation.dart';
import '../../../../core/routing/app_paths.dart';
import '../../../../core/routing/hub_chrome.dart';
import '../../../../core/ui/widgets/shell_utility_actions.dart';
import '../../../../core/ui/widgets/stitch_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/data/local_coach_profile_repository.dart';
import '../../../settings/presentation/backup_onboarding_prompt.dart';
import '../../../settings/presentation/data_health_controller.dart';
import '../../data/dashboard_snapshot_loader.dart';
import '../../domain/dashboard_snapshot.dart';
import '../today_session_log_handler.dart';
import '../widgets/backup_reminder_banner.dart';
import '../widgets/dashboard_attention_section.dart';
import '../widgets/dashboard_coach_tools_section.dart';
import '../widgets/dashboard_hero_header.dart';
import '../widgets/dashboard_hero_metrics.dart';
import '../widgets/dashboard_no_plan_section.dart';
import '../widgets/dashboard_section_header.dart';
import '../widgets/dashboard_shortcuts_section.dart';
import '../widgets/dashboard_stale_plans_section.dart';
import '../widgets/dashboard_summary_footer.dart';
import '../widgets/dashboard_surface_card.dart';
import '../widgets/dashboard_today_section.dart';
import '../widgets/post_invite_onboarding_card.dart';

/// Coach Dashboard — command center for "what to do today" plus summary stats.
class CoachDashboardScreen extends StatefulWidget {
  const CoachDashboardScreen({
    super.key,
    this.loadSnapshot,
    this.loadDataHealth,
  });

  /// When set (tests), skips repositories and returns this future instead.
  final Future<DashboardSnapshot> Function(String unknownClientLabel)?
      loadSnapshot;

  /// When set (tests), skips [DataHealthController] and returns this report.
  final Future<DataQualityReport?> Function()? loadDataHealth;

  @override
  State<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

class _CoachDashboardScreenState extends State<CoachDashboardScreen> {
  final DashboardSnapshotLoader _loader = DashboardSnapshotLoader();
  final TodaySessionLogHandler _todaySessionLogHandler =
      TodaySessionLogHandler();
  final DataHealthController _dataHealthController = DataHealthController();
  DashboardSnapshot? _snapshot;
  List<DataQualityFinding> _actionableFindings = const [];
  bool _loading = true;
  bool _backupOnboardingScheduled = false;
  bool _loggingTodaySession = false;
  String _coachDisplayName = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadCoachDisplayName();
      _loadStats();
    });
  }

  Future<void> _loadCoachDisplayName() async {
    final l10n = AppLocalizations.of(context);
    final fallback = l10n.dashboardGreetingFallbackName;
    final uid = SupabaseBootstrap.currentUser?.id;
    if (uid == null || uid.isEmpty) {
      if (!mounted) return;
      setState(() => _coachDisplayName = fallback);
      return;
    }
    try {
      final profile =
          await LocalCoachProfileRepository.instance.getProfile(uid);
      if (!mounted) return;
      final name = profile.displayName.trim();
      setState(() => _coachDisplayName = name.isEmpty ? fallback : name);
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      if (!mounted) return;
      setState(() => _coachDisplayName = fallback);
    }
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    final l10n = AppLocalizations.of(context);
    final unknown = l10n.dashboardUnknownClient;
    final snapFuture = widget.loadSnapshot != null
        ? widget.loadSnapshot!(unknown)
        : _loader.load(
            unknownClientLabel: unknown,
            untitledWorkoutLabel: l10n.dashboardUntitledWorkout,
          );
    final results = await Future.wait<Object?>([
      snapFuture,
      _loadDataHealthReport(),
    ]);
    if (!mounted) return;
    final snap = results[0]! as DashboardSnapshot;
    final report = results[1] as DataQualityReport?;
    setState(() {
      _snapshot = snap;
      _actionableFindings = report?.actionableFindings ?? const [];
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

  Future<DataQualityReport?> _loadDataHealthReport() async {
    if (widget.loadDataHealth != null) {
      try {
        return await widget.loadDataHealth!();
      } catch (e, stackTrace) {
        await Sentry.captureException(e, stackTrace: stackTrace);
        return null;
      }
    }
    final uid = SupabaseBootstrap.currentUser?.id;
    if (uid == null) return null;
    try {
      return await _dataHealthController.scan(uid);
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> _reloadStatsAfterRecovery() async {
    final l10n = AppLocalizations.of(context);
    final results = await Future.wait<Object?>([
      _loader.load(
        unknownClientLabel: l10n.dashboardUnknownClient,
        untitledWorkoutLabel: l10n.dashboardUntitledWorkout,
      ),
      _loadDataHealthReport(),
    ]);
    if (!mounted) return;
    final snap = results[0]! as DashboardSnapshot;
    final report = results[1] as DataQualityReport?;
    setState(() {
      _snapshot = snap;
      _actionableFindings = report?.actionableFindings ?? const [];
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
    final greetingName = _coachDisplayName.isEmpty
        ? l10n.dashboardGreetingFallbackName
        : _coachDisplayName;

    final slimHub = primaryShellUsesRail(context);
    // Phone denser gaps toward Stitch; slim hub already compact beside the rail.
    final sectionGap = slimHub ? 16.0 : 14.0;

    return Scaffold(
      backgroundColor: hubPageBackground(context),
      appBar: StitchAppBar(
        title: slimHub ? l10n.dashboardTitle : l10n.navTabToday,
        showLogo: !slimHub,
        showTitle: !slimHub,
        actions: slimHub
            ? null
            : phoneHubUtilityActions(includeSettings: true),
      ),
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.primary,
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BillingAlertBanner(),
              const BackupReminderBanner(),
              PostInviteOnboardingCard(snapshot: snap),
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
                  SizedBox(height: sectionGap),
                ],
                if (snap != null && !snap.hasError) ...[
                  if (slimHub) ...[
                    DashboardHeroHeader(
                      displayName: greetingName,
                      dateLabel: todaySubtitle,
                    ),
                    SizedBox(height: sectionGap),
                  ] else ...[
                    // Phone: compact greeting + date (Stitch density); CTAs stay
                    // in later sections / shortcuts to avoid a tall hero stack.
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todaySubtitle,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.dashboardGreeting(greetingName),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sectionGap > 16 ? 16.0 : sectionGap),
                  ],
                  DashboardHeroMetrics(
                    theme: theme,
                    colorScheme: cs,
                    l10n: l10n,
                    snapshot: snap,
                    loading: _loading,
                    attentionExtraCount: _actionableFindings.length,
                  ),
                  SizedBox(height: sectionGap),
                  Semantics(
                    container: true,
                    label: l10n.dashboardSemanticTodayList,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DashboardSectionHeader(
                          title: slimHub
                              ? l10n.dashboardSectionAppointmentsToday
                              : l10n.dashboardSectionToday,
                          subtitle: todaySubtitle,
                          actionLabel: l10n.dashboardSeeAll,
                          onAction: () {
                            HapticFeedback.mediumImpact();
                            navigateTo(context, AppPaths.calendar);
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
                            if (_loggingTodaySession) return;
                            _loggingTodaySession = true;
                            try {
                              final ok = await _todaySessionLogHandler
                                  .logSession(
                                context: context,
                                item: item,
                              );
                              if (ok && mounted) await _loadStats();
                            } finally {
                              _loggingTodaySession = false;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: sectionGap),
                ],
                if (snap != null && !slimHub) ...[
                  const DashboardCoachToolsSection(),
                  SizedBox(height: sectionGap),
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
                          actionableFindings: _actionableFindings,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: sectionGap),
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
                  SizedBox(height: sectionGap),
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
                  SizedBox(height: sectionGap),
                  if (!slimHub) ...[
                    DashboardShortcutsSection(
                      theme: theme,
                      colorScheme: cs,
                      l10n: l10n,
                    ),
                    SizedBox(height: sectionGap),
                  ],
                ],
                if (!slimHub) ...[
                  DashboardSummaryFooter(
                    theme: theme,
                    colorScheme: cs,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 20),
                ],
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
