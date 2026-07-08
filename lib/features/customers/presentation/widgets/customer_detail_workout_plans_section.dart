import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:powercoach_studio/core/routing/app_navigation.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_api_model.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_repository.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/presentation/workout_plan_display_helpers.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

class CustomerDetailWorkoutPlansSection extends StatelessWidget {
  const CustomerDetailWorkoutPlansSection({
    super.key,
    required this.customerId,
    required this.plans,
    required this.loading,
    required this.onOpenEditor,
    required this.onPlansChanged,
  });

  final String customerId;
  final List<WorkoutPlanApiModel> plans;
  final bool loading;
  final void Function({String? planId}) onOpenEditor;
  final VoidCallback onPlansChanged;

  Future<void> _createFollowUp(
    BuildContext context,
    WorkoutPlanApiModel plan,
  ) async {
    final l10n = AppLocalizations.of(context);
    final planRepo = WorkoutPlanRepository();
    try {
      final routine = planDataToRoutine(plan.planData);
      final numWeeks = routine.weeks.isEmpty ? 1 : routine.weeks.length;
      final newStartingWeek = plan.initialWeekNumber + numWeeks;
      final emptyPlanData = jsonEncode(WorkoutRoutine.empty().toJson());
      await planRepo.create(
        customerId: customerId,
        name: l10n.workoutNewPlanName,
        planDataJson: emptyPlanData,
        initialWeekNumber: newStartingWeek,
      );
      if (!context.mounted) return;
      onPlansChanged();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutDuplicatedMessage),
          behavior: SnackBarBehavior.floating,
          backgroundColor: StitchM3Theme.accent,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }

  Future<void> _deletePlan(
    BuildContext context,
    WorkoutPlanApiModel plan,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: l10n.workoutDeleteConfirmTitle,
      message: l10n.workoutDeleteConfirmMessage,
      confirmLabel: l10n.customerDelete,
      cancelLabel: l10n.customerCancel,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    try {
      await WorkoutPlanRepository().delete(plan.id);
      if (!context.mounted) return;
      onPlansChanged();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutDeletedMessage),
          behavior: SnackBarBehavior.floating,
          backgroundColor: StitchM3Theme.accent,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutDeleteError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const int maxRecent = 5;
    final recentPlans = plans.take(maxRecent).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusXl),
        border: Border.all(
          color: StitchM3Theme.accent.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: StitchM3Theme.accent.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: StitchM3Theme.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: StitchM3Theme.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.customerWorkoutPlans,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (plans.isNotEmpty)
                TextButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    navigateTo(context, customerWorkoutsPath(customerId));
                  },
                  child: Text(
                    l10n.customerViewAll,
                    style: TextStyle(
                      color: StitchM3Theme.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (plans.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Text(
                    l10n.customerNoWorkoutPlansYet,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      onOpenEditor();
                    },
                    icon: const Icon(Icons.add_task, size: 20),
                    label: Text(l10n.customerAssignWorkout),
                    style: FilledButton.styleFrom(
                      backgroundColor: StitchM3Theme.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...recentPlans.asMap().entries.map((e) {
              final plan = e.value;
              final isLast = e.key == recentPlans.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      onOpenEditor(planId: plan.id);
                    },
                    borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius:
                            BorderRadius.circular(StitchM3Theme.radiusLg),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plan.name.isNotEmpty
                                      ? plan.name
                                      : l10n.customerUnnamedPlan,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatPlanUpdatedAt(l10n, plan.updatedAt),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_vert,
                              color: colorScheme.onSurfaceVariant,
                              size: 24,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 0),
                            onSelected: (value) {
                              HapticFeedback.mediumImpact();
                              if (value == 'follow_up') {
                                _createFollowUp(context, plan);
                              } else if (value == 'delete') {
                                _deletePlan(context, plan);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'follow_up',
                                child: Text(l10n.workoutCreateNewFromThis),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(l10n.workoutDelete),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: colorScheme.onSurfaceVariant,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
