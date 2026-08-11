import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_paths.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../dashboard/domain/plan_calendar_event.dart';
import '../../../dashboard/domain/session_detail_loader.dart';
import '../../data/workout_plan_repository.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/plan_session_status_service.dart';
import '../../domain/session_execution.dart';
import '../../domain/session_execution_service.dart';
import '../widgets/session_log_form_body.dart';

/// Gym mode session runner — full-page (not a bottom sheet) so a coach can
/// log a session from the gym floor: shows client/program/day, the day's
/// coaching note, and the shared session-log form with larger touch targets.
class GymSessionScreen extends StatefulWidget {
  const GymSessionScreen({super.key});

  @override
  State<GymSessionScreen> createState() => _GymSessionScreenState();
}

class _GymSessionScreenState extends State<GymSessionScreen> {
  final SessionDetailLoader _detailLoader = SessionDetailLoader();
  final WorkoutPlanRepository _planRepo = WorkoutPlanRepository();
  final SessionExecutionService _executionService = SessionExecutionService();
  final PlanSessionStatusService _statusService = PlanSessionStatusService();

  bool _loading = true;
  bool _saving = false;
  String? _error;
  SessionDetailSnapshot? _snapshot;
  Day? _day;
  SessionExecution? _existingExecution;

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
    final explicitDate = dateParam == null ? null : DateTime.tryParse(dateParam);

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

    setState(() => _loading = true);
    final snapshot = await _detailLoader.load(
      customerId: customerId,
      planId: planId,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      explicitDate: explicitDate,
      unknownClientLabel: l10n.dashboardUnknownClient,
      untitledProgramLabel: l10n.dashboardUntitledWorkout,
    );
    if (!mounted) return;
    if (snapshot == null) {
      setState(() {
        _loading = false;
        _error = l10n.calendarLoadError;
      });
      return;
    }

    final plan = await _planRepo.getById(planId);
    if (!mounted) return;
    Day? day;
    if (plan != null) {
      final routine = planDataToRoutine(plan.planData);
      if (weekIndex < routine.weeks.length &&
          dayIndex < routine.weeks[weekIndex].days.length) {
        day = routine.weeks[weekIndex].days[dayIndex];
      }
    }

    final sessionKey = WorkoutRoutine.sessionKey(weekIndex, dayIndex);
    final existing = await _executionService.get(
      planId: planId,
      sessionKey: sessionKey,
    );
    if (!mounted) return;

    setState(() {
      _snapshot = snapshot;
      _day = day;
      _existingExecution = existing;
      _loading = false;
      _error = day == null ? l10n.calendarLoadError : null;
    });
  }

  Future<void> _handleSave(SessionLogResult result) async {
    final snapshot = _snapshot;
    if (snapshot == null || _saving) return;
    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context);
    try {
      await _statusService.setSessionStatus(
        planId: snapshot.event.planId,
        weekIndex: snapshot.event.weekIndex,
        dayIndex: snapshot.event.dayIndex,
        status: PlanSessionStatus.completed,
        sessionDate: snapshot.event.day,
        exercises: result.exercises,
        notes: result.notes,
        sessionRpe: result.sessionRpe,
        painLevel: result.painLevel,
        painLocation: result.painLocation,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.gymModeLogSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppPaths.gym);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.calendarUpdateError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final snapshot = _snapshot;
    final day = _day;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cs.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).maybePop();
          },
        ),
        title: Text(
          l10n.gymModeRunnerTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null || snapshot == null || day == null)
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
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  Text(
                    snapshot.event.customerName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${snapshot.event.programName} · ${snapshot.event.sessionLabel}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  if (day.coachingNote != null &&
                      day.coachingNote!.trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.secondaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.gymModeCoachingNoteLabel,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: cs.onSecondaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            day.coachingNote!.trim(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SessionLogFormBody(
                    plannedExercises: day.exercises,
                    initialExercises: _existingExecution?.exercises,
                    initialNotes: _existingExecution?.notes ?? '',
                    initialSessionRpe: _existingExecution?.sessionRpe,
                    initialPainLevel: _existingExecution?.painLevel,
                    initialPainLocation: _existingExecution?.painLocation,
                    saveLabel: _saving
                        ? l10n.gymModeSaving
                        : l10n.gymModeSaveAndComplete,
                    expandableList: false,
                    compact: false,
                    onSave: _saving ? (_) {} : _handleSave,
                  ),
                ],
              ),
            ),
    );
  }
}
