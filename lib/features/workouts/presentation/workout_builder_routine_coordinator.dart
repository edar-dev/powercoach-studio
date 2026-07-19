import 'package:flutter/material.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import '../../customers/data/customer_repository.dart';
import '../../customers/data/models/customer.dart' show Customer;
import '../data/workout_draft_store.dart';
import '../data/workout_plan_repository.dart';
import '../data/workout_routine_model.dart';
import '../domain/day_scheduled_weekday.dart';
import '../domain/workout_routine_plan_encoder.dart';
import 'widgets/assign_template_customer_dialog.dart';
import 'workout_builder_editor_exit.dart';
import 'workout_builder_load_helpers.dart';
import 'workout_builder_session_controller.dart';
import 'workout_editor_controller.dart';
import 'workout_editor_snapshot.dart';

/// Load/save/exit orchestration for the workout builder screen.
class WorkoutBuilderRoutineCoordinator {
  WorkoutBuilderRoutineCoordinator({
    required this.builderSession,
    required this.editorController,
    required this.planRepo,
    required this.customerRepo,
    required this.draftStore,
    required this.routineNameController,
    required this.initialWeekController,
    required this.phaseController,
    required this.tagsController,
    required this.notesController,
  });

  final WorkoutBuilderSessionController builderSession;
  final WorkoutEditorController editorController;
  final WorkoutPlanRepository planRepo;
  final CustomerRepository customerRepo;
  final WorkoutDraftStore draftStore;
  final TextEditingController routineNameController;
  final TextEditingController initialWeekController;
  final TextEditingController phaseController;
  final TextEditingController tagsController;
  final TextEditingController notesController;

  WorkoutEditorSession editorSession({required int initialWeekNumber}) {
    final parsedInitialWeek = int.tryParse(initialWeekController.text.trim());
    final resolvedInitialWeek =
        (parsedInitialWeek != null && parsedInitialWeek >= 1)
        ? parsedInitialWeek
        : initialWeekNumber;
    return WorkoutEditorSession(
      routine: builderSession.routine,
      planName: routineNameController.text,
      initialWeekNumber: resolvedInitialWeek,
      phase: phaseController.text,
      tags: tagsController.text,
      notes: notesController.text,
    );
  }

  String standaloneSnapshot({required int initialWeekNumber}) =>
      buildWorkoutEditorSnapshot(
        routine: builderSession.routine,
        planName: routineNameController.text,
        initialWeekNumber: initialWeekNumber,
        phase: phaseController.text,
        tags: tagsController.text,
        notes: notesController.text,
      );

  Future<WorkoutRoutine> loadStandaloneDraft() async {
    return hydrateScheduledWeekdays(await draftStore.load());
  }

  Future<WorkoutBuilderEditorLoadResult> loadEditorPlan({
    required String customerId,
    String? planId,
    int? pendingWeekIndex,
    int? pendingDayIndex,
  }) async {
    Customer? customer;
    editorController.suspendTracking();
    String? loadedPlanId;
    var loadedInitialWeek = 1;
    WorkoutRoutine? loadedRoutine;
    var weekIndex = 0;
    var dayIndex = 0;
    var phase = '';
    var tags = '';
    var notes = '';
    var planCompleted = false;
    var planArchived = false;

    if (planId != null && planId.isNotEmpty) {
      final plan = await planRepo.getById(planId);
      if (plan != null) {
        final snapshot = buildEditorPlanSnapshot(
          plan,
          pendingWeekIndex: pendingWeekIndex,
          pendingDayIndex: pendingDayIndex,
        );
        loadedPlanId = plan.id;
        loadedInitialWeek = snapshot.initialWeekNumber;
        loadedRoutine = snapshot.routine;
        weekIndex = snapshot.weekIndex;
        dayIndex = snapshot.dayIndex;
        phase = snapshot.phase;
        tags = snapshot.tags;
        notes = snapshot.notes;
        planCompleted = snapshot.planCompleted;
        planArchived = snapshot.planArchived;
      }
    }

    try {
      customer = await customerRepo.getById(customerId);
    } catch (_) {}

    return WorkoutBuilderEditorLoadResult(
      customer: customer,
      loadedPlanId: loadedPlanId,
      loadedInitialWeek: loadedInitialWeek,
      routine: loadedRoutine,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      phase: phase,
      tags: tags,
      notes: notes,
      planCompleted: planCompleted,
      planArchived: planArchived,
    );
  }

