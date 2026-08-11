import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../core/theme/stitch_m3_theme.dart';
import '../../../../core/ui/widgets/app_sheet.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../dashboard/domain/plan_calendar_event.dart';
import '../../../workouts/data/workout_plan_api_model.dart';
import '../../../workouts/data/workout_plan_repository.dart';
import '../../../../core/notifications/calendar_reminder_scheduler.dart';
import '../../../workouts/domain/session_execution_service.dart';
import '../../../workouts/domain/workout_plan_list_helpers.dart';
import '../../../workouts/presentation/workout_plan_display_helpers.dart';
import '../../../workouts/presentation/widgets/workout_plan_name_prompt_dialog.dart';
import '../customer_workout_follow_up.dart';
import '../customer_workout_plan_session_handler.dart';
import 'customer_new_workout_sheet.dart';
import 'customer_workout_plan_list.dart';
import 'customer_workout_plan_list_tile.dart';

/// Reusable customer workout plans list (FAB + filters). Used on full screen and detail tab.
class CustomerWorkoutPlansBody extends StatefulWidget {
  const CustomerWorkoutPlansBody({
    super.key,
    required this.customerId,
    this.embeddedInTab = false,
    this.onPlansChanged,
  });

  final String customerId;
  final bool embeddedInTab;
  final VoidCallback? onPlansChanged;

  @override
  State<CustomerWorkoutPlansBody> createState() =>
      _CustomerWorkoutPlansBodyState();
}

class _CustomerWorkoutPlansBodyState extends State<CustomerWorkoutPlansBody> {
  final WorkoutPlanRepository _planRepo = WorkoutPlanRepository();
  final SessionExecutionService _executionService = SessionExecutionService();
  late final CustomerWorkoutPlanSessionHandler _sessionHandler;
  List<WorkoutPlanApiModel> _plans = [];
  bool _loading = true;
  String? _error;
  String _searchQuery = '';
  WorkoutPlanFilter _filter = WorkoutPlanFilter.all;
  final WorkoutPlanSort _sort = WorkoutPlanSort.startDateDesc;

  List<WorkoutPlanApiModel> get _visiblePlans => applyWorkoutPlanListQuery(
    plans: _plans,
    filter: _filter,
    sort: _sort,
    searchQuery: _searchQuery,
  );

  @override
  void initState() {
    super.initState();
    _sessionHandler = CustomerWorkoutPlanSessionHandler();
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
    final shouldReload = await _sessionHandler.handleSessionLongPress(
      context,
      event,
    );
    if (shouldReload && mounted) {
      await _loadPlans();
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
        widget.onPlansChanged?.call();
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

  void _openPlanDiff(WorkoutPlanApiModel plan) {
    navigateTo(
      context,
      planDiffPath(customerId: widget.customerId, planIdA: plan.id),
    );
  }

  Future<void> _openNewWorkoutSheet() async {
    HapticFeedback.mediumImpact();
    await showCustomerNewWorkoutSheet(
      context,
      customerId: widget.customerId,
      planRepo: _planRepo,
    );
    if (mounted) {
      await _loadPlans();
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
      onScheduleEmptyTap: () => _openWorkoutEditor(planId: plan.id),
      onCreateFollowUp: () => _createFollowUpWorkout(plan),
      onDuplicate: () => _duplicatePlan(plan),
      onSaveAsTemplate: () => _savePlanAsTemplate(plan),
      onCompare: _plans.length > 1 ? () => _openPlanDiff(plan) : null,
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

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
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
      );
    }

    return Stack(
      children: [
        if (_plans.isEmpty)
          const CustomerWorkoutPlanEmptyState()
        else if (_visiblePlans.isEmpty)
          CustomerWorkoutPlanNoMatchState(
            selectedFilter: _filter,
            onSearchQueryChanged: (value) =>
                setState(() => _searchQuery = value),
            onFilterChanged: (filter) => setState(() => _filter = filter),
          )
        else
          RefreshIndicator(
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
        if (!_loading && _error == null)
          Positioned(
            right: widget.embeddedInTab ? 0 : 16,
            bottom: widget.embeddedInTab ? 0 : 16,
            child: FloatingActionButton.extended(
              onPressed: _openNewWorkoutSheet,
              icon: const Icon(Icons.add),
              label: Text(l10n.customerAssignWorkout),
              backgroundColor: StitchM3Theme.accent,
            ),
          ),
      ],
    );
  }

  Future<void> _savePlanAsTemplate(WorkoutPlanApiModel plan) async {
    final l10n = AppLocalizations.of(context);
    final name = await showWorkoutPlanNamePromptDialog(
      context,
      title: l10n.workoutTemplatesSaveAsTemplateTitle,
      nameLabel: l10n.workoutTemplatesNameHint,
      confirmLabel: l10n.workoutTemplatesSaveAsTemplate,
      initialName: plan.name,
    );
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
    await createCustomerWorkoutFollowUp(
      context,
      customerId: widget.customerId,
      plan: plan,
      planRepo: _planRepo,
      executionService: _executionService,
      onSuccess: () async {
        if (!mounted) return;
        await _loadPlans();
      },
    );
  }

  Future<void> _duplicatePlan(WorkoutPlanApiModel plan) async {
    final l10n = AppLocalizations.of(context);
    final name = await showWorkoutPlanNamePromptDialog(
      context,
      title: l10n.workoutDuplicateTitle,
      nameLabel: l10n.workoutDuplicateNameHint,
      confirmLabel: l10n.workoutDuplicateAction,
      initialName: '${plan.name} (2)',
    );
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
    final l10n = AppLocalizations.of(context);
    try {
      await _planRepo.archivePlan(plan.id);
      await CalendarReminderScheduler.instance.rescheduleUpcoming();
      if (!mounted) return;
      await _loadPlans();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutActionFailed),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }

  Future<void> _unarchivePlan(WorkoutPlanApiModel plan) async {
    final l10n = AppLocalizations.of(context);
    try {
      await _planRepo.unarchivePlan(plan.id);
      await CalendarReminderScheduler.instance.rescheduleUpcoming();
      if (!mounted) return;
      await _loadPlans();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutActionFailed),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }

  Future<void> _markPlanCompleted(WorkoutPlanApiModel plan) async {
    final l10n = AppLocalizations.of(context);
    try {
      await _planRepo.markPlanCompleted(plan.id);
      if (!mounted) return;
      await _loadPlans();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutActionFailed),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }
}
