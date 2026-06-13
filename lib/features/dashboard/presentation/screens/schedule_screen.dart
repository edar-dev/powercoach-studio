import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:powercoach_studio/core/routing/app_navigation.dart';

import '../../../../core/constants/workout_plan_template_scope.dart';
import '../../../customers/data/customer_repository.dart';
import '../../domain/calendar_event_loader.dart';
import '../../domain/plan_calendar_event.dart';
import '../../../workouts/data/workout_plan_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/stitch_m3_theme.dart';

/// Lista completa "Today's Schedule" – route /dashboard/schedule.
/// Mostra solo elementi reali derivati dai piani con start date valorizzata.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final CustomerRepository _customerRepo = CustomerRepository();
  final WorkoutPlanRepository _workoutPlanRepo = WorkoutPlanRepository();
  List<PlanCalendarEvent> _events = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadSchedule();
    });
  }

  Future<void> _loadSchedule() async {
    try {
      final customers = await _customerRepo.getAll();
      final plans = await _workoutPlanRepo.getAll();
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final customerById = <String, String>{
        for (final c in customers) c.id: c.name,
      };
      final today = calendarDayOnly(DateTime.now());
      final events = CalendarEventLoader.eventsForPlans(
        plans: plans
            .where((p) => p.customerId != kWorkoutPlanTemplateScopeId)
            .toList(),
        customerNamesById: customerById,
        rangeStart: today,
        rangeEndExclusive: today.add(const Duration(days: 30)),
        unknownClientLabel: l10n.dashboardUnknownClient,
        untitledProgramLabel: l10n.dashboardUntitledWorkout,
      );
      setState(() {
        _events = events;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _events = const [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final localeName = l10n.localeName;

    return Scaffold(
      backgroundColor: cs.surfaceContainerHighest,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: cs.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.mediumImpact();
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: Text(
          l10n.dashboardTodaySchedule,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: cs.outline, height: 1),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.dashboardNoScheduledWorkoutsYet,
                  style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : _ScheduleEventsList(
              events: _events,
              theme: theme,
              cs: cs,
              localeName: localeName,
            ),
    );
  }
}

class _ScheduleEventsList extends StatelessWidget {
  const _ScheduleEventsList({
    required this.events,
    required this.theme,
    required this.cs,
    required this.localeName,
  });

  final List<PlanCalendarEvent> events;
  final ThemeData theme;
  final ColorScheme cs;
  final String localeName;

  @override
  Widget build(BuildContext context) {
    final grouped = <DateTime, List<PlanCalendarEvent>>{};
    for (final event in events) {
      final key = calendarDayOnly(event.day);
      grouped.putIfAbsent(key, () => []).add(event);
    }
    final sortedDays = grouped.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        for (final day in sortedDays) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              DateFormat.yMMMEd(localeName).format(day),
              style: theme.textTheme.titleSmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ...grouped[day]!.map((event) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SessionTile(
                  event: event,
                  theme: theme,
                  cs: cs,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    context.push(
                      customerWorkoutEditorPath(
                        event.customerId,
                        planId: event.planId,
                        weekIndex: event.weekIndex,
                        dayIndex: event.dayIndex,
                      ),
                    );
                  },
                ),
              )),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.event,
    required this.theme,
    required this.cs,
    required this.onTap,
  });

  final PlanCalendarEvent event;
  final ThemeData theme;
  final ColorScheme cs;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
            border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.customerName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${event.programName} · ${event.sessionLabel}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _StatusPill(
                label: switch (event.status) {
                  PlanSessionStatus.completed => l10n.sessionCompleted,
                  PlanSessionStatus.skipped => l10n.sessionSkipped,
                  PlanSessionStatus.planned => l10n.sessionPlanned,
                },
                color: switch (event.status) {
                  PlanSessionStatus.completed => cs.tertiary,
                  PlanSessionStatus.skipped => cs.error,
                  PlanSessionStatus.planned => cs.onSurfaceVariant,
                },
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
