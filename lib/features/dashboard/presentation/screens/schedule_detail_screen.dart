import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:powercoach_studio/core/routing/app_navigation.dart';

import '../../../workouts/domain/session_execution.dart';
import '../../../workouts/domain/plan_session_status_service.dart';
import '../../../workouts/domain/plan_session_override_service.dart';
import '../../../workouts/domain/session_execution_service.dart';
import '../../../workouts/data/workout_plan_repository.dart';
import '../../../workouts/data/workout_routine_model.dart';
import '../../../workouts/presentation/widgets/plan_session_actions_sheet.dart';
import '../../../workouts/presentation/widgets/session_log_sheet.dart';
import '../../domain/plan_calendar_event.dart';
import '../../domain/session_detail_loader.dart';
import '../widgets/session_detail_view.dart';
import '../widgets/session_logger_actions_bar.dart';
import '../../../../l10n/app_localizations.dart';

class ScheduleDetailScreen extends StatefulWidget {
  const ScheduleDetailScreen({super.key});

  @override
  State<ScheduleDetailScreen> createState() => _ScheduleDetailScreenState();
}

class _ScheduleDetailScreenState extends State<ScheduleDetailScreen> {
  final SessionDetailLoader _loader = SessionDetailLoader();
  final PlanSessionStatusService _statusService = PlanSessionStatusService();
  final PlanSessionOverrideService _overrideService =
      PlanSessionOverrideService();
  final WorkoutPlanRepository _planRepo = WorkoutPlanRepository();
  final SessionExecutionService _executionService = SessionExecutionService();
  SessionDetailSnapshot? _snapshot;
  bool _loading = true;
  bool _actionBusy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _load();
    });
  }

  Future<void> _load() async {
    final l10n = AppLocalizations.of(context);
    final uri = GoRouterState.of(context).uri;
    final customerId = uri.queryParameters['customerId'] ?? '';
    final planId = uri.queryParameters['planId'] ?? '';
    final weekIndex = int.tryParse(uri.queryParameters['week'] ?? '');
    final dayIndex = int.tryParse(uri.queryParameters['day'] ?? '');
    final dateParam = uri.queryParameters['date'];
    final explicitDate = dateParam == null
        ? null
        : DateTime.tryParse(dateParam);
    if (customerId.isEmpty ||
        planId.isEmpty ||
        weekIndex == null ||
        dayIndex == null) {
      setState(() {
        _loading = false;
        _error = l10n.calendarLoadError;
      });
      return;
    }
    final snapshot = await _loader.load(
      customerId: customerId,
      planId: planId,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      explicitDate: explicitDate,
      unknownClientLabel: l10n.dashboardUnknownClient,
      untitledProgramLabel: l10n.dashboardUntitledWorkout,
    );
    if (!mounted) return;
    setState(() {
      _snapshot = snapshot;
      _loading = false;
      _error = snapshot == null ? l10n.calendarLoadError : null;
    });
  }

  Future<void> _showError() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.calendarUpdateError),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
      ),
    );
  }

  Future<_PlannedDayContext?> _plannedDay(PlanCalendarEvent event) async {
    final plan = await _planRepo.getById(event.planId);
    if (plan == null) return null;
    final routine = plan.routine;
    if (event.weekIndex < 0 ||
        event.weekIndex >= routine.weeks.length ||
        event.dayIndex < 0 ||
        event.dayIndex >= routine.weeks[event.weekIndex].days.length) {
      return null;
    }
    final day = routine.weeks[event.weekIndex].days[event.dayIndex];
    final sessionKey = WorkoutRoutine.sessionKey(
      event.weekIndex,
      event.dayIndex,
    );
    final existing = await _executionService.get(
      planId: event.planId,
      sessionKey: sessionKey,
    );
    return _PlannedDayContext(day: day, existing: existing);
  }

  Future<void> _skipSession(PlanCalendarEvent event) async {
    if (_actionBusy) return;
    setState(() => _actionBusy = true);
    try {
      await _statusService.setSessionStatus(
        planId: event.planId,
        weekIndex: event.weekIndex,
        dayIndex: event.dayIndex,
        status: PlanSessionStatus.skipped,
        sessionDate: event.day,
        source: 'schedule_detail',
      );
      if (!mounted) return;
      await _load();
    } catch (_) {
      await _showError();
    } finally {
      if (mounted) setState(() => _actionBusy = false);
    }
  }

  Future<void> _logSession(PlanCalendarEvent event) async {
    if (_actionBusy) return;
    setState(() => _actionBusy = true);
    try {
      final planned = await _plannedDay(event);
      if (!mounted) return;
      if (planned == null) {
        await _showError();
        return;
      }
      final logResult = await showSessionLogSheet(
        context: context,
        plannedExercises: planned.day.exercises,
        initialExercises: planned.existing?.exercises,
        initialNotes: planned.existing?.notes ?? '',
      );
      if (logResult == null || !mounted) return;
      await _statusService.setSessionStatus(
        planId: event.planId,
        weekIndex: event.weekIndex,
        dayIndex: event.dayIndex,
        status: PlanSessionStatus.completed,
        sessionDate: event.day,
        exercises: logResult.exercises,
        notes: logResult.notes,
        source: 'schedule_detail',
      );
      if (!mounted) return;
      await _load();
    } catch (_) {
      await _showError();
    } finally {
      if (mounted) setState(() => _actionBusy = false);
    }
  }

  Future<void> _completeSession(PlanCalendarEvent event) async {
    if (_actionBusy) return;
    setState(() => _actionBusy = true);
    try {
      final planned = await _plannedDay(event);
      if (!mounted) return;
      if (planned == null) {
        await _showError();
        return;
      }

      final existing = planned.existing;
      final alreadyLogged =
          existing != null &&
          existing.exercises.isNotEmpty &&
          existing.status == PlanSessionStatus.completed;

      if (alreadyLogged) {
        await _statusService.setSessionStatus(
          planId: event.planId,
          weekIndex: event.weekIndex,
          dayIndex: event.dayIndex,
          status: PlanSessionStatus.completed,
          sessionDate: event.day,
          exercises: existing.exercises,
          notes: existing.notes,
          source: 'schedule_detail',
        );
      } else {
        final logResult = await showSessionLogSheet(
          context: context,
          plannedExercises: planned.day.exercises,
          initialExercises: existing?.exercises,
          initialNotes: existing?.notes ?? '',
        );
        if (logResult == null || !mounted) return;
        await _statusService.setSessionStatus(
          planId: event.planId,
          weekIndex: event.weekIndex,
          dayIndex: event.dayIndex,
          status: PlanSessionStatus.completed,
          sessionDate: event.day,
          exercises: logResult.exercises,
          notes: logResult.notes,
          source: 'schedule_detail',
        );
      }
      if (!mounted) return;
      await _load();
    } catch (_) {
      await _showError();
    } finally {
      if (mounted) setState(() => _actionBusy = false);
    }
  }

  Future<void> _showSessionActions(PlanCalendarEvent event) async {
    final l10n = AppLocalizations.of(context);
    final selected = await showPlanSessionActionsSheet(context);
    if (selected == null || !mounted) return;
    final originalDay = event.originalDay ?? event.day;
    try {
      if (selected.startsWith('status_')) {
        final status = switch (selected) {
          'status_completed' => PlanSessionStatus.completed,
          'status_skipped' => PlanSessionStatus.skipped,
          _ => PlanSessionStatus.planned,
        };

        if (status == PlanSessionStatus.skipped) {
          await _skipSession(event);
          return;
        }
        if (status == PlanSessionStatus.completed) {
          await _completeSession(event);
          return;
        }

        await _statusService.setSessionStatus(
          planId: event.planId,
          weekIndex: event.weekIndex,
          dayIndex: event.dayIndex,
          status: status,
          sessionDate: event.day,
          source: 'schedule_detail',
        );
      } else if (selected == 'override_skip') {
        await _overrideService.skipSessionOccurrence(
          planId: event.planId,
          weekIndex: event.weekIndex,
          dayIndex: event.dayIndex,
          originalDay: originalDay,
        );
      } else if (selected == 'override_move') {
        final picked = await showDatePicker(
          context: context,
          initialDate: event.day,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100, 12, 31),
        );
        if (picked == null || !mounted) return;
        await _overrideService.moveSessionOccurrence(
          planId: event.planId,
          weekIndex: event.weekIndex,
          dayIndex: event.dayIndex,
          originalDay: originalDay,
          movedToDate: picked,
        );
      } else if (selected == 'override_clear') {
        await _overrideService.clearSessionOccurrenceOverride(
          planId: event.planId,
          weekIndex: event.weekIndex,
          dayIndex: event.dayIndex,
          originalDay: originalDay,
        );
      }
      if (!mounted) return;
      await _load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.calendarUpdateError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final snapshot = _snapshot;
    final event = snapshot?.event;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cs.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.pop();
          },
        ),
        title: event == null
            ? Text(
                l10n.dashboardSessionTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.customerName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    DateFormat.yMMMd(l10n.localeName).format(event.day),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
        actions: event == null
            ? null
            : [
                IconButton(
                  tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showSessionActions(event),
                ),
              ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null || snapshot == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _error ?? l10n.calendarLoadError,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            )
          : SessionDetailView(
              snapshot: snapshot,
              onOpenBuilder: () {
                navigateTo(
                  context,
                  customerWorkoutEditorPath(
                    snapshot.event.customerId,
                    planId: snapshot.event.planId,
                    weekIndex: snapshot.event.weekIndex,
                    dayIndex: snapshot.event.dayIndex,
                  ),
                );
              },
            ),
      bottomNavigationBar: snapshot == null
          ? null
          : SessionLoggerActionsBar(
              busy: _actionBusy,
              onSkip: () => _skipSession(snapshot.event),
              onLog: () => _logSession(snapshot.event),
              onComplete: () => _completeSession(snapshot.event),
            ),
    );
  }
}

class _PlannedDayContext {
  const _PlannedDayContext({required this.day, required this.existing});

  final Day day;
  final SessionExecution? existing;
}
