import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../theme/stitch_m3_theme.dart';
import '../../../../widgets/app_sheet.dart';
import '../../../workouts/data/workout_plan_api_model.dart';
import '../../../workouts/data/workout_plan_repository.dart';
import '../../../workouts/data/workout_routine_model.dart';

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
  List<WorkoutPlanApiModel> _plans = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlans();
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
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/customers');
            }
          },
        ),
        title: Text(
          l10n.workoutsTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
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
                          style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
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
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fitness_center, size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            Text(
                              l10n.workoutsNoWorkoutsYet,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.workoutsAssignHint,
                              style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPlans,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _plans.length,
                        itemBuilder: (context, index) {
                          final plan = _plans[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: index < _plans.length - 1 ? 12 : 0),
                            child: _WorkoutListCard(
                              theme: theme,
                              cs: cs,
                              title: plan.name.isNotEmpty ? plan.name : l10n.customerUnnamedPlan,
                              subtitle: _formatPlanSubtitle(l10n, plan),
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                context.push(
                                  '/workouts/editor/${plan.id}?customerId=${widget.customerId}',
                                ).then((_) {
                                  if (mounted) _loadPlans();
                                });
                              },
                              onCreateFollowUp: () => _createFollowUpWorkout(plan),
                              onSaveAsTemplate: () => _savePlanAsTemplate(plan),
                              onDelete: () => _deletePlan(plan),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: !_loading && _error == null
          ? FloatingActionButton.extended(
              onPressed: () async {
                HapticFeedback.mediumImpact();
                await context.push('/workouts/editor?customerId=${widget.customerId}');
                if (mounted) _loadPlans();
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.customerAssignWorkout),
              backgroundColor: StitchM3Theme.accent,
            )
          : null,
    );
  }

  String _formatPlanSubtitle(AppLocalizations l10n, WorkoutPlanApiModel plan) {
    final updated = plan.updatedAt;
    final now = DateTime.now();
    final diff = now.difference(updated);
    if (diff.inDays > 0) return l10n.updatedDaysAgo(diff.inDays);
    if (diff.inHours > 0) return l10n.updatedHoursAgo(diff.inHours);
    if (diff.inMinutes > 0) return l10n.updatedMinutesAgo(diff.inMinutes);
    return l10n.updatedJustNow;
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
            decoration: InputDecoration(labelText: l10n.workoutTemplatesNameHint),
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
      await _planRepo.createTemplateFromPlan(sourcePlanId: plan.id, templateName: name);
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
    try {
      final routine = planDataToRoutine(plan.planData);
      final numWeeks = routine.weeks.isEmpty ? 1 : routine.weeks.length;
      final newStartingWeek = plan.initialWeekNumber + numWeeks;
      final emptyPlanData = jsonEncode(WorkoutRoutine.empty().toJson());
      await _planRepo.create(
        customerId: widget.customerId,
        name: AppLocalizations.of(context).workoutNewPlanName,
        planDataJson: emptyPlanData,
        initialWeekNumber: newStartingWeek,
      );
      if (!mounted) return;
      _loadPlans();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).workoutDuplicatedMessage),
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
}

class _WorkoutListCard extends StatelessWidget {
  const _WorkoutListCard({
    required this.theme,
    required this.cs,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.onCreateFollowUp,
    this.onSaveAsTemplate,
    this.onDelete,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onCreateFollowUp;
  final VoidCallback? onSaveAsTemplate;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
            border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (onCreateFollowUp != null || onSaveAsTemplate != null || onDelete != null)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: cs.onSurfaceVariant, size: 24),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 0),
                  onSelected: (value) {
                    HapticFeedback.mediumImpact();
                    if (value == 'follow_up') {
                      onCreateFollowUp?.call();
                    } else if (value == 'template') {
                      onSaveAsTemplate?.call();
                    } else if (value == 'delete') {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    if (onCreateFollowUp != null)
                      PopupMenuItem(
                        value: 'follow_up',
                        child: Text(l10n.workoutCreateNewFromThis),
                      ),
                    if (onSaveAsTemplate != null)
                      PopupMenuItem(
                        value: 'template',
                        child: Text(l10n.workoutTemplatesSaveAsTemplate),
                      ),
                    if (onDelete != null)
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(l10n.workoutDelete),
                      ),
                  ],
                ),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
