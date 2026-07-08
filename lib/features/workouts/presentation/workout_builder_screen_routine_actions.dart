import 'package:flutter/material.dart';

import '../../customers/data/models/customer.dart' show Customer;
import '../data/workout_routine_model.dart';
import '../domain/day_scheduled_weekday.dart';
import 'workout_builder_date_picker_helpers.dart';
import 'workout_builder_export_actions.dart';
import 'workout_builder_routine_coordinator.dart';
import 'workout_builder_session_controller.dart';
import 'workout_editor_controller.dart';
import 'widgets/workout_export_sheet.dart';

/// Save, export, import, and date-picker actions for the workout builder screen.
class WorkoutBuilderScreenRoutineActions {
  WorkoutBuilderScreenRoutineActions({
    required this.context,
    required this.mounted,
    required this.setState,
    required this.coordinator,
    required this.builderSession,
    required this.editorController,
    required this.exportActions,
    required this.editorMode,
    required this.customerId,
    required this.initialWeekNumber,
    required this.editorCustomer,
    required this.selectedWeekIndex,
    required this.selectedDayIndex,
    required this.isDirty,
    required this.isStandaloneDirty,
    required this.onStandaloneSnapshotCaptured,
    required this.onPlanCompleted,
    required this.routineNameController,
    required this.onInitialWeekNumberSaved,
    required this.saving,
    required this.onSavingChanged,
  });

  final BuildContext context;
  final bool Function() mounted;
  final void Function(VoidCallback fn) setState;
  final WorkoutBuilderRoutineCoordinator coordinator;
  final WorkoutBuilderSessionController builderSession;
  final WorkoutEditorController editorController;
  final WorkoutBuilderExportActions exportActions;
  final bool editorMode;
  final String? customerId;
  final int Function() initialWeekNumber;
  final Customer? Function() editorCustomer;
  final int Function() selectedWeekIndex;
  final int Function() selectedDayIndex;
  final bool Function() isDirty;
  final bool Function() isStandaloneDirty;
  final VoidCallback onStandaloneSnapshotCaptured;
  final void Function(WorkoutRoutine updated) onPlanCompleted;
  final TextEditingController routineNameController;
  final void Function(int initialWeekNumber) onInitialWeekNumberSaved;
  final bool Function() saving;
  final void Function(bool saving) onSavingChanged;

  WorkoutRoutine get _routine => builderSession.routine;

  Future<void> pickRoutineStartDate() async {
    final picked = await pickWorkoutRoutineStartDate(
      context,
      currentStart: _routine.startDate,
    );
    if (!mounted() || picked == null) return;
    setState(() => builderSession.setRoutine(applyRoutineStartDate(_routine, picked)));
  }

  Future<void> pickRoutineEndDate() async {
    final picked = await pickWorkoutRoutineEndDate(
      context,
      startDate: _routine.startDate,
      currentEnd: _routine.endDate,
    );
    if (!mounted() || picked == null) return;
    setState(() => builderSession.setRoutine(applyRoutineEndDate(_routine, picked)));
  }

  Future<bool> saveRoutine({bool silent = false}) async {
    if (!editorMode) {
      if (saving()) return false;
      onSavingChanged(true);
    }
    final outcome = await coordinator.saveRoutine(
      context: context,
      editorMode: editorMode,
      customerId: customerId,
      initialWeekNumber: initialWeekNumber(),
      editorCustomer: editorCustomer(),
      selectedWeekIndex: selectedWeekIndex(),
      selectedDayIndex: selectedDayIndex(),
      silent: silent,
    );
    if (!mounted()) return outcome.success;
    if (outcome.savedRoutine != null) {
      setState(() {
        builderSession.setRoutine(outcome.savedRoutine!);
        if (outcome.savedInitialWeekNumber != null) {
          onInitialWeekNumberSaved(outcome.savedInitialWeekNumber!);
        }
      });
    }
    if (!editorMode) {
      onStandaloneSnapshotCaptured();
      onSavingChanged(false);
    }
    return outcome.success;
  }

  void showPdfExportSheet() {
    showWorkoutExportSheet(
      context: context,
      routine: _routine,
      onExportPdf: (options) {
        exportActions.exportPdf(
          _routine,
          layout: options.layout,
          includeMobility: options.includeMobility,
        );
      },
    );
  }

  Future<void> handleExitAttempt() async {
    await coordinator.handleExitAttempt(
      context: context,
      editorMode: editorMode,
      customerId: customerId,
      isDirty: editorMode ? isDirty() : isStandaloneDirty(),
      onSave: ({bool silent = false}) => saveRoutine(silent: silent),
    );
  }

  Future<void> importJsonFromFile() async {
    final imported = await exportActions.importJson();
    if (imported == null || !mounted()) return;
    setState(() {
      builderSession.setRoutine(hydrateScheduledWeekdays(imported));
      routineNameController.text = imported.name;
    });
  }

  Future<void> markPlanCompletedFromEditor() async {
    final planId = editorController.loadedPlanId;
    if (planId == null) return;
    await coordinator.markPlanCompleted(
      context: context,
      planId: planId,
      routine: _routine,
      onRoutineUpdated: onPlanCompleted,
    );
  }

  void handleExportMenu(String value) {
    if (value == 'pdf') {
      showPdfExportSheet();
    } else if (value == 'excel') {
      exportActions.exportExcel(_routine);
    } else if (value == 'json') {
      exportActions.exportJson(_routine);
    } else if (value == 'hevy') {
      exportActions.exportCurrentDayToHevy(
        routine: _routine,
        selectedWeekIndex: selectedWeekIndex(),
        selectedDayIndex: selectedDayIndex(),
      );
    }
  }
}
