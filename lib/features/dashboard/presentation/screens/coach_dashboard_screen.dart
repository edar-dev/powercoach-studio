import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import '../../../customers/presentation/widgets/customer_reminder_sheet.dart';
import '../../data/dashboard_snapshot_loader.dart';
import '../../domain/dashboard_snapshot.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_empty_placeholder.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_surface_card.dart';

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
              context.push('/profile');
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: cs.outline, height: 1),
        ),
      ),
      drawer: _DashboardDrawer(theme: theme, cs: cs),
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
                        ..._buildTodayRows(context, theme, cs, l10n, snap),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
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
                        ..._buildAttentionSection(
                          context,
                          theme,
                          cs,
                          l10n,
                          snap,
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
                        ..._buildNoPlanRows(context, theme, cs, l10n, snap),
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
                        ..._buildStaleRows(context, theme, cs, l10n, snap),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
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
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (_loading && snap == null)
                            ? '–'
                            : '${snap?.weeklyUpdates ?? 0}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        l10n.dashboardPlansUpdatedThisWeek,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        theme: theme,
                        cs: cs,
                        value: (_loading && snap == null)
                            ? '–'
                            : '${snap?.clientCount ?? 0}',
                        label: l10n.dashboardTotalClients,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        theme: theme,
                        cs: cs,
                        value: (_loading && snap == null)
                            ? '–'
                            : '${snap?.activePrograms ?? 0}',
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
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTodayRows(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    AppLocalizations l10n,
    DashboardSnapshot snap,
  ) {
    if (_loading && snap.todayItems.isEmpty && !snap.hasError) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    final items = snap.todayItems.take(kDashboardSectionRowLimit).toList();
    if (items.isEmpty) {
      return [
        DashboardEmptyPlaceholder(
          message: l10n.dashboardNoScheduleToday,
          icon: Icons.event_available_outlined,
        ),
      ];
    }
    final localeName = l10n.localeName;
    return items.map((item) {
      final dateLabel = DateFormat(
        'dd MMM',
        localeName,
      ).format(item.date).toUpperCase();
      final weekdayLabel = DateFormat(
        'EEE',
        localeName,
      ).format(item.date).toUpperCase();
      final programLabel = item.programName.trim().isEmpty
          ? l10n.dashboardUntitledWorkout
          : item.programName;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _ScheduleCard(
          theme: theme,
          cs: cs,
          time: dateLabel,
          period: weekdayLabel,
          clientName: item.clientName,
          programName: programLabel,
          onTap: () {
            HapticFeedback.mediumImpact();
            navigateTo(
              context,
              scheduleSessionDetailPath(
                customerId: item.customerId,
                planId: item.planId,
                weekIndex: item.weekIndex,
                dayIndex: item.dayIndex,
                date: item.date,
              ),
            );
          },
        ),
      );
    }).toList();
  }

  List<Widget> _buildAttentionSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    AppLocalizations l10n,
    DashboardSnapshot snap,
  ) {
    return [
      DashboardEmptyPlaceholder(
        message: l10n.dashboardNoPending,
        icon: Icons.cloud_done_outlined,
      ),
      const SizedBox(height: 8),
      DashboardSurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dashboardBackupHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                context.push('/settings');
              },
              child: Text(l10n.dashboardOpenBackupSettings),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildNoPlanRows(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    AppLocalizations l10n,
    DashboardSnapshot snap,
  ) {
    if (snap.customersWithoutPlan.isEmpty) {
      return [
        DashboardEmptyPlaceholder(
          message: l10n.dashboardNoCustomersWithoutPlan,
          icon: Icons.people_outline,
        ),
      ];
    }
    return snap.customersWithoutPlan.map((c) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
          child: InkWell(
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
            onTap: () {
              HapticFeedback.mediumImpact();
              navigateTo(context, '/customers/${c.customerId}');
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_outline, color: cs.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      c.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildStaleRows(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    AppLocalizations l10n,
    DashboardSnapshot snap,
  ) {
    if (snap.stalePlans.isEmpty) {
      return [
        DashboardEmptyPlaceholder(
          message: l10n.dashboardNoStalePlans(kStalePlanDays),
          icon: Icons.history_toggle_off_outlined,
        ),
      ];
    }
    final localeName = l10n.localeName;
    return snap.stalePlans.map((item) {
      final updated = DateFormat.yMMMd(localeName).format(item.updatedAt);
      final programLabel = item.programName.trim().isEmpty
          ? l10n.dashboardUntitledWorkout
          : item.programName;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
          child: InkWell(
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
            onTap: () {
              HapticFeedback.mediumImpact();
              navigateTo(context, '/customers/${item.customerId}/workouts');
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.edit_calendar_outlined, color: cs.secondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.clientName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          programLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          updated,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.theme,
    required this.cs,
    required this.value,
    required this.label,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.theme,
    required this.cs,
    required this.time,
    required this.period,
    required this.clientName,
    required this.programName,
    required this.onTap,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final String time;
  final String period;
  final String clientName;
  final String programName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
            border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
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
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    period,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      programName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardDrawer extends StatelessWidget {
  const _DashboardDrawer({required this.theme, required this.cs});

  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: Text(AppLocalizations.of(context).dashboardTitle),
              onTap: () {
                Navigator.of(context).pop();
                if (context.mounted) context.go('/dashboard');
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: Text(AppLocalizations.of(context).calendarTitle),
              onTap: () {
                Navigator.of(context).pop();
                if (context.mounted) context.push('/dashboard/calendar');
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: Text(AppLocalizations.of(context).customersTitle),
              onTap: () {
                Navigator.of(context).pop();
                if (context.mounted) context.go('/customers');
              },
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center),
              title: Text(AppLocalizations.of(context).dashboardWorkoutBuilder),
              onTap: () {
                Navigator.of(context).pop();
                if (context.mounted) context.push('/workouts/builder');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_outline),
              title: Text(
                AppLocalizations.of(context).workoutTemplatesDrawerLabel,
              ),
              onTap: () {
                Navigator.of(context).pop();
                if (context.mounted) context.push('/workouts/templates');
              },
            ),
            ListTile(
              leading: const Icon(Icons.library_books_outlined),
              title: Text(AppLocalizations.of(context).exerciseLibraryTitle),
              onTap: () {
                Navigator.of(context).pop();
                if (context.mounted) context.push('/exercise-library');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(AppLocalizations.of(context).headerProfile),
              onTap: () {
                Navigator.of(context).pop();
                if (context.mounted) context.push('/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(AppLocalizations.of(context).settingsTitle),
              onTap: () {
                Navigator.of(context).pop();
                if (context.mounted) context.push('/settings');
              },
            ),
          ],
        ),
      ),
    );
  }
}
