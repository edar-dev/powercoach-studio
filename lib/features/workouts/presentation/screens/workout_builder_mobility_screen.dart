import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/workout_plan_template_scope.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../customers/data/customer_repository.dart';
import '../../../customers/data/models/customer.dart' show Customer;
import '../../data/workout_draft_store.dart';
import '../../data/workout_plan_repository.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/day_scheduled_weekday.dart';
import '../mobility_builder_controller.dart';
import '../workout_builder_export_actions.dart';
import '../workout_builder_load_helpers.dart';
import '../workout_builder_mobility_handlers.dart';
import '../workout_builder_routine_coordinator.dart';
import '../workout_builder_session_controller.dart';
import '../workout_builder_training_handlers.dart';
import '../workout_builder_variant.dart';
import '../workout_editor_controller.dart';
import '../workout_editor_snapshot.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_builder_editor_shell.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_editor_save_status_indicator.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_export_sheet.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_mobility_tab.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_plan_details_tab.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_training_tab.dart';

/// Workout Builder – Enhanced Mobility / Multi-set / Super Set / Intuitive Super Set.
/// When [editorMode] is true and [customerId] is set, loads/saves via API (workout plan for customer).
class WorkoutBuilderMobilityScreen extends StatefulWidget {
  const WorkoutBuilderMobilityScreen({
    super.key,
    this.variant = WorkoutBuilderVariant.mobility,
    this.customerId,
    this.planId,
    this.editorMode = false,
  });

  final WorkoutBuilderVariant variant;
  final String? customerId;
  final String? planId;
  final bool editorMode;

  @override
  State<WorkoutBuilderMobilityScreen> createState() =>
      _WorkoutBuilderMobilityScreenState();
}

