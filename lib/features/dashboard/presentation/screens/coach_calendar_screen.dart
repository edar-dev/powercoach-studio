import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/theme/stitch_mobile_colors.dart';
import '../../../../core/ui/breakpoints.dart';
import '../../../../core/ui/widgets/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../customers/data/customer_repository.dart';
import '../../../customers/data/models/customer.dart';
import '../../../workouts/data/workout_plan_repository.dart';
import '../../../workouts/domain/plan_session_status_service.dart';
import '../../domain/calendar_event_loader.dart';
import '../../domain/plan_calendar_event.dart';
import '../widgets/coach_calendar_day_summary.dart';
import '../widgets/coach_calendar_grid_card.dart';
import '../widgets/coach_calendar_toolbar.dart';

class CoachCalendarScreen extends StatefulWidget {
  const CoachCalendarScreen({super.key});

  @override
  State<CoachCalendarScreen> createState() => _CoachCalendarScreenState();
}

class _CoachCalendarScreenState extends State<CoachCalendarScreen> {
  final CustomerRepository _customerRepo = CustomerRepository();
  final WorkoutPlanRepository _planRepo = WorkoutPlanRepository();
  final PlanSessionStatusService _sessionStatusService =
      PlanSessionStatusService();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<PlanCalendarEvent> _events = const [];
  List<Customer> _customers = const [];
  String? _filterCustomerId;
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
      if (!mounted) return;
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
        _customers = customers
            .where((c) => !c.isArchived)
            .toList(growable: false);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _events = const [];
        _loading = false;
        _error = error.toString();
      });
    }
  }

  List<PlanCalendarEvent> get _filteredEvents {
    final id = _filterCustomerId;
    if (id == null || id.isEmpty) return _events;
    return _events.where((e) => e.customerId == id).toList(growable: false);
  }

  List<PlanCalendarEvent> _eventsOnDay(DateTime day) {
    final normalized = calendarDayOnly(day);
    return _filteredEvents
        .where((event) => calendarDayOnly(event.day) == normalized)
        .toList();
  }

  Future<void> _toggleCompleted(PlanCalendarEvent event, bool completed) async {
    try {
      await _sessionStatusService.setSessionStatus(
        planId: event.planId,
        weekIndex: event.weekIndex,
        dayIndex: event.dayIndex,
        status: completed
            ? PlanSessionStatus.completed
            : PlanSessionStatus.planned,
      );
      await _loadEvents();
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        content: Text(AppLocalizations.of(context).calendarUpdateError),
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
      );
    }
  }

  Future<void> _toggleSkipped(PlanCalendarEvent event) async {
    unawaited(HapticFeedback.mediumImpact());
    try {
      await _sessionStatusService.setSessionStatus(
        planId: event.planId,
        weekIndex: event.weekIndex,
        dayIndex: event.dayIndex,
        status: event.status == PlanSessionStatus.skipped
            ? PlanSessionStatus.planned
            : PlanSessionStatus.skipped,
      );
      await _loadEvents();
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        content: Text(AppLocalizations.of(context).calendarUpdateError),
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
      );
    }
  }

  void _openEvent(PlanCalendarEvent event) {
    navigateTo(
      context,
      scheduleSessionDetailPath(
        customerId: event.customerId,
        planId: event.planId,
        weekIndex: event.weekIndex,
        dayIndex: event.dayIndex,
        date: event.day,
      ),
    );
  }

  void _goToday() {
    final today = calendarDayOnly(DateTime.now());
    setState(() {
      _selectedDay = today;
      _focusedDay = today;
    });
    _loadEvents();
  }

  void _shiftMonth(int delta) {
    final next = DateTime(_focusedDay.year, _focusedDay.month + delta, 1);
    setState(() => _focusedDay = next);
    _loadEvents();
  }

  void _addSession() => navigateTo(context, '/customers');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = l10n.localeName;
    final selectedDay = _selectedDay ?? calendarDayOnly(DateTime.now());
    final dayEvents = _eventsOnDay(selectedDay);
    final monthLabel = DateFormat.yMMMM(locale).format(_focusedDay);
    final phone = !Breakpoints.isTabletOrWider(context);
    final isWide = MediaQuery.sizeOf(context).width >= 1100;

    return Scaffold(
      backgroundColor: phone
          ? StitchMobileColors.surface
          : MarketingDarkColors.stitchPageBg,
      body: SafeArea(
        child: _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.calendarLoadError,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: phone
                              ? StitchMobileColors.onSurfaceVariant
                              : MarketingDarkColors.slate300,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: phone
                              ? StitchMobileColors.primaryContainer
                              : MarketingDarkColors.brand,
                          foregroundColor: phone
                              ? StitchMobileColors.onPrimary
                              : Colors.white,
                        ),
                        onPressed: _loadEvents,
                        child: Text(l10n.customersRetry),
                      ),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                color: phone
                    ? StitchMobileColors.primary
                    : MarketingDarkColors.brandLight,
                onRefresh: _loadEvents,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    StitchMobileColors.marginMobile,
                    phone ? 8 : 16,
                    StitchMobileColors.marginMobile,
                    24,
                  ),
                  children: [
                    if (phone) ...[
                      CoachCalendarPhoneHeader(onAddSession: _addSession),
                      const SizedBox(height: 12),
                    ],
                    CoachCalendarToolbar(
                      monthLabel: monthLabel,
                      onBack: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          navigateTo(context, '/dashboard');
                        }
                      },
                      onPreviousMonth: () => _shiftMonth(-1),
                      onNextMonth: () => _shiftMonth(1),
                      onToday: _goToday,
                      onAddSession: _addSession,
                      customers: phone ? _customers : const [],
                      filterCustomerId: _filterCustomerId,
                      onFilterCustomer: phone
                          ? (id) => setState(() => _filterCustomerId = id)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    if (!phone && isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 8,
                            child: CoachCalendarGridCard(
                              focusedDay: _focusedDay,
                              selectedDay: _selectedDay,
                              locale: locale,
                              eventsOnDay: _eventsOnDay,
                              onDaySelected: (selected, focused) {
                                setState(() {
                                  _selectedDay = calendarDayOnly(selected);
                                  _focusedDay = focused;
                                });
                              },
                              onPageChanged: (focused) {
                                _focusedDay = focused;
                                _loadEvents();
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 4,
                            child: CoachCalendarDaySummary(
                              day: selectedDay,
                              events: dayEvents,
                              loading: _loading,
                              onOpen: _openEvent,
                              onToggleCompleted: _toggleCompleted,
                              onToggleSkipped: _toggleSkipped,
                            ),
                          ),
                        ],
                      )
                    else ...[
                      CoachCalendarGridCard(
                        focusedDay: _focusedDay,
                        selectedDay: _selectedDay,
                        locale: locale,
                        eventsOnDay: _eventsOnDay,
                        onDaySelected: (selected, focused) {
                          setState(() {
                            _selectedDay = calendarDayOnly(selected);
                            _focusedDay = focused;
                          });
                        },
                        onPageChanged: (focused) {
                          _focusedDay = focused;
                          _loadEvents();
                        },
                      ),
                      const SizedBox(height: 16),
                      CoachCalendarDaySummary(
                        day: selectedDay,
                        events: dayEvents,
                        loading: _loading,
                        onOpen: _openEvent,
                        onToggleCompleted: _toggleCompleted,
                        onToggleSkipped: _toggleSkipped,
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
