import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:powercoach_studio/core/routing/app_navigation.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import '../../../dashboard/domain/plan_calendar_event.dart';
import '../../../workouts/data/workout_plan_api_model.dart';
import '../../../workouts/data/workout_plan_repository.dart';
import '../../../../core/notifications/calendar_reminder_scheduler.dart';
import '../../../workouts/domain/plan_session_status_service.dart';
import '../../../workouts/domain/plan_session_override_service.dart';
import '../../../workouts/domain/session_execution_service.dart';
import '../../../workouts/domain/workout_follow_up_factory.dart';
import '../../../workouts/domain/workout_plan_list_helpers.dart';
import '../../../workouts/presentation/workout_plan_display_helpers.dart';
import '../widgets/customer_workout_plan_list.dart';
import '../widgets/customer_workout_plan_list_tile.dart';

/// Lista workout del cliente – route /customers/:id/workouts.
/// Carica i piani dall'API (WorkoutPlanRepository) e permette di aprirli in modifica.
class CustomerWorkoutsScreen extends StatefulWidget {
  const CustomerWorkoutsScreen({super.key, required this.customerId});

  final String customerId;

  @override
  State<CustomerWorkoutsScreen> createState() => _CustomerWorkoutsScreenState();
}

class _CustomerWorkoutsScreenState extends State<CustomerWorkoutsScreen> {
  final WorkoutPlanRepository _planRepo = WorkoutPlanRepository();
  final PlanSessionStatusService _sessionStatusService =
      PlanSessionStatusService();
  final PlanSessionOverrideService _sessionOverrideService =
      PlanSessionOverrideService();
  final SessionExecutionService _executionService = SessionExecutionService();
  List<WorkoutPlanApiModel> _plans = [];
  bool _loading = true;
  String? _error;
  String _searchQuery = '';
  WorkoutPlanFilter _filter = WorkoutPlanFilter.all;
  WorkoutPlanSort _sort = WorkoutPlanSort.startDateDesc;

