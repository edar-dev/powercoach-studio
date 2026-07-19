import 'package:flutter/material.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_api_model.dart';
import 'package:powercoach_studio/features/workouts/data/workout_plan_repository.dart';
import 'package:powercoach_studio/features/workouts/domain/session_execution_service.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_follow_up_dialog.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

/// Shared follow-up creation flow for customer workout lists and overview.
Future<void> createCustomerWorkoutFollowUp(
  BuildContext context, {
  required String customerId,
  required WorkoutPlanApiModel plan,
  required VoidCallback onSuccess,
  WorkoutPlanRepository? planRepo,
  SessionExecutionService? executionService,
}) async {
  final l10n = AppLocalizations.of(context);
  final repo = planRepo ?? WorkoutPlanRepository();
  final execution = executionService ?? SessionExecutionService();
  final draft = await showWorkoutFollowUpDialog(
    context,
    plan: plan,
    executionService: execution,
  );
  if (draft == null || !context.mounted) return;

  try {
    await repo.createFollowUpFromPlan(
      sourcePlanId: plan.id,
      name: draft.name,
      newStartDate: draft.startDate,
      applyExecutedLoads: draft.applyExecutedLoads,
    );
    if (!context.mounted) return;
    onSuccess();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.workoutFollowUpCreatedMessage),
        behavior: SnackBarBehavior.floating,
        backgroundColor: StitchM3Theme.accent,
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.workoutActionFailed),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
      ),
    );
  }
}
