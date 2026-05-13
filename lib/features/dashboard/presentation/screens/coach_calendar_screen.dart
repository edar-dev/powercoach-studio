import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../customers/data/customer_repository.dart';
import '../../../workouts/data/workout_plan_repository.dart';
import '../../domain/calendar_event_loader.dart';
import '../../domain/plan_calendar_event.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/app_snackbar.dart';

class CoachCalendarScreen extends StatefulWidget {
  const CoachCalendarScreen({super.key});

  @override
  State<CoachCalendarScreen> createState() => _CoachCalendarScreenState();
}

class _CoachCalendarScreenState extends State<CoachCalendarScreen> {
  final CustomerRepository _customerRepo = CustomerRepository();
  final WorkoutPlanRepository _planRepo = WorkoutPlanRepository();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<PlanCalendarEvent> _events = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedDay = calendarDayOnly(DateTime.now());
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final customers = await _customerRepo.getAll();
      final plans = await _planRepo.getAll();
      if (!mounted) {
        return;
      }
      final l10n = AppLocalizations.of(context);
      final customerById = <String, String>{
        for (final customer in customers) customer.id: customer.name,
      };
      final rangeStart = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
      final rangeEnd = DateTime(_focusedDay.year, _focusedDay.month + 2, 1);
      final events = CalendarEventLoader.eventsForPlans(
        plans: plans,
        customerNamesById: customerById,
        rangeStart: rangeStart,
        rangeEndExclusive: rangeEnd,
        unknownClientLabel: l10n.dashboardUnknownClient,
        untitledProgramLabel: l10n.dashboardUntitledWorkout,
      );
      setState(() {
        _events = events;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _events = const [];
        _loading = false;
        _error = error.toString();
      });
    }
  }

  List<PlanCalendarEvent> _eventsOnDay(DateTime day) {
    final normalized = calendarDayOnly(day);
    return _events.where((event) => calendarDayOnly(event.day) == normalized).toList();
  }

  Future<void> _toggleCompleted(PlanCalendarEvent event, bool completed) async {
    try {
      await _planRepo.setSessionCompleted(
        planId: event.planId,
        weekIndex: event.weekIndex,
        dayIndex: event.dayIndex,
        completed: completed,
      );
      await _loadEvents();
    } catch (_) {
      if (!mounted) {
        return;
      }
      showAppSnackBar(
        context,
        content: Text(AppLocalizations.of(context).calendarUpdateError),
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
      );
    }
  }

  Color _eventColor(String customerId, ColorScheme colorScheme) {
    final hash = customerId.hashCode.abs();
    final palette = <Color>[
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.primaryContainer,
    ];
    return palette[hash % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final locale = l10n.localeName;
    final selectedDay = _selectedDay ?? calendarDayOnly(DateTime.now());
    final dayEvents = _eventsOnDay(selectedDay);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.calendarTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.pop();
          },
        ),
      ),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.calendarLoadError, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _loadEvents,
                      child: Text(l10n.customersRetry),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadEvents,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: TableCalendar<PlanCalendarEvent>(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2035, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        eventLoader: _eventsOnDay,
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        locale: locale,
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: BoxDecoration(
                            color: colorScheme.tertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        headerStyle: HeaderStyle(
                          titleCentered: true,
                          formatButtonVisible: false,
                        ),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = calendarDayOnly(selectedDay);
                            _focusedDay = focusedDay;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                          _loadEvents();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    DateFormat.yMMMMd(locale).format(selectedDay),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (dayEvents.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          l10n.calendarEmptyMonth,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    ...dayEvents.map((event) {
                      final color = _eventColor(event.customerId, colorScheme);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: color.withValues(alpha: 0.2),
                            child: Icon(Icons.fitness_center, color: color, size: 20),
                          ),
                          title: Text(event.customerName),
                          subtitle: Text('${event.programName} · ${event.sessionLabel}'),
                          trailing: Checkbox(
                            value: event.status == PlanSessionStatus.completed,
                            onChanged: (value) => _toggleCompleted(event, value ?? false),
                          ),
                          onTap: () {
                            context.push('/customers/${event.customerId}/workouts');
                          },
                          onLongPress: () async {
                            await _planRepo.setSessionCompleted(
                              planId: event.planId,
                              weekIndex: event.weekIndex,
                              dayIndex: event.dayIndex,
                              completed: false,
                              skipped: event.status != PlanSessionStatus.skipped,
                            );
                            await _loadEvents();
                          },
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
