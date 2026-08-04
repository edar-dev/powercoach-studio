import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/settings/workout_builder_onboarding_store.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/auth/supabase_bootstrap.dart';
import '../../../customers/data/customer_repository.dart';
import '../../../customers/data/models/customer.dart' show Customer;
import '../../../dashboard/domain/plan_calendar_event.dart';
import '../../data/workout_draft_store.dart';
import '../../data/workout_plan_repository.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/plan_session_status_service.dart';
import '../../domain/session_execution_service.dart';
import '../mobility_builder_controller.dart';
import '../workout_builder_export_actions.dart';
import '../workout_builder_mobility_handlers.dart';
import '../workout_builder_routine_coordinator.dart';
import '../workout_builder_screen_load_handler.dart';
import '../workout_builder_screen_routine_actions.dart';
import '../workout_builder_screen_tabs_config.dart';
import '../workout_builder_session_controller.dart';
import '../workout_builder_training_handlers.dart';
import '../workout_builder_variant.dart';
import '../workout_editor_controller.dart';
import '../workout_editor_snapshot.dart';
import '../widgets/session_log_sheet.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_editor_save_status_indicator.dart';

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
  final _statusService = PlanSessionStatusService();
  final _executionService = SessionExecutionService();
  final WorkoutDraftStore _draftStore = const SharedPrefsWorkoutDraftStore();
  late final WorkoutBuilderSessionController _builderSession;
  late final MobilityBuilderController _mobilityController;
  late final WorkoutEditorController _editorController;
  late final WorkoutBuilderRoutineCoordinator _routineCoordinator;
  late final WorkoutBuilderScreenLoadHandler _loadHandler;
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
  bool _showOnboardingCard = false;
  late final TabController _sectionTabController;

  int get _selectedWeekIndex => _builderSession.selectedWeekIndex;
  int get _selectedDayIndex => _builderSession.selectedDayIndex;

  bool get _showsMobilityTab =>
      widget.variant.showsMobilityTab &&
      _builderSession.routine.includesMobilityTab;

  bool get _readOnly => _planArchived || _planCompleted;

  WorkoutBuilderTrainingHandlers get _trainingHandlers =>
      WorkoutBuilderTrainingHandlers(
        context: context,
        session: _builderSession,
        customerId: widget.customerId,
        readOnly: _readOnly,
      );

  WorkoutBuilderMobilityHandlers get _mobilityHandlers =>
      WorkoutBuilderMobilityHandlers(
        context: context,
        mobilityController: _mobilityController,
        readOnly: _readOnly,
      );

  WorkoutBuilderExportActions get _exportActions => WorkoutBuilderExportActions(
        context: context,
        routineNameController: _routineNameController,
        customerRepo: _customerRepo,
        editorCustomer: _editorCustomer,
        editorMode: widget.editorMode,
      );

  WorkoutBuilderScreenRoutineActions get _routineActions =>
      WorkoutBuilderScreenRoutineActions(
        context: context,
        mounted: () => mounted,
        setState: setState,
        coordinator: _routineCoordinator,
        builderSession: _builderSession,
        editorController: _editorController,
        exportActions: _exportActions,
        editorMode: widget.editorMode,
        customerId: widget.customerId,
        initialWeekNumber: () => _initialWeekNumber,
        editorCustomer: () => _editorCustomer,
        selectedWeekIndex: () => _selectedWeekIndex,
        selectedDayIndex: () => _selectedDayIndex,
        isDirty: () => _isDirty,
        isStandaloneDirty: () => _isStandaloneDirty,
        onStandaloneSnapshotCaptured: _captureStandaloneSnapshot,
        onPlanCompleted: (updated) {
          setState(() {
            _planCompleted = true;
            _builderSession.setRoutine(updated);
          });
        },
        routineNameController: _routineNameController,
        onInitialWeekNumberSaved: (value) => _initialWeekNumber = value,
        saving: () => _saving,
        onSavingChanged: (value) => setState(() => _saving = value),
      );

  WorkoutBuilderScreenTabsConfig get _screenTabsConfig =>
      WorkoutBuilderScreenTabsConfig(
        context: context,
        builderSession: _builderSession,
        mobilityController: _mobilityController,
        editorController: _editorController,
        trainingHandlers: _trainingHandlers,
        mobilityHandlers: _mobilityHandlers,
        sectionTabController: _sectionTabController,
        routineNameController: _routineNameController,
        initialWeekController: _initialWeekController,
        phaseController: _phaseController,
        tagsController: _tagsController,
        notesController: _notesController,
        editorMode: widget.editorMode,
        customerId: widget.customerId,
        loading: _loading,
        showsMobilityTab: _showsMobilityTab,
        planCompleted: _planCompleted,
        planArchived: _planArchived,
        readOnly: _readOnly,
        onLogSession: _canLogSession ? _logCurrentSession : null,
        onAssignDraftToCustomer: !widget.editorMode ? _assignDraftToCustomer : null,
        actions: _routineActions,
        onInitialWeekNumberChanged: (value) =>
            setState(() => _initialWeekNumber = value),
        onMetadataChanged: _onMetadataEdited,
        onMarkCompleted:
            _editorController.loadedPlanId != null &&
                !_planCompleted &&
                !_planArchived
            ? _routineActions.markPlanCompletedFromEditor
            : null,
        loadedPlanId: _editorController.loadedPlanId,
        showOnboardingCard: _showOnboardingCard,
        onDismissOnboarding: _dismissOnboarding,
        onIncludesMobilityTabChanged: _readOnly ? null : _onIncludesMobilityTabChanged,
        onSyncMobilityTabVisibility: _syncTabControllerLength,
        editorCustomerName: _editorCustomer?.name,
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

  bool get _canLogSession =>
      widget.editorMode &&
      widget.customerId != null &&
      _editorController.loadedPlanId != null &&
      !_readOnly &&
      !_loading;

  Future<void> _assignDraftToCustomer() {
    return _routineCoordinator.assignDraftToCustomer(
      context: context,
      session: _routineCoordinator.editorSession(
        initialWeekNumber: _initialWeekNumber,
      ),
      selectedWeekIndex: _selectedWeekIndex,
      selectedDayIndex: _selectedDayIndex,
    );
  }

  Future<void> _logCurrentSession() async {
    final planId = _editorController.loadedPlanId;
    final customerId = widget.customerId;
    if (planId == null || customerId == null || _readOnly) return;

    final weekIndex = _selectedWeekIndex;
    final dayIndex = _selectedDayIndex;
    final routine = _builderSession.routine;
    if (weekIndex < 0 ||
        weekIndex >= routine.weeks.length ||
        dayIndex < 0 ||
        dayIndex >= routine.weeks[weekIndex].days.length) {
      return;
    }

    final day = routine.weeks[weekIndex].days[dayIndex];
    final sessionKey = WorkoutRoutine.sessionKey(weekIndex, dayIndex);
    final existing = await _executionService.get(
      planId: planId,
      sessionKey: sessionKey,
    );
    if (!mounted) return;

    final logResult = await showSessionLogSheet(
      context: context,
      plannedExercises: day.exercises,
      initialExercises: existing?.exercises,
      initialNotes: existing?.notes ?? '',
    );
    if (logResult == null || !mounted) return;

    try {
      await _statusService.setSessionStatus(
        planId: planId,
        weekIndex: weekIndex,
        dayIndex: dayIndex,
        status: PlanSessionStatus.completed,
        exercises: logResult.exercises,
        notes: logResult.notes,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).workoutBuilderLogSessionSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).calendarUpdateError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
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
    _loadHandler = WorkoutBuilderScreenLoadHandler(
      coordinator: _routineCoordinator,
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_loadOnboardingState());
        unawaited(_loadRoutine());
      }
    });
  }

  Future<void> _loadOnboardingState() async {
    final user = SupabaseBootstrap.currentUser;
    if (user == null) return;
    final dismissed =
        await WorkoutBuilderOnboardingStore.instance.isDismissed(user.id);
    if (!mounted) return;
    setState(() => _showOnboardingCard = !dismissed);
  }

  void _dismissOnboarding() {
    final user = SupabaseBootstrap.currentUser;
    if (user != null) {
      unawaited(WorkoutBuilderOnboardingStore.instance.markDismissed(user.id));
    }
    setState(() => _showOnboardingCard = false);
  }

  void _syncTabControllerLength() {
    final length = _showsMobilityTab ? 3 : 2;
    if (_sectionTabController.length == length) return;
    final previousIndex = _sectionTabController.index;
    _sectionTabController.dispose();
    _sectionTabController = TabController(
      length: length,
      vsync: this,
      initialIndex: previousIndex.clamp(0, length - 1),
    );
  }

  void _onIncludesMobilityTabChanged(bool value) {
    _builderSession.setRoutine(
      _builderSession.routine.copyWith(includesMobilityTab: value),
    );
    _syncTabControllerLength();
    if (!value && _sectionTabController.index == 1) {
      _sectionTabController.index = 0;
    }
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
    final router = GoRouter.maybeOf(context);
    if (router == null) {
      return;
    }
    final query = router.state.uri.queryParameters;
    _pendingSelectedWeekIndex = int.tryParse(query['week'] ?? '');
    _pendingSelectedDayIndex = int.tryParse(query['day'] ?? '');
    final mobilityParam = query['mobility'];
    if (mobilityParam == '0' || mobilityParam == 'false') {
      _builderSession.setRoutine(
        _builderSession.routine.copyWith(includesMobilityTab: false),
      );
      _syncTabControllerLength();
    }
  }

  void _captureStandaloneSnapshot() {
    if (!widget.editorMode) {
      _standaloneSavedSnapshot = _routineCoordinator.standaloneSnapshot(
        initialWeekNumber: _initialWeekNumber,
      );
    }
  }

  void _scheduleEditorContentChanged() {
    if (!widget.editorMode || _loading || _readOnly) {
      return;
    }
    _editorController.scheduleContentChanged(
      session: _routineCoordinator.editorSession(
        initialWeekNumber: _initialWeekNumber,
      ),
      editorMode: widget.editorMode,
      loading: _loading,
      onAutosave: () => _routineActions.saveRoutine(silent: true),
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
    final loaded = await _loadHandler.loadStandalone();
    if (!mounted) return;
    setState(() {
      _builderSession.setRoutine(loaded);
      _routineNameController.text = loaded.name;
      _builderSession.selectWeek(0, resetDay: true);
      _loading = false;
    });
    _captureStandaloneSnapshot();
  }

  Future<void> _loadForEditorMode() async {
    final application = await _loadHandler.loadEditor(
      customerId: widget.customerId!,
      planId: widget.planId,
      pendingWeekIndex: _pendingSelectedWeekIndex,
      pendingDayIndex: _pendingSelectedDayIndex,
      fallbackInitialWeekNumber: _initialWeekNumber,
    );
    if (!mounted) return;
    if (application.clearDeepLink) {
      _pendingSelectedWeekIndex = null;
      _pendingSelectedDayIndex = null;
    }
    setState(() {
      if (application.routine != null) {
        _builderSession.setRoutine(application.routine!);
        _routineNameController.text = application.routine!.name;
        _phaseController.text = application.phase;
        _tagsController.text = application.tags;
        _notesController.text = application.notes;
        _initialWeekNumber = application.initialWeekNumber;
        _initialWeekController.text = application.initialWeekNumber.toString();
        _builderSession.selectWeekDay(
          application.weekIndex,
          application.dayIndex,
        );
        _planCompleted = application.planCompleted;
        _planArchived = application.planArchived;
      } else {
        _builderSession.selectWeek(0, resetDay: true);
      }
      _editorCustomer = application.customer;
      _loading = false;
    });
    _editorController.markLoaded(
      session: _routineCoordinator.editorSession(
        initialWeekNumber: _initialWeekNumber,
      ),
      planId: application.loadedPlanId,
      loadedInitialWeekNumber: application.initialWeekNumber,
    );
    if (_readOnly) {
      _editorController.suspendTracking();
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final tabs = _screenTabsConfig.build();

    if (!widget.editorMode) {
      return tabs.buildEditorShell(
        canPop: !_isStandaloneDirty,
        saving: _saving,
        showManualSaveButton: true,
        saveStatusIndicator: null,
        showSandboxBanner: true,
      );
    }

    return ListenableBuilder(
      listenable: _editorController,
      builder: (context, _) => tabs.buildEditorShell(
        canPop: !_editorController.isDirty,
        saving: _editorController.saving,
        showManualSaveButton: !_readOnly &&
            _editorController.shouldShowManualSaveButton(
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
                onRetry: _routineActions.saveRoutine,
              )
            : null,
        showFirstSaveBanner:
            !_loading && _editorController.loadedPlanId == null,
      ),
    );
  }
}