  Future<WorkoutBuilderSaveOutcome> saveRoutine({
    required BuildContext context,
    required bool editorMode,
    String? customerId,
    required int initialWeekNumber,
    Customer? editorCustomer,
    required int selectedWeekIndex,
    required int selectedDayIndex,
    bool silent = false,
  }) async {
    if (editorMode && customerId != null) {
      if (editorController.saving) {
        return const WorkoutBuilderSaveOutcome(success: false);
      }
      final outcome = await editorController.save(
        session: editorSession(initialWeekNumber: initialWeekNumber),
        customerId: customerId,
        pdfHeader: editorCustomer?.pdfHeader,
        useCustomPdfHeader: editorCustomer?.useCustomPdfHeader ?? false,
        silent: silent,
      );
      if (!context.mounted) {
        return WorkoutBuilderSaveOutcome(success: outcome.success);
      }
      if (outcome.success) {
        if (!silent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).workoutBuilderPlanSaved,
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: StitchM3Theme.accent,
            ),
          );
        }
        final createdPlanId = outcome.createdPlanId;
        if (createdPlanId != null && createdPlanId.isNotEmpty) {
          navigateReplace(
            context,
            customerWorkoutEditorPath(
              customerId,
              planId: createdPlanId,
              weekIndex: selectedWeekIndex,
              dayIndex: selectedDayIndex,
            ),
          );
        }
      } else if (silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).workoutEditorAutosaveFailed,
            ),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: AppLocalizations.of(context).workoutEditorRetrySave,
              onPressed: () {
                saveRoutine(
                  context: context,
                  editorMode: editorMode,
                  customerId: customerId,
                  initialWeekNumber: initialWeekNumber,
                  editorCustomer: editorCustomer,
                  selectedWeekIndex: selectedWeekIndex,
                  selectedDayIndex: selectedDayIndex,
                );
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).workoutExportError),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
          ),
        );
      }
      return WorkoutBuilderSaveOutcome(
        success: outcome.success,
        savedRoutine: outcome.savedRoutine,
        savedInitialWeekNumber: outcome.savedInitialWeekNumber,
      );
    }

    final name = routineNameController.text.trim();
    final toSave = builderSession.routine.copyWith(
      name: name.isEmpty ? builderSession.routine.name : name,
    );

    try {
      await draftStore.save(toSave);
      if (!context.mounted) {
        return WorkoutBuilderSaveOutcome(success: true, savedRoutine: toSave);
      }
      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).workoutBuilderRoutineSaved,
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: StitchM3Theme.accent,
          ),
        );
      }
      return WorkoutBuilderSaveOutcome(success: true, savedRoutine: toSave);
    } catch (_) {
      if (!context.mounted) {
        return const WorkoutBuilderSaveOutcome(success: false);
      }
      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).workoutExportError),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
          ),
        );
      }
      return const WorkoutBuilderSaveOutcome(success: false);
    }
  }

  Future<void> handleExitAttempt({
    required BuildContext context,
    required bool editorMode,
    String? customerId,
    required bool isDirty,
    required Future<bool> Function({bool silent}) onSave,
  }) async {
    if (!isDirty) {
      navigateBackFromWorkoutBuilder(
        context: context,
        editorMode: editorMode,
        customerId: customerId,
      );
      return;
    }
    final action = await showWorkoutEditorUnsavedDialog(context);
    if (!context.mounted ||
        action == null ||
        action == WorkoutEditorExitAction.cancel) {
      return;
    }
    if (action == WorkoutEditorExitAction.discard) {
      navigateBackFromWorkoutBuilder(
        context: context,
        editorMode: editorMode,
        customerId: customerId,
      );
      return;
    }
    final didSave = await onSave();
    if (didSave && context.mounted) {
      navigateBackFromWorkoutBuilder(
        context: context,
        editorMode: editorMode,
        customerId: customerId,
      );
    }
  }

  Future<void> assignDraftToCustomer({
    required BuildContext context,
    required WorkoutEditorSession session,
    required int selectedWeekIndex,
    required int selectedDayIndex,
  }) async {
    final l10n = AppLocalizations.of(context);
    List<Customer> customers;
    try {
      final all = await customerRepo.getAll();
      customers = all.where((c) => !c.isArchived).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutTemplatesCustomersLoadError),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!context.mounted) return;
    if (customers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dashboardNoCustomersWithoutPlan),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final chosen = await showAssignTemplateCustomerDialog(
      context,
      customers: customers,
    );
    if (chosen == null || !context.mounted) return;

    final name = session.planName.trim();
    final routine = session.routine.copyWith(
      name: name.isEmpty ? session.routine.name : name,
    );
    try {
      final created = await planRepo.create(
        customerId: chosen.id,
        name: routine.name,
        planDataJson: encodeWorkoutRoutinePlanData(routine),
        pdfHeader: chosen.pdfHeader,
        useCustomPdfHeader: chosen.useCustomPdfHeader,
        initialWeekNumber: session.initialWeekNumber,
        phase: session.phase,
        tags: session.tags,
        notes: session.notes,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutBuilderAssignDraftSuccess),
          behavior: SnackBarBehavior.floating,
          backgroundColor: StitchM3Theme.accent,
        ),
      );
      navigateReplace(
        context,
        customerWorkoutEditorPath(
          chosen.id,
          planId: created.id,
          weekIndex: selectedWeekIndex,
          dayIndex: selectedDayIndex,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutExportError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }

  Future<void> markPlanCompleted({
    required BuildContext context,
    required String planId,
    required WorkoutRoutine routine,
    required void Function(WorkoutRoutine updatedRoutine) onRoutineUpdated,
  }) async {
    final l10n = AppLocalizations.of(context);
    try {
      await planRepo.markPlanCompleted(planId);
      if (!context.mounted) return;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      onRoutineUpdated(
        routine.copyWith(endDate: routine.endDate ?? today),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutPlanCompleteAction),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutExportError),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class WorkoutBuilderEditorLoadResult {
  const WorkoutBuilderEditorLoadResult({
    this.customer,
    this.loadedPlanId,
    required this.loadedInitialWeek,
    this.routine,
    required this.weekIndex,
    required this.dayIndex,
    this.phase = '',
    this.tags = '',
    this.notes = '',
    this.planCompleted = false,
    this.planArchived = false,
  });

  final Customer? customer;
  final String? loadedPlanId;
  final int loadedInitialWeek;
  final WorkoutRoutine? routine;
  final int weekIndex;
  final int dayIndex;
  final String phase;
  final String tags;
  final String notes;
  final bool planCompleted;
  final bool planArchived;
}

class WorkoutBuilderSaveOutcome {
  const WorkoutBuilderSaveOutcome({
    required this.success,
    this.savedRoutine,
    this.savedInitialWeekNumber,
  });

  final bool success;
  final WorkoutRoutine? savedRoutine;
  final int? savedInitialWeekNumber;
}
