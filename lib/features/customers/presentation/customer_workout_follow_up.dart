import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/routing/app_navigation.dart';
import '../../../core/ui/widgets/cloud_save_feedback.dart';
import '../../../l10n/app_localizations.dart';
import '../../workouts/data/workout_plan_api_model.dart';
import '../../workouts/data/workout_plan_repository.dart';
import '../../workouts/domain/session_execution_service.dart';
import '../../workouts/presentation/widgets/workout_follow_up_dialog.dart';

/// Shared follow-up creation flow for customer workout lists and overview.
///
/// Returns the created plan, or `null` if the user cancelled or creation failed.
Future<WorkoutPlanApiModel?> createCustomerWorkoutFollowUp(
  BuildContext context, {
  required String customerId,
  required WorkoutPlanApiModel plan,
  required FutureOr<void> Function() onSuccess,
  WorkoutPlanRepository? planRepo,
  SessionExecutionService? executionService,
  bool openEditor = true,
}) async {
  final l10n = AppLocalizations.of(context);
  final repo = planRepo ?? WorkoutPlanRepository();
  final execution = executionService ?? SessionExecutionService();
  final draft = await showWorkoutFollowUpDialog(
    context,
    plan: plan,
    executionService: execution,
  );
  if (draft == null || !context.mounted) return null;

  try {
    final created = await repo.createFollowUpFromPlan(
      sourcePlanId: plan.id,
      name: draft.name,
      newStartDate: draft.startDate,
      applyExecutedLoads: draft.applyExecutedLoads,
    );
    if (!context.mounted) return created;
    await onSuccess();
    if (!context.mounted) return created;
    showCloudSaveSuccessSnackBar(
      context,
      message: l10n.workoutFollowUpCreatedMessage,
    );
    if (openEditor) {
      navigateTo(
        context,
        customerWorkoutEditorPath(customerId, planId: created.id),
      );
    }
    return created;
  } catch (e) {
    if (!context.mounted) return null;
    showCloudSaveErrorSnackBar(
      context,
      e,
      fallbackMessage: l10n.workoutActionFailed,
    );
    return null;
  }
}