  List<WorkoutPlanApiModel> get _visiblePlans => applyWorkoutPlanListQuery(
    plans: _plans,
    filter: _filter,
    sort: _sort,
    searchQuery: _searchQuery,
  );

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  void _openWorkoutEditor({String? planId, int? weekIndex, int? dayIndex}) {
    navigateTo(
      context,
      customerWorkoutEditorPath(
        widget.customerId,
        planId: planId,
        weekIndex: weekIndex,
        dayIndex: dayIndex,
      ),
    );
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
        await _sessionStatusService.setSessionStatus(
          planId: event.planId,
          weekIndex: event.weekIndex,
          dayIndex: event.dayIndex,
          status: status,
        );
      } else if (selected == 'override_skip') {
        await _sessionOverrideService.skipSessionOccurrence(
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
        await _sessionOverrideService.moveSessionOccurrence(
          planId: event.planId,
          weekIndex: event.weekIndex,
          dayIndex: event.dayIndex,
          originalDay: originalDay,
          movedToDate: picked,
        );
      } else if (selected == 'override_clear') {
        await _sessionOverrideService.clearSessionOccurrenceOverride(
          planId: event.planId,
          weekIndex: event.weekIndex,
          dayIndex: event.dayIndex,
          originalDay: originalDay,
        );
      }
      if (!mounted) return;
      await _loadPlans();
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

  Future<void> _loadPlans() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _planRepo.getByCustomerId(widget.customerId);
      if (mounted) {
        setState(() {
          _plans = list;
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  Widget _buildPlanTile(BuildContext context, WorkoutPlanApiModel plan) {
    final l10n = AppLocalizations.of(context);
    return CustomerWorkoutPlanListTile(
      title: plan.name.isNotEmpty ? plan.name : l10n.customerUnnamedPlan,
      subtitle: formatPlanUpdatedAt(l10n, plan.updatedAt),
      plan: plan,
      localeName: l10n.localeName,
      onSessionTap: (event) => _openWorkoutEditor(
        planId: event.planId,
        weekIndex: event.weekIndex,
        dayIndex: event.dayIndex,
      ),
      onSessionLongPress: _showSessionActions,
      onTap: () => _openWorkoutEditor(planId: plan.id),
      onCreateFollowUp: () => _createFollowUpWorkout(plan),
      onDuplicate: () => _duplicatePlan(plan),
      onSaveAsTemplate: () => _savePlanAsTemplate(plan),
      onArchive: () => _archivePlan(plan),
      onUnarchive: () => _unarchivePlan(plan),
      onMarkCompleted: () => _markPlanCompleted(plan),
      onDelete: () => _deletePlan(plan),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cs.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.mediumImpact();
            navigateBack(context, fallback: customerPath(widget.customerId));
          },
        ),
        title: Text(
          l10n.workoutsTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        actions: [
          if (!_loading && _error == null && _plans.isNotEmpty)
            PopupMenuButton<WorkoutPlanSort>(
              tooltip: l10n.customerWorkoutsSortTitle,
              icon: Icon(Icons.sort, color: cs.onSurfaceVariant),
              onSelected: (value) => setState(() => _sort = value),
              itemBuilder: (context) => WorkoutPlanSort.values
                  .map(
                    (sort) => PopupMenuItem(
                      value: sort,
                      child: Row(
                        children: [
                          if (sort == _sort)
                            Icon(
                              Icons.check,
                              size: 18,
                              color: StitchM3Theme.accent,
                            )
                          else
                            const SizedBox(width: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(workoutPlanSortLabel(l10n, sort))),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: cs.error),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _loadPlans,
                      child: Text(l10n.customersRetry),
                    ),
                  ],
                ),
              ),
            )
          : _plans.isEmpty
          ? const CustomerWorkoutPlanEmptyState()
          : _visiblePlans.isEmpty
          ? CustomerWorkoutPlanNoMatchState(
              selectedFilter: _filter,
              onSearchQueryChanged: (value) =>
                  setState(() => _searchQuery = value),
              onFilterChanged: (filter) => setState(() => _filter = filter),
            )
          : RefreshIndicator(
              onRefresh: _loadPlans,
              child: CustomerWorkoutPlanList(
                plans: _visiblePlans,
                selectedFilter: _filter,
                onSearchQueryChanged: (value) =>
                    setState(() => _searchQuery = value),
                onFilterChanged: (filter) => setState(() => _filter = filter),
                tileBuilder: _buildPlanTile,
              ),
            ),
      floatingActionButton: !_loading && _error == null
          ? FloatingActionButton.extended(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _openWorkoutEditor();
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.customerAssignWorkout),
              backgroundColor: StitchM3Theme.accent,
            )
          : null,
    );
  }

  Future<void> _savePlanAsTemplate(WorkoutPlanApiModel plan) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: plan.name);
    String? name;
    try {
      name = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.workoutTemplatesSaveAsTemplateTitle),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: l10n.workoutTemplatesNameHint,
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.customerCancel),
            ),
            FilledButton(
              onPressed: () {
                final s = controller.text.trim();
                if (s.isEmpty) return;
                Navigator.of(ctx).pop(s);
              },
              child: Text(l10n.workoutTemplatesSaveAsTemplate),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
    if (name == null || name.isEmpty || !mounted) return;
    try {
      await _planRepo.createTemplateFromPlan(
        sourcePlanId: plan.id,
        templateName: name,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutTemplatesDuplicateSnack),
          behavior: SnackBarBehavior.floating,
          backgroundColor: StitchM3Theme.accent,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }

  Future<void> _createFollowUpWorkout(WorkoutPlanApiModel plan) async {
    final draft = await _showFollowUpDialog(plan);
    if (draft == null || !mounted) return;
    try {
      await _planRepo.createFollowUpFromPlan(
        sourcePlanId: plan.id,
        name: draft.name,
        newStartDate: draft.startDate,
        applyExecutedLoads: draft.applyExecutedLoads,
      );
      if (!mounted) return;
      await _loadPlans();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).workoutFollowUpCreatedMessage,
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: StitchM3Theme.accent,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }

  Future<void> _duplicatePlan(WorkoutPlanApiModel plan) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: '${plan.name} (2)');
    String? name;
    try {
      name = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.workoutDuplicateTitle),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: l10n.workoutDuplicateNameHint,
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.customerCancel),
            ),
            FilledButton(
              onPressed: () {
                final s = controller.text.trim();
                if (s.isEmpty) return;
                Navigator.of(ctx).pop(s);
              },
              child: Text(l10n.workoutDuplicateAction),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
    if (name == null || name.isEmpty || !mounted) return;
    try {
      await _planRepo.duplicateToCustomer(
        sourcePlanId: plan.id,
        customerId: widget.customerId,
        name: name,
      );
      if (!mounted) return;
      await _loadPlans();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutDuplicatedMessage),
          behavior: SnackBarBehavior.floating,
          backgroundColor: StitchM3Theme.accent,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }

  Future<({String name, DateTime? startDate, bool applyExecutedLoads})?>
  _showFollowUpDialog(
    WorkoutPlanApiModel plan,
  ) async {
    final l10n = AppLocalizations.of(context);
    final executions = await _executionService.listForPlan(plan.id);
    if (!mounted) return null;
    final completedCount = countCompletedExecutions(executions);
    final controller = TextEditingController(
      text: '${plan.name} - ${l10n.workoutFollowUpDefaultSuffix}',
    );
    DateTime? selectedStartDate;
    var applyExecutedLoads = completedCount > 0;
    try {
      if (!mounted) return null;
      return await showDialog<({
        String name,
        DateTime? startDate,
        bool applyExecutedLoads,
      })>(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: Text(l10n.workoutFollowUpTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: l10n.workoutFollowUpNameHint,
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: Text(
                    selectedStartDate != null
                        ? MaterialLocalizations.of(
                            ctx,
                          ).formatFullDate(selectedStartDate!)
                        : l10n.workoutFollowUpStartDateOptional,
                  ),
                  trailing: selectedStartDate != null
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: l10n.workoutFollowUpStartDateClear,
                          onPressed: () =>
                              setDialogState(() => selectedStartDate = null),
                        )
                      : null,
                  onTap: () async {
                    final now = DateTime.now();
                    final initial =
                        selectedStartDate ??
                        DateTime(now.year, now.month, now.day);
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: initial,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(now.year + 10, 12, 31),
                    );
                    if (picked == null) return;
                    setDialogState(() {
                      selectedStartDate = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                      );
                    });
                  },
                ),
                if (completedCount > 0)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: applyExecutedLoads,
                    onChanged: (v) => setDialogState(
                      () => applyExecutedLoads = v ?? false,
                    ),
                    title: Text(l10n.workoutFollowUpFromExecution),
                    subtitle: Text(
                      l10n.workoutFollowUpFromExecutionHint(completedCount),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      l10n.workoutFollowUpNoExecutionData,
                      style: Theme.of(ctx).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l10n.customerCancel),
              ),
              FilledButton(
                onPressed: () {
                  final name = controller.text.trim();
                  if (name.isEmpty) return;
                  Navigator.of(ctx).pop((
                    name: name,
                    startDate: selectedStartDate,
                    applyExecutedLoads:
                        completedCount > 0 && applyExecutedLoads,
                  ));
                },
                child: Text(l10n.workoutFollowUpCreateAction),
              ),
            ],
          ),
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _deletePlan(WorkoutPlanApiModel plan) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: l10n.workoutDeleteConfirmTitle,
      message: l10n.workoutDeleteConfirmMessage,
      confirmLabel: l10n.customerDelete,
      cancelLabel: l10n.customerCancel,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    try {
      await _planRepo.delete(plan.id);
      if (!mounted) return;
      _loadPlans();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutDeletedMessage),
          behavior: SnackBarBehavior.floating,
          backgroundColor: StitchM3Theme.accent,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutDeleteError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }

  Future<void> _archivePlan(WorkoutPlanApiModel plan) async {
    try {
      await _planRepo.archivePlan(plan.id);
      await CalendarReminderScheduler.instance.rescheduleUpcoming();
      if (!mounted) return;
      await _loadPlans();
    } catch (_) {}
  }

  Future<void> _unarchivePlan(WorkoutPlanApiModel plan) async {
    try {
      await _planRepo.unarchivePlan(plan.id);
      await CalendarReminderScheduler.instance.rescheduleUpcoming();
      if (!mounted) return;
      await _loadPlans();
    } catch (_) {}
  }

  Future<void> _markPlanCompleted(WorkoutPlanApiModel plan) async {
    try {
      await _planRepo.markPlanCompleted(plan.id);
      if (!mounted) return;
      await _loadPlans();
    } catch (_) {}
  }
}