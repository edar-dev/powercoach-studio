import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../customers/data/customer_repository.dart';
import '../../../workouts/data/workout_plan_api_model.dart';
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
  List<_ScheduleListItem> _items = const [];
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
      final schedule = plans
          .map((plan) => _toScheduleItem(plan, customerById, l10n))
          .whereType<_ScheduleListItem>()
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      setState(() {
        _items = schedule;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items = const [];
        _loading = false;
      });
    }
  }

  _ScheduleListItem? _toScheduleItem(
    WorkoutPlanApiModel plan,
    Map<String, String> customerById,
    AppLocalizations l10n,
  ) {
    try {
      final routine = planDataToRoutine(plan.planData);
      final startDate = routine.startDate;
      if (startDate == null) return null;
      final safeDate = DateTime(startDate.year, startDate.month, startDate.day);
      return _ScheduleListItem(
        date: safeDate,
        clientName: customerById[plan.customerId] ?? l10n.dashboardUnknownClient,
        programName: plan.name.trim().isEmpty ? l10n.dashboardUntitledWorkout : plan.name,
      );
    } catch (_) {
      return null;
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
          : _items.isEmpty
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
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                final time = DateFormat('dd MMM').format(item.date).toUpperCase();
                final period = DateFormat('EEE').format(item.date).toUpperCase();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ScheduleTile(
                    theme: theme,
                    cs: cs,
                    time: time,
                    period: period,
                    clientName: item.clientName,
                    programName: item.programName,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      context.push(
                        Uri(
                          path: '/dashboard/schedule/detail',
                          queryParameters: {
                            'time': time,
                            'period': period,
                            'client': item.clientName,
                            'program': item.programName,
                          },
                        ).toString(),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class _ScheduleListItem {
  const _ScheduleListItem({
    required this.date,
    required this.clientName,
    required this.programName,
  });

  final DateTime date;
  final String clientName;
  final String programName;
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({
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