class _WorkoutBuilderMobilityScreenState
    extends State<WorkoutBuilderMobilityScreen>
    with SingleTickerProviderStateMixin {
  final _routineNameController = TextEditingController();
  final _initialWeekController = TextEditingController(text: '1');
  final _phaseController = TextEditingController();
  final _tagsController = TextEditingController();
  final _notesController = TextEditingController();
  final _customerRepo = CustomerRepository();
  final _planRepo = WorkoutPlanRepository();
  final WorkoutDraftStore _draftStore = const SharedPrefsWorkoutDraftStore();
  late final WorkoutBuilderSessionController _builderSession;
  late final MobilityBuilderController _mobilityController;
  late final WorkoutEditorController _editorController;
  late final WorkoutBuilderRoutineCoordinator _routineCoordinator;
  Customer? _editorCustomer;
  bool _loading = true;
  bool _saving = false;
  bool _planCompleted = false;
  bool _planArchived = false;
  int _initialWeekNumber = 1;
  String? _standaloneSavedSnapshot;
  int? _pendingSelectedWeekIndex;
  int? _pendingSelectedDayIndex;
  bool _didReadDeepLinkSelection = false;
  late final TabController _sectionTabController;

  WorkoutRoutine get _routine => _builderSession.routine;
  set _routine(WorkoutRoutine value) => _builderSession.setRoutine(value);

  int get _selectedWeekIndex => _builderSession.selectedWeekIndex;
  int get _selectedDayIndex => _builderSession.selectedDayIndex;

  bool get _showsMobilityTab => widget.variant.showsMobilityTab;

  WorkoutBuilderTrainingHandlers get _trainingHandlers =>
      WorkoutBuilderTrainingHandlers(
        context: context,
        session: _builderSession,
        customerId: widget.customerId,
      );

  WorkoutBuilderMobilityHandlers get _mobilityHandlers =>
      WorkoutBuilderMobilityHandlers(
        context: context,
        mobilityController: _mobilityController,
      );

  WorkoutBuilderExportActions get _exportActions => WorkoutBuilderExportActions(
        context: context,
        routineNameController: _routineNameController,
        customerRepo: _customerRepo,
        editorCustomer: _editorCustomer,
        editorMode: widget.editorMode,
      );

  bool get _isDirty => widget.editorMode ? _editorController.isDirty : false;

  bool get _isStandaloneDirty {
    if (widget.editorMode || _standaloneSavedSnapshot == null) return false;
    return isWorkoutEditorDirty(
      savedSnapshot: _standaloneSavedSnapshot,
      currentSnapshot: _routineCoordinator.standaloneSnapshot(
        initialWeekNumber: _initialWeekNumber,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _builderSession = WorkoutBuilderSessionController();
    _builderSession.addListener(_onBuilderControllersChanged);
    _mobilityController = MobilityBuilderController(_builderSession);
    _mobilityController.addListener(_onBuilderControllersChanged);
    _editorController = WorkoutEditorController(planRepo: _planRepo);
    _routineCoordinator = WorkoutBuilderRoutineCoordinator(
      builderSession: _builderSession,
      editorController: _editorController,
      planRepo: _planRepo,
      customerRepo: _customerRepo,
      draftStore: _draftStore,
      routineNameController: _routineNameController,
      initialWeekController: _initialWeekController,
      phaseController: _phaseController,
      tagsController: _tagsController,
      notesController: _notesController,
    );
    _sectionTabController = TabController(
      length: _showsMobilityTab ? 3 : 2,
      vsync: this,
    );
    _routineNameController.addListener(_onMetadataEdited);
    _initialWeekController.addListener(_onMetadataEdited);
    _phaseController.addListener(_onMetadataEdited);
    _tagsController.addListener(_onMetadataEdited);
    _notesController.addListener(_onMetadataEdited);
    _loadRoutine();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didReadDeepLinkSelection) {
      return;
    }
    _didReadDeepLinkSelection = true;
    _readDeepLinkSelection();
  }

  void _readDeepLinkSelection() {
    final query = GoRouterState.of(context).uri.queryParameters;
    _pendingSelectedWeekIndex = int.tryParse(query['week'] ?? '');
    _pendingSelectedDayIndex = int.tryParse(query['day'] ?? '');
  }

  void _captureStandaloneSnapshot() {
    if (!widget.editorMode) {
      _standaloneSavedSnapshot = _routineCoordinator.standaloneSnapshot(
        initialWeekNumber: _initialWeekNumber,
      );
    }
  }

  void _scheduleEditorContentChanged() {
    if (!widget.editorMode || _loading) {
      return;
    }
    _editorController.scheduleContentChanged(
      session: _routineCoordinator.editorSession(
        initialWeekNumber: _initialWeekNumber,
      ),
      editorMode: widget.editorMode,
      loading: _loading,
      onAutosave: () => _saveRoutine(silent: true),
    );
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) {
      return;
    }
    super.setState(fn);
    _scheduleEditorContentChanged();
  }

  void _onMetadataEdited() {
    if (_loading || !mounted) {
      return;
    }
    if (!widget.editorMode) {
      setState(() {});
      return;
    }
    if (_editorController.trackingSuspended) return;
    setState(() {});
  }

  Future<void> _loadRoutine() async {
    if (widget.editorMode && widget.customerId != null) {
      await _loadForEditorMode();
      return;
    }
    final loaded = await _routineCoordinator.loadStandaloneDraft();
    if (!mounted) return;
    setState(() {
      _routine = loaded;
      _routineNameController.text = loaded.name;
      _builderSession.selectWeek(0, resetDay: true);
      _loading = false;
    });
    _captureStandaloneSnapshot();
  }

  Future<void> _loadForEditorMode() async {
    final customerId = widget.customerId!;
    try {
      final result = await _routineCoordinator.loadEditorPlan(
        customerId: customerId,
        planId: widget.planId,
        pendingWeekIndex: _pendingSelectedWeekIndex,
        pendingDayIndex: _pendingSelectedDayIndex,
      );
      if (!mounted) return;
      if (result.routine != null) {
        if (_pendingSelectedWeekIndex != null &&
            _pendingSelectedDayIndex != null &&
            resolveWorkoutBuilderDeepLinkSelection(
                  result.routine!,
                  pendingWeekIndex: _pendingSelectedWeekIndex,
                  pendingDayIndex: _pendingSelectedDayIndex,
                ) !=
                null) {
          _pendingSelectedWeekIndex = null;
          _pendingSelectedDayIndex = null;
        }
        setState(() {
          _routine = result.routine!;
          _routineNameController.text = result.routine!.name;
          _phaseController.text = result.phase;
          _tagsController.text = result.tags;
          _notesController.text = result.notes;
          _initialWeekNumber = result.loadedInitialWeek;
          _initialWeekController.text = result.loadedInitialWeek.toString();
          _builderSession.selectWeekDay(result.weekIndex, result.dayIndex);
          _planCompleted = result.planCompleted;
          _planArchived = result.planArchived;
        });
      } else {
        setState(() {
          _builderSession.selectWeek(0, resetDay: true);
        });
      }
      setState(() {
        _editorCustomer = result.customer;
        _loading = false;
      });
      _editorController.markLoaded(
        session: _routineCoordinator.editorSession(
          initialWeekNumber: _initialWeekNumber,
        ),
        planId: result.loadedPlanId,
        loadedInitialWeekNumber: result.loadedInitialWeek,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _builderSession.selectWeek(0, resetDay: true);
        _loading = false;
      });
      _editorController.markLoaded(
        session: _routineCoordinator.editorSession(
          initialWeekNumber: _initialWeekNumber,
        ),
      );
    }
  }

  Future<void> _pickRoutineStartDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = _routine.startDate ?? today;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 10, 12, 31),
    );
    if (!mounted || picked == null) return;
    setState(() {
      _routine = _routine.copyWith(
        startDate: DateTime(picked.year, picked.month, picked.day),
      );
    });
  }

  Future<void> _pickRoutineEndDate() async {
    final now = DateTime.now();
    final fallback = DateTime(now.year, now.month, now.day);
    final initial = _routine.endDate ?? _routine.startDate ?? fallback;
    final firstDate = _routine.startDate ?? DateTime(2000);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(firstDate.year, firstDate.month, firstDate.day),
      lastDate: DateTime(now.year + 10, 12, 31),
    );
    if (!mounted || picked == null) return;
    setState(() {
      _routine = _routine.copyWith(
        endDate: DateTime(picked.year, picked.month, picked.day),
      );
    });
  }

  Future<bool> _saveRoutine({bool silent = false}) async {
    if (!widget.editorMode) {
      if (_saving) return false;
      setState(() => _saving = true);
    }
    final outcome = await _routineCoordinator.saveRoutine(
      context: context,
      editorMode: widget.editorMode,
      customerId: widget.customerId,
      initialWeekNumber: _initialWeekNumber,
      editorCustomer: _editorCustomer,
      selectedWeekIndex: _selectedWeekIndex,
      selectedDayIndex: _selectedDayIndex,
      silent: silent,
    );
    if (!mounted) return outcome.success;
    if (outcome.savedRoutine != null) {
      setState(() {
        _routine = outcome.savedRoutine!;
        if (outcome.savedInitialWeekNumber != null) {
          _initialWeekNumber = outcome.savedInitialWeekNumber!;
        }
      });
    }
    if (!widget.editorMode) {
      _captureStandaloneSnapshot();
      setState(() => _saving = false);
    }
    return outcome.success;
  }

  void _showPdfExportSheet() {
    showWorkoutExportSheet(
      context: context,
      routine: _routine,
      onExportPdf: (options) {
        _exportActions.exportPdf(
          _routine,
          layout: options.layout,
          includeMobility: options.includeMobility,
        );
      },
    );
  }

  Future<void> _handleExitAttempt() async {
    await _routineCoordinator.handleExitAttempt(
      context: context,
      editorMode: widget.editorMode,
      customerId: widget.customerId,
      isDirty: widget.editorMode ? _isDirty : _isStandaloneDirty,
      onSave: ({bool silent = false}) {
        return _saveRoutine(silent: silent);
      },
    );
  }

  Future<void> _importJsonFromFile() async {
    final imported = await _exportActions.importJson();
    if (imported == null || !mounted) return;
    setState(() {
      _routine = hydrateScheduledWeekdays(imported);
      _routineNameController.text = imported.name;
    });
  }

  void _onBuilderControllersChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _builderSession.removeListener(_onBuilderControllersChanged);
    _mobilityController.removeListener(_onBuilderControllersChanged);
    _mobilityController.dispose();
    _builderSession.dispose();
    _editorController.dispose();
    _routineNameController.removeListener(_onMetadataEdited);
    _initialWeekController.removeListener(_onMetadataEdited);
    _phaseController.removeListener(_onMetadataEdited);
    _tagsController.removeListener(_onMetadataEdited);
    _notesController.removeListener(_onMetadataEdited);
    _sectionTabController.dispose();
    _routineNameController.dispose();
    _initialWeekController.dispose();
    _phaseController.dispose();
    _tagsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Widget _buildDetailsTab(ThemeData theme, ColorScheme cs) {
    return WorkoutPlanDetailsTab(
      routine: _routine,
      editorMode: widget.editorMode,
      initialWeekController: _initialWeekController,
      phaseController: _phaseController,
      tagsController: _tagsController,
      notesController: _notesController,
      onPickStartDate: _pickRoutineStartDate,
      onPickEndDate: _pickRoutineEndDate,
      onInitialWeekChanged: (value) {
        final v = int.tryParse(value);
        if (v != null && v >= 1) {
          setState(() => _initialWeekNumber = v);
        }
      },
      onCurrentWeekChanged: (value) {
        setState(() {
          _routine = _routine.copyWith(currentWeek: value);
        });
      },
      onMetadataChanged: _onMetadataEdited,
      planCompleted: _planCompleted,
      planArchived: _planArchived,
      onMarkCompleted:
          _editorController.loadedPlanId != null &&
              !_planCompleted &&
              !_planArchived
          ? _markPlanCompletedFromEditor
          : null,
    );
  }

  Future<void> _markPlanCompletedFromEditor() async {
    final planId = _editorController.loadedPlanId;
    if (planId == null) return;
    await _routineCoordinator.markPlanCompleted(
      context: context,
      planId: planId,
      routine: _routine,
      onRoutineUpdated: (updated) {
        if (!mounted) return;
        setState(() {
          _planCompleted = true;
          _routine = updated;
        });
      },
    );
  }

  Widget _buildMobilityTab(ThemeData theme, ColorScheme cs) {
    return WorkoutMobilityTab(
      theme: theme,
      colorScheme: cs,
      sections: _mobilityController.sections,
      selectedSectionIndex: _mobilityController.selectedSectionIndex,
      itemsForSelectedSection: _mobilityController.itemsForSelectedSection,
      onAddItem: _mobilityHandlers.addMobilityItem,
      onAddSection: _mobilityHandlers.addMobilitySection,
      onEditSection: _mobilityHandlers.editMobilitySection,
      onDeleteSection: _mobilityHandlers.deleteMobilitySection,
      onSelectSection: _mobilityController.selectSection,
      onReorderItems: _mobilityHandlers.reorderMobility,
      onUpdateItem: (itemId, t, s, short) =>
          _mobilityHandlers.updateMobilityItem(itemId, t, s, shortTitle: short),
      onDeleteItem: _mobilityHandlers.removeMobilityItem,
    );
  }

  Widget _buildTrainingTab(ThemeData theme, ColorScheme cs) {
    return WorkoutTrainingTab(
      theme: theme,
      cs: cs,
      embeddedInTab: true,
      weeks: _routine.weeks,
      selectedWeekIndex: _selectedWeekIndex,
      selectedDayIndex: _selectedDayIndex,
      onNewWeek: _trainingHandlers.addWeek,
      onCloneWeek: _trainingHandlers.cloneWeek,
      onDeleteWeek: _trainingHandlers.confirmDeleteWeek,
      onRenameWeek: _trainingHandlers.renameWeek,
      onAddDay: _trainingHandlers.addDayToWeek,
      onRenameDay: _trainingHandlers.renameDay,
      onDeleteDay: _trainingHandlers.deleteDay,
      onAddExercise: _trainingHandlers.addExerciseToDay,
      onDuplicateExercise: _trainingHandlers.duplicateExercise,
      onRemoveExercise: _trainingHandlers.removeExercise,
      onMoveExercise: _trainingHandlers.moveExerciseInDay,
      onUpdateExercise: _trainingHandlers.updateExercise,
      onAddSetToExercise: _trainingHandlers.addSetToExercise,
      onUpdateExerciseSet: _trainingHandlers.updateExerciseSet,
      onRemoveExerciseSet: _trainingHandlers.removeExerciseSet,
      onAssignToSuperset: _trainingHandlers.assignToSuperset,
      onRemoveFromSuperset: _trainingHandlers.removeFromSuperset,
      onAddExerciseToSuperset: _trainingHandlers.addExerciseToSuperset,
      onSelectWeek: (i) => _builderSession.selectWeek(i, resetDay: true),
      onSelectDay: (i) => _builderSession.selectDay(i),
      onUpdateScheduledWeekday: _trainingHandlers.setDayScheduledWeekday,
    );
  }

  WorkoutBuilderEditorShell _editorShell({
    required bool canPop,
    required bool saving,
    required bool showManualSaveButton,
    Widget? saveStatusIndicator,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hideExportMenu =
        widget.editorMode && widget.customerId == kWorkoutPlanTemplateScopeId;

    return WorkoutBuilderEditorShell(
      canPop: canPop,
      saving: saving,
      showManualSaveButton: showManualSaveButton,
      saveStatusIndicator: saveStatusIndicator,
      editorMode: widget.editorMode,
      loading: _loading,
      hideExportMenu: hideExportMenu,
      showsMobilityTab: _showsMobilityTab,
      sectionTabController: _sectionTabController,
      routineNameController: _routineNameController,
      trainingTab: _buildTrainingTab(theme, cs),
      mobilityTab: _buildMobilityTab(theme, cs),
      detailsTab: _buildDetailsTab(theme, cs),
      showBottomNav: !widget.editorMode,
      onPopInvoked: _handleExitAttempt,
      onBack: _handleExitAttempt,
      onOpenTemplates: () {},
      onImportJson: _importJsonFromFile,
      onExport: (value) {
        if (value == 'pdf') _showPdfExportSheet();
        if (value == 'excel') _exportActions.exportExcel(_routine);
        if (value == 'json') _exportActions.exportJson(_routine);
        if (value == 'hevy') {
          _exportActions.exportCurrentDayToHevy(
            routine: _routine,
            selectedWeekIndex: _selectedWeekIndex,
            selectedDayIndex: _selectedDayIndex,
          );
        }
      },
      onSave: () => _saveRoutine(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    if (!widget.editorMode) {
      return _editorShell(
        canPop: !_isStandaloneDirty,
        saving: _saving,
        showManualSaveButton: true,
        saveStatusIndicator: null,
      );
    }

    return ListenableBuilder(
      listenable: _editorController,
      builder: (context, _) => _editorShell(
        canPop: !_editorController.isDirty,
        saving: _editorController.saving,
        showManualSaveButton: _editorController.shouldShowManualSaveButton(
          loading: _loading,
          editorMode: widget.editorMode,
        ),
        saveStatusIndicator: !_loading
            ? WorkoutEditorSaveStatusIndicator(
                saveState: _editorController.saveState,
                l10n: l10n,
                colorScheme: cs,
                textTheme: theme.textTheme,
                editorMode: widget.editorMode,
                hasLoadedPlan: _editorController.loadedPlanId != null,
                onRetry: _saveRoutine,
              )
            : null,
      ),
    );
  }
}
