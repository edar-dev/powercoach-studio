import 'package:flutter/material.dart';

import '../../../../core/constants/workout_plan_template_scope.dart';
import 'mobility_builder_controller.dart';
import 'workout_builder_mobility_handlers.dart';
import 'workout_builder_screen_routine_actions.dart';
import 'workout_builder_session_controller.dart';
import 'workout_builder_training_handlers.dart';
import 'workout_editor_controller.dart';
import 'widgets/workout_builder_screen_tabs.dart';

/// Builds [WorkoutBuilderScreenTabs] from screen dependencies.
class WorkoutBuilderScreenTabsConfig {
  const WorkoutBuilderScreenTabsConfig({
    required this.context,
    required this.builderSession,
    required this.mobilityController,
    required this.editorController,
    required this.trainingHandlers,
    required this.mobilityHandlers,
    required this.sectionTabController,
    required this.routineNameController,
    required this.initialWeekController,
    required this.phaseController,
    required this.tagsController,
    required this.notesController,
    required this.editorMode,
    required this.customerId,
    required this.loading,
    required this.showsMobilityTab,
    required this.planCompleted,
    required this.planArchived,
    required this.readOnly,
    required this.onLogSession,
    required this.onAssignDraftToCustomer,
    required this.actions,
    required this.onInitialWeekNumberChanged,
    required this.onMetadataChanged,
    required this.onMarkCompleted,
    this.loadedPlanId,
    this.showOnboardingCard = false,
    this.onDismissOnboarding,
    this.onIncludesMobilityTabChanged,
    this.onSyncMobilityTabVisibility,
  });

  final BuildContext context;
  final WorkoutBuilderSessionController builderSession;
  final MobilityBuilderController mobilityController;
  final WorkoutEditorController editorController;
  final WorkoutBuilderTrainingHandlers trainingHandlers;
  final WorkoutBuilderMobilityHandlers mobilityHandlers;
  final TabController sectionTabController;
  final TextEditingController routineNameController;
  final TextEditingController initialWeekController;
  final TextEditingController phaseController;
  final TextEditingController tagsController;
  final TextEditingController notesController;
  final bool editorMode;
  final String? customerId;
  final bool loading;
  final bool showsMobilityTab;
  final bool planCompleted;
  final bool planArchived;
  final bool readOnly;
  final VoidCallback? onLogSession;
  final VoidCallback? onAssignDraftToCustomer;
  final WorkoutBuilderScreenRoutineActions actions;
  final ValueChanged<int> onInitialWeekNumberChanged;
  final VoidCallback onMetadataChanged;
  final VoidCallback? onMarkCompleted;
  final String? loadedPlanId;
  final bool showOnboardingCard;
  final VoidCallback? onDismissOnboarding;
  final ValueChanged<bool>? onIncludesMobilityTabChanged;
  final VoidCallback? onSyncMobilityTabVisibility;

  WorkoutBuilderScreenTabs build() {
    return WorkoutBuilderScreenTabs(
      context: context,
      builderSession: builderSession,
      mobilityController: mobilityController,
      editorController: editorController,
      trainingHandlers: trainingHandlers,
      mobilityHandlers: mobilityHandlers,
      sectionTabController: sectionTabController,
      routineNameController: routineNameController,
      initialWeekController: initialWeekController,
      phaseController: phaseController,
      tagsController: tagsController,
      notesController: notesController,
      editorMode: editorMode,
      loading: loading,
      hideExportMenu:
          editorMode && customerId == kWorkoutPlanTemplateScopeId,
      showsMobilityTab: showsMobilityTab,
      showBottomNav: !editorMode,
      planCompleted: planCompleted,
      planArchived: planArchived,
      readOnly: readOnly,
      onLogSession: onLogSession,
      onAssignDraftToCustomer: onAssignDraftToCustomer,
      onInitialWeekChanged: (value) {
        final v = int.tryParse(value);
        if (v != null && v >= 1) {
          onInitialWeekNumberChanged(v);
        }
      },
      onCurrentWeekChanged: (value) {
        builderSession.setRoutine(
          builderSession.routine.copyWith(currentWeek: value),
        );
      },
      onMetadataChanged: onMetadataChanged,
      onPickStartDate: actions.pickRoutineStartDate,
      onPickEndDate: actions.pickRoutineEndDate,
      onMarkCompleted: onMarkCompleted,
      onPopInvoked: actions.handleExitAttempt,
      onBack: actions.handleExitAttempt,
      onImportJson: actions.importJsonFromFile,
      onExport: actions.handleExportMenu,
      onSave: () => actions.saveRoutine(),
      loadedPlanId: loadedPlanId ?? editorController.loadedPlanId,
      showOnboardingCard: showOnboardingCard,
      onDismissOnboarding: onDismissOnboarding,
      onIncludesMobilityTabChanged: onIncludesMobilityTabChanged,
      onSyncMobilityTabVisibility: onSyncMobilityTabVisibility,
    );
  }
}
