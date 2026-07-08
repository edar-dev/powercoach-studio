import 'package:flutter/material.dart';

import '../../data/workout_routine_model.dart';
import '../mobility_builder_controller.dart';
import '../workout_builder_mobility_handlers.dart';
import '../workout_builder_session_controller.dart';
import '../workout_builder_training_handlers.dart';
import '../workout_editor_controller.dart';
import 'workout_builder_editor_shell.dart';
import 'workout_mobility_tab.dart';
import 'workout_plan_details_tab.dart';
import 'workout_training_tab.dart';

/// Tab bodies and editor shell wiring for the workout builder screen.
class WorkoutBuilderScreenTabs {
  const WorkoutBuilderScreenTabs({
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
    required this.loading,
    required this.hideExportMenu,
    required this.showsMobilityTab,
    required this.showBottomNav,
    required this.planCompleted,
    required this.planArchived,
    required this.onInitialWeekChanged,
    required this.onCurrentWeekChanged,
    required this.onMetadataChanged,
    required this.onPickStartDate,
    required this.onPickEndDate,
    required this.onMarkCompleted,
    required this.onPopInvoked,
    required this.onBack,
    required this.onImportJson,
    required this.onExport,
    required this.onSave,
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
  final bool loading;
  final bool hideExportMenu;
  final bool showsMobilityTab;
  final bool showBottomNav;
  final bool planCompleted;
  final bool planArchived;
  final ValueChanged<String> onInitialWeekChanged;
  final ValueChanged<int> onCurrentWeekChanged;
  final VoidCallback onMetadataChanged;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickEndDate;
  final VoidCallback? onMarkCompleted;
  final Future<void> Function() onPopInvoked;
  final Future<void> Function() onBack;
  final Future<void> Function() onImportJson;
  final void Function(String value) onExport;
  final Future<bool> Function() onSave;

  WorkoutRoutine get _routine => builderSession.routine;

  Widget buildDetailsTab(ThemeData theme, ColorScheme cs) {
    return WorkoutPlanDetailsTab(
      routine: _routine,
      editorMode: editorMode,
      initialWeekController: initialWeekController,
      phaseController: phaseController,
      tagsController: tagsController,
      notesController: notesController,
      onPickStartDate: onPickStartDate,
      onPickEndDate: onPickEndDate,
      onInitialWeekChanged: onInitialWeekChanged,
      onCurrentWeekChanged: onCurrentWeekChanged,
      onMetadataChanged: onMetadataChanged,
      planCompleted: planCompleted,
      planArchived: planArchived,
      onMarkCompleted: onMarkCompleted,
    );
  }

  Widget buildMobilityTab(ThemeData theme, ColorScheme cs) {
    return WorkoutMobilityTab(
      theme: theme,
      colorScheme: cs,
      sections: mobilityController.sections,
      selectedSectionIndex: mobilityController.selectedSectionIndex,
      itemsForSelectedSection: mobilityController.itemsForSelectedSection,
      onAddItem: mobilityHandlers.addMobilityItem,
      onAddSection: mobilityHandlers.addMobilitySection,
      onEditSection: mobilityHandlers.editMobilitySection,
      onDeleteSection: mobilityHandlers.deleteMobilitySection,
      onSelectSection: mobilityController.selectSection,
      onReorderItems: mobilityHandlers.reorderMobility,
      onUpdateItem: (itemId, t, s, short) =>
          mobilityHandlers.updateMobilityItem(itemId, t, s, shortTitle: short),
      onDeleteItem: mobilityHandlers.removeMobilityItem,
    );
  }

  Widget buildTrainingTab(ThemeData theme, ColorScheme cs) {
    return WorkoutTrainingTab(
      theme: theme,
      cs: cs,
      embeddedInTab: true,
      weeks: _routine.weeks,
      selectedWeekIndex: builderSession.selectedWeekIndex,
      selectedDayIndex: builderSession.selectedDayIndex,
      onNewWeek: trainingHandlers.addWeek,
      onCloneWeek: trainingHandlers.cloneWeek,
      onDeleteWeek: trainingHandlers.confirmDeleteWeek,
      onRenameWeek: trainingHandlers.renameWeek,
      onAddDay: trainingHandlers.addDayToWeek,
      onRenameDay: trainingHandlers.renameDay,
      onDeleteDay: trainingHandlers.deleteDay,
      onAddExercise: trainingHandlers.addExerciseToDay,
      onDuplicateExercise: trainingHandlers.duplicateExercise,
      onRemoveExercise: trainingHandlers.removeExercise,
      onMoveExercise: trainingHandlers.moveExerciseInDay,
      onUpdateExercise: trainingHandlers.updateExercise,
      onAddSetToExercise: trainingHandlers.addSetToExercise,
      onUpdateExerciseSet: trainingHandlers.updateExerciseSet,
      onRemoveExerciseSet: trainingHandlers.removeExerciseSet,
      onAssignToSuperset: trainingHandlers.assignToSuperset,
      onRemoveFromSuperset: trainingHandlers.removeFromSuperset,
      onAddExerciseToSuperset: trainingHandlers.addExerciseToSuperset,
      onSelectWeek: (i) => builderSession.selectWeek(i, resetDay: true),
      onSelectDay: (i) => builderSession.selectDay(i),
      onUpdateScheduledWeekday: trainingHandlers.setDayScheduledWeekday,
    );
  }

  Widget buildEditorShell({
    required bool canPop,
    required bool saving,
    required bool showManualSaveButton,
    Widget? saveStatusIndicator,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return WorkoutBuilderEditorShell(
      canPop: canPop,
      saving: saving,
      showManualSaveButton: showManualSaveButton,
      saveStatusIndicator: saveStatusIndicator,
      editorMode: editorMode,
      loading: loading,
      hideExportMenu: hideExportMenu,
      showsMobilityTab: showsMobilityTab,
      sectionTabController: sectionTabController,
      routineNameController: routineNameController,
      trainingTab: buildTrainingTab(theme, cs),
      mobilityTab: buildMobilityTab(theme, cs),
      detailsTab: buildDetailsTab(theme, cs),
      showBottomNav: showBottomNav,
      onPopInvoked: onPopInvoked,
      onBack: onBack,
      onOpenTemplates: () {},
      onImportJson: onImportJson,
      onExport: onExport,
      onSave: onSave,
    );
  }
}
