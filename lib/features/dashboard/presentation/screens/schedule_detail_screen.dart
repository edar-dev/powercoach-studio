import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/routing/app_navigation.dart';

import '../../../workouts/domain/session_execution.dart';
import '../../../workouts/domain/plan_session_status_service.dart';
import '../../../workouts/domain/plan_session_override_service.dart';
import '../../../workouts/data/workout_plan_repository.dart';
import '../../../workouts/presentation/widgets/session_log_sheet.dart';
import '../../domain/plan_calendar_event.dart';
import '../../domain/session_detail_loader.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/session_detail_view.dart';
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
  SessionDetailSnapshot? _snapshot;
  bool _loading = true;
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

  Future<void> _showSessionActions(PlanCalendarEvent event) async {
    final l10n = AppLocalizations.of(context);
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: Text(l10n.sessionCompleted),
              onTap: () => Navigator.of(ctx).pop('status_completed'),
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle_outline),
              title: Text(l10n.sessionSkipped),
              onTap: () => Navigator.of(ctx).pop('status_skipped'),
            ),
            ListTile(
              leading: const Icon(Icons.restart_alt),
              title: Text(l10n.sessionMarkPlanned),
              onTap: () => Navigator.of(ctx).pop('status_planned'),
            ),
            ListTile(
              leading: const Icon(Icons.event_busy_outlined),
              title: Text(l10n.sessionSkipDate),
              onTap: () => Navigator.of(ctx).pop('override_skip'),
            ),
            ListTile(
              leading: const Icon(Icons.event_repeat_outlined),
              title: Text(l10n.sessionReschedule),
              onTap: () => Navigator.of(ctx).pop('override_move'),
            ),
            ListTile(
              leading: const Icon(Icons.restart_alt),
              title: Text(l10n.sessionOverrideClear),
              onTap: () => Navigator.of(ctx).pop('override_clear'),
            ),
          ],
        ),
      ),
    );
    if (selected == null || !mounted) return;
    final originalDay = event.originalDay ?? event.day;
    try {
      if (selected.startsWith('status_')) {
        final status = switch (selected) {
          'status_completed' => PlanSessionStatus.completed,
          'status_skipped' => PlanSessionStatus.skipped,
          _ => PlanSessionStatus.planned,
        };

        List<ExecutedExercise> exercises = const [];
        var notes = '';
        if (status == PlanSessionStatus.completed) {
          final plan = await _planRepo.getById(event.planId);
          if (!mounted) return;
          if (plan != null) {
            final routine = planDataToRoutine(plan.planData);
            if (event.weekIndex < routine.weeks.length &&
                event.dayIndex <
                    routine.weeks[event.weekIndex].days.length) {
              final day =
                  routine.weeks[event.weekIndex].days[event.dayIndex];
              if (!context.mounted) return;
              final logResult = await showSessionLogSheet(
                context: context,
                plannedExercises: day.exercises,
              );
              if (logResult == null || !mounted) return;
              exercises = logResult.exercises;
              notes = logResult.notes;
            }
          }
        }

        await _statusService.setSessionStatus(
          planId: event.planId,
          weekIndex: event.weekIndex,
          dayIndex: event.dayIndex,
          status: status,
          sessionDate: event.day,
          exercises: exercises,
          notes: notes,
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
        title: Text(
          l10n.dashboardSessionTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
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
              onSessionActions: () => _showSessionActions(snapshot.event),
            ),
    );
  }
}
