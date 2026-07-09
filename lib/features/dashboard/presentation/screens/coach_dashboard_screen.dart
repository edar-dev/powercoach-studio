import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../customers/presentation/widgets/customer_reminder_sheet.dart';
import '../../data/dashboard_snapshot_loader.dart';
import '../../domain/dashboard_snapshot.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_coach_tools_section.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_attention_section.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_drawer.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_no_plan_section.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_stale_plans_section.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_summary_footer.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_surface_card.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_today_section.dart';

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
  DashboardSnapshot? _snapshot;
  bool _loading = true;

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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final snap = _snapshot;

    return Scaffold(
      backgroundColor: cs.surfaceContainerHighest,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: cs.surface,
        title: Text(
          l10n.dashboardTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
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
            tooltip: l10n.dashboardReminderTooltip,
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              HapticFeedback.mediumImpact();
              showDashboardReminderComposer(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              HapticFeedback.mediumImpact();
              navigateTo(context, '/profile');
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
                  Semantics(
                    container: true,
                    label: l10n.dashboardSemanticTodayList,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DashboardSectionHeader(
                          title: l10n.dashboardSectionToday,
                          actionLabel: l10n.dashboardSeeAll,
                          onAction: () {
                            HapticFeedback.mediumImpact();
                            context.push('/dashboard/schedule');
                          },
                        ),
                        const SizedBox(height: 12),
                        DashboardTodaySection(
                          theme: theme,
                          colorScheme: cs,
                          l10n: l10n,
                          snapshot: snap,
                          loading: _loading,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (snap != null) ...[
                  DashboardCoachToolsSection(),
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
                ],
                DashboardSummaryFooter(
                  theme: theme,
                  colorScheme: cs,
                  l10n: l10n,
                  snapshot: snap,
                  loading: _loading,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
