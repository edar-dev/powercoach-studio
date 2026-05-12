import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../customers/data/customer_repository.dart';
import '../../../customers/presentation/widgets/customer_reminder_sheet.dart';
import '../../../workouts/data/workout_plan_api_model.dart';
import '../../../workouts/data/workout_plan_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/stitch_m3_theme.dart';

/// Coach Dashboard – Stitch screen ID 285387f9d39c459a989d6060a1c486b0.
/// Weekly progress, stats (clients, programs), Add Client / Create Program, Today's Schedule.
class CoachDashboardScreen extends StatefulWidget {
  const CoachDashboardScreen({super.key});

  @override
  State<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

class _CoachDashboardScreenState extends State<CoachDashboardScreen> {
  final CustomerRepository _customerRepo = CustomerRepository();
  final WorkoutPlanRepository _workoutPlanRepo = WorkoutPlanRepository();
  _DashboardStats _stats = const _DashboardStats.empty();
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadStats();
    });
  }

  Future<void> _loadStats() async {
    try {
      final customers = await _customerRepo.getAll();
      final plans = await _workoutPlanRepo.getAll();
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final customerById = <String, String>{
        for (final c in customers) c.id: c.name,
      };
      final weekRange = _currentWeekRange(DateTime.now());
      final weeklyUpdates = plans.where((plan) {
        final updatedDay = DateTime(
          plan.updatedAt.year,
          plan.updatedAt.month,
          plan.updatedAt.day,
        );
        return !updatedDay.isBefore(weekRange.start) &&
            updatedDay.isBefore(weekRange.endExclusive);
      }).length;
      final todaySchedule = plans
          .map((plan) {
            final startDate = _planStartDate(plan);
            if (startDate == null) return null;
            if (!_isSameDay(startDate, DateTime.now())) return null;
            return _TodayScheduleItem(
              date: startDate,
              clientName: customerById[plan.customerId] ?? l10n.dashboardUnknownClient,
              programName: plan.name.trim().isEmpty ? l10n.dashboardUntitledWorkout : plan.name,
            );
          })
          .whereType<_TodayScheduleItem>()
          .toList()
        ..sort((a, b) => a.clientName.compareTo(b.clientName));
      if (mounted) {
        setState(() {
          _stats = _DashboardStats(
            clientCount: customers.length,
            activePrograms: plans.length,
            weeklyUpdates: weeklyUpdates,
            todaySchedule: todaySchedule,
          );
          _loadingStats = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _stats = const _DashboardStats.empty();
          _loadingStats = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

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
              // Weekly Progress
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.trending_up, size: 20, color: StitchM3Theme.accent),
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
                      _loadingStats ? '–' : '${_stats.weeklyUpdates}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      l10n.dashboardPlansUpdatedThisWeek,
                      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Stats row
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      theme: theme,
                      cs: cs,
                      value: _loadingStats ? '–' : '${_stats.clientCount}',
                      label: l10n.dashboardTotalClients,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      theme: theme,
                      cs: cs,
                      value: _loadingStats ? '–' : '${_stats.activePrograms}',
                      label: l10n.dashboardActivePrograms,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Add Client / Create Program
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        context.push('/customers/new');
                      },
                      icon: const Icon(Icons.person_add, size: 20),
                      label: Text(l10n.customersAddCustomer),
                      style: FilledButton.styleFrom(
                        backgroundColor: StitchM3Theme.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg)),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // Today's Schedule
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.dashboardTodaySchedule,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      context.push('/dashboard/schedule');
                    },
                    child: Text(l10n.dashboardSeeAll, style: TextStyle(color: StitchM3Theme.accent, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._todayScheduleItems(context, theme, cs, _stats.todaySchedule),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _todayScheduleItems(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    List<_TodayScheduleItem> schedule,
  ) {
    final l10n = AppLocalizations.of(context);
    final localeName = l10n.localeName;
    if (_loadingStats) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (schedule.isEmpty) {
      return [
        _SectionCard(
          child: Text(
            l10n.dashboardNoScheduleToday,
            style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      ];
    }
    return schedule.take(4).map((item) {
      final dateLabel =
          DateFormat('dd MMM', localeName).format(item.date).toUpperCase();
      final weekdayLabel =
          DateFormat('EEE', localeName).format(item.date).toUpperCase();
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _ScheduleCard(
          theme: theme,
          cs: cs,
          time: dateLabel,
          period: weekdayLabel,
          clientName: item.clientName,
          programName: item.programName,
          onTap: () {
            HapticFeedback.mediumImpact();
            context.push(
              Uri(
                path: '/dashboard/schedule/detail',
                queryParameters: {
                  'time': dateLabel,
                  'period': weekdayLabel,
                  'client': item.clientName,
                  'program': item.programName,
                },
              ).toString(),
            );
          },
        ),
      );
    }).toList();
  }

  ({DateTime start, DateTime endExclusive}) _currentWeekRange(DateTime now) {
    final dayStart = DateTime(now.year, now.month, now.day);
    final weekStart = dayStart.subtract(Duration(days: now.weekday - DateTime.monday));
    return (start: weekStart, endExclusive: weekStart.add(const Duration(days: 7)));
  }

  DateTime? _planStartDate(WorkoutPlanApiModel plan) {
    try {
      final routine = planDataToRoutine(plan.planData);
      final startDate = routine.startDate;
      if (startDate == null) return null;
      return DateTime(startDate.year, startDate.month, startDate.day);
    } catch (_) {
      return null;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _DashboardStats {
  const _DashboardStats({
    required this.clientCount,
    required this.activePrograms,
    required this.weeklyUpdates,
    required this.todaySchedule,
  });

  const _DashboardStats.empty()
      : clientCount = 0,
        activePrograms = 0,
        weeklyUpdates = 0,
        todaySchedule = const [];

  final int clientCount;
  final int activePrograms;
  final int weeklyUpdates;
  final List<_TodayScheduleItem> todaySchedule;
}

class _TodayScheduleItem {
  const _TodayScheduleItem({
    required this.date,
    required this.clientName,
    required this.programName,
  });

  final DateTime date;
  final String clientName;
  final String programName;
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
      ),
      child: child,
    );
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
            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
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
                    style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
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
                      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
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
