import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/workout_plan_template_scope.dart';
import '../../../../core/routing/app_navigation.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../customers/data/customer_repository.dart';
import '../../../customers/data/models/customer.dart' show Customer;
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import '../../data/workout_draft_store.dart';
import '../../data/workout_plan_repository.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/day_scheduled_weekday.dart';
import '../../domain/exercise_prescription_scope.dart';
import '../../domain/workout_exercise_mutations.dart';
import '../../domain/workout_mobility_mutations.dart';
import '../../domain/workout_plan_list_helpers.dart';
import '../../domain/workout_routine_mutations.dart';
import '../workout_builder_editor_exit.dart';
import '../workout_builder_export_actions.dart';
import '../workout_builder_session_controller.dart';
import '../workout_builder_variant.dart';
import '../workout_editor_controller.dart';
import '../workout_editor_snapshot.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/exercise_add_sheet.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/mobility_add_sheet.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/mobility_section_editor_sheet.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_builder_editor_shell.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_editor_save_status_indicator.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_export_sheet.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_training_helpers.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_mobility_tab.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_plan_details_tab.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_superset_actions.dart';
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
  late final WorkoutEditorController _editorController;
  Customer? _editorCustomer;
  bool _loading = true;
  bool _saving = false;
  bool _planCompleted = false;
  bool _planArchived = false;
  int _initialWeekNumber = 1;
  int _selectedMobilitySectionIndex = 0;
  String? _standaloneSavedSnapshot;
  int? _pendingSelectedWeekIndex;
  int? _pendingSelectedDayIndex;
  bool _didReadDeepLinkSelection = false;
  late final TabController _sectionTabController;

  WorkoutRoutine get _routine => _builderSession.routine;
  set _routine(WorkoutRoutine value) => _builderSession.setRoutine(value);

  int get _selectedWeekIndex => _builderSession.selectedWeekIndex;
  set _selectedWeekIndex(int value) => _builderSession.selectWeek(value);

  int get _selectedDayIndex => _builderSession.selectedDayIndex;
  set _selectedDayIndex(int value) => _builderSession.selectDay(value);

  bool get _showsMobilityTab => widget.variant.showsMobilityTab;

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
      currentSnapshot: _standaloneSnapshot(),
    );
  }

  @override
  void initState() {
    super.initState();
    _builderSession = WorkoutBuilderSessionController();
    _editorController = WorkoutEditorController(planRepo: _planRepo);
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

  WorkoutEditorSession _editorSession() {
    final parsedInitialWeek = int.tryParse(_initialWeekController.text.trim());
    final resolvedInitialWeek =
        (parsedInitialWeek != null && parsedInitialWeek >= 1)
        ? parsedInitialWeek
        : _initialWeekNumber;
    return WorkoutEditorSession(
      routine: _routine,
      planName: _routineNameController.text,
      initialWeekNumber: resolvedInitialWeek,
      phase: _phaseController.text,
      tags: _tagsController.text,
      notes: _notesController.text,
    );
  }

  String _standaloneSnapshot() => buildWorkoutEditorSnapshot(
    routine: _routine,
    planName: _routineNameController.text,
    initialWeekNumber: _initialWeekNumber,
    phase: _phaseController.text,
    tags: _tagsController.text,
    notes: _notesController.text,
  );

  void _captureStandaloneSnapshot() {
    if (!widget.editorMode) {
      _standaloneSavedSnapshot = _standaloneSnapshot();
    }
  }

  void _scheduleEditorContentChanged() {
    if (!widget.editorMode || _loading) {
      return;
    }
    _editorController.scheduleContentChanged(
      session: _editorSession(),
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
    final loaded = await _draftStore.load();
    if (!mounted) return;
    setState(() {
      _routine = hydrateScheduledWeekdays(loaded);
      _routineNameController.text = loaded.name;
      _selectedWeekIndex = 0;
      _selectedDayIndex = 0;
      _loading = false;
    });
    _captureStandaloneSnapshot();
  }

  Future<void> _loadForEditorMode() async {
    final customerId = widget.customerId!;
    try {
      Customer? customer;
      _editorController.suspendTracking();
      String? loadedPlanId;
      var loadedInitialWeek = _initialWeekNumber;
      if (widget.planId != null && widget.planId!.isNotEmpty) {
        final plan = await _planRepo.getById(widget.planId!);
        if (plan != null && mounted) {
          final routine = hydrateScheduledWeekdays(
            planDataToRoutine(plan.planData),
          );
          final (weekIndex, dayIndex) = _resolveInitialSelection(routine);
          loadedPlanId = plan.id;
          loadedInitialWeek = plan.initialWeekNumber;
          setState(() {
            _routine = routine;
            _routineNameController.text = routine.name;
            _phaseController.text = plan.phase ?? '';
            _tagsController.text = plan.tags ?? '';
            _notesController.text = plan.notes ?? '';
            _initialWeekNumber = plan.initialWeekNumber;
            _initialWeekController.text = plan.initialWeekNumber.toString();
            _selectedWeekIndex = weekIndex;
            _selectedDayIndex = dayIndex;
            _planCompleted = completedAtForPlan(plan) != null;
            _planArchived = isArchivedPlan(plan);
          });
        }
      } else {
        setState(() {
          _selectedWeekIndex = 0;
          _selectedDayIndex = 0;
        });
      }
      try {
        customer = await _customerRepo.getById(customerId);
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _editorCustomer = customer;
        _loading = false;
      });
      _editorController.markLoaded(
        session: _editorSession(),
        planId: loadedPlanId,
        loadedInitialWeekNumber: loadedInitialWeek,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _selectedWeekIndex = 0;
        _selectedDayIndex = 0;
        _loading = false;
      });
      _editorController.markLoaded(session: _editorSession());
    }
  }

  (int, int) _resolveInitialSelection(WorkoutRoutine routine) {
    final week = _pendingSelectedWeekIndex;
    final day = _pendingSelectedDayIndex;
    if (week == null || day == null) {
      return (0, 0);
    }
    if (week < 0 || week >= routine.weeks.length) {
      return (0, 0);
    }
    final days = routine.weeks[week].days;
    if (day < 0 || day >= days.length) {
      return (week, 0);
    }
    _pendingSelectedWeekIndex = null;
    _pendingSelectedDayIndex = null;
    return (week, day);
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
    if (widget.editorMode && widget.customerId != null) {
      if (_editorController.saving) return false;
      final outcome = await _editorController.save(
        session: _editorSession(),
        customerId: widget.customerId!,
        pdfHeader: _editorCustomer?.pdfHeader,
        useCustomPdfHeader: _editorCustomer?.useCustomPdfHeader ?? false,
        silent: silent,
      );
      if (!mounted) return outcome.success;
      if (outcome.success) {
        setState(() {
          if (outcome.savedRoutine != null) {
            _routine = outcome.savedRoutine!;
          }
          if (outcome.savedInitialWeekNumber != null) {
            _initialWeekNumber = outcome.savedInitialWeekNumber!;
          }
        });
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
        if (createdPlanId != null && createdPlanId.isNotEmpty && mounted) {
          navigateReplace(
            context,
            customerWorkoutEditorPath(
              widget.customerId!,
              planId: createdPlanId,
              weekIndex: _selectedWeekIndex,
              dayIndex: _selectedDayIndex,
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
                _saveRoutine();
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
      return outcome.success;
    }

    if (_saving) return false;
    if (mounted) setState(() => _saving = true);
    final name = _routineNameController.text.trim();
    final toSave = _routine.copyWith(name: name.isEmpty ? _routine.name : name);

    try {
      await _draftStore.save(toSave);
      if (!mounted) return true;
      setState(() {
        _routine = toSave;
      });
      _captureStandaloneSnapshot();
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
      return true;
    } catch (_) {
      if (!mounted) return false;
      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).workoutExportError),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
          ),
        );
      }
      return false;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
    if (!widget.editorMode && !_isStandaloneDirty) {
      navigateBackFromWorkoutBuilder(
        context: context,
        editorMode: widget.editorMode,
        customerId: widget.customerId,
      );
      return;
    }
    if (widget.editorMode && !_isDirty) {
      navigateBackFromWorkoutBuilder(
        context: context,
        editorMode: widget.editorMode,
        customerId: widget.customerId,
      );
      return;
    }
    final action = await showWorkoutEditorUnsavedDialog(context);
    if (!mounted ||
        action == null ||
        action == WorkoutEditorExitAction.cancel) {
      return;
    }
    if (action == WorkoutEditorExitAction.discard) {
      navigateBackFromWorkoutBuilder(
        context: context,
        editorMode: widget.editorMode,
        customerId: widget.customerId,
      );
      return;
    }
    final didSave = await _saveRoutine();
    if (didSave && mounted) {
      navigateBackFromWorkoutBuilder(
        context: context,
        editorMode: widget.editorMode,
        customerId: widget.customerId,
      );
    }
  }

  Future<void> _importJsonFromFile() async {
    final imported = await _exportActions.importJson();
    if (imported == null || !mounted) return;
    setState(() {
      _routine = hydrateScheduledWeekdays(imported);
      _routineNameController.text = imported.name;
    });
  }

  String? get _selectedSectionId {
    final sections = _routine.mobilitySections;
    if (sections.isEmpty) return null;
    final idx = _selectedMobilitySectionIndex.clamp(0, sections.length - 1);
    return sections[idx].id;
  }

  List<MobilityItem> get _mobilityItemsForSelectedSection {
    final sid = _selectedSectionId;
    if (sid == null) return [];
    return _routine.mobilityItems.where((e) => e.sectionId == sid).toList();
  }

  void _addMobilityItem() {
    final sectionId = _selectedSectionId;
    if (sectionId == null) return;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    showAddMobilityExerciseDialog(context, theme, cs, (
      title,
      subtitle,
      customExerciseId,
    ) {
      final t = title.trim();
      final s = subtitle.trim();
      if (t.isEmpty && s.isEmpty) return;
      setState(() {
        final id = 'm_${DateTime.now().millisecondsSinceEpoch}';
        _routine = addMobilityItemToRoutine(
          routine: _routine,
          item: MobilityItem(
            id: id,
            title: t.isEmpty ? l10n.workoutBuilderNewExerciseDefault : t,
            subtitle: s,
            sectionId: sectionId,
            customExerciseId: customExerciseId,
          ),
        );
      });
    });
  }

  void _removeMobilityItem(String id) {
    setState(() {
      _routine = removeMobilityItemFromRoutine(routine: _routine, itemId: id);
    });
  }

  void _reorderMobility(int oldIndex, int newIndex) {
    final sectionId = _selectedSectionId;
    if (sectionId == null) return;
    setState(() {
      _routine = reorderMobilityItemsInSection(
        routine: _routine,
        sectionId: sectionId,
        oldIndex: oldIndex,
        newIndex: newIndex,
      );
    });
  }

  void _addMobilitySection() {
    final l10n = AppLocalizations.of(context);
    setState(() {
      final id = 'sec_${DateTime.now().millisecondsSinceEpoch}';
      final name = l10n.workoutBuilderSectionNumbered(
        _routine.mobilitySections.length + 1,
      );
      _routine = addMobilitySectionToRoutine(
        routine: _routine,
        section: MobilitySection(id: id, name: name),
      );
      _selectedMobilitySectionIndex = _routine.mobilitySections.length - 1;
    });
  }

  void _editMobilitySection(int index) {
    if (index < 0 || index >= _routine.mobilitySections.length) return;
    final section = _routine.mobilitySections[index];
    showEditMobilitySectionSheet(
      context,
      initialName: section.name,
      initialScheduleHint: section.scheduleHint,
      onSave: (newName, scheduleHint) {
        if (newName.trim().isEmpty) return;
        setState(() {
          _routine = updateMobilitySectionInRoutine(
            routine: _routine,
            sectionId: section.id,
            name: newName,
            scheduleHint: scheduleHint,
          );
        });
      },
    );
  }

  void _deleteMobilitySection(int index) {
    if (index < 0 || index >= _routine.mobilitySections.length) return;
    if (_routine.mobilitySections.length <= 1) {
      return; // keep at least one section
    }
    setState(() {
      final updated = deleteMobilitySectionFromRoutine(
        routine: _routine,
        sectionIndex: index,
      );
      if (updated == null) return;
      _routine = updated;
      _selectedMobilitySectionIndex = (_selectedMobilitySectionIndex.clamp(
        0,
        _routine.mobilitySections.length - 1,
      ));
    });
  }

  void _addWeek() {
    final l10n = AppLocalizations.of(context);
    setState(() {
      final id = 'w_${DateTime.now().millisecondsSinceEpoch}';
      final next = _routine.weeks.length + 1;
      _routine = addWeekToRoutine(
        routine: _routine,
        weekId: id,
        weekName: l10n.workoutBuilderWeekNumbered(next),
        firstDayId: '${id}_d1',
        firstDayName: l10n.workoutBuilderDayNumbered(1),
      );
      _selectedWeekIndex = _routine.weeks.length - 1;
      _selectedDayIndex = 0;
    });
  }

  Future<void> _cloneWeek(int weekIndex) async {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final source = _routine.weeks[weekIndex];
    final l10n = AppLocalizations.of(context);
    final defaultName = '${source.name}${l10n.workoutBuilderNameCopySuffix}';
    final name = await showDuplicateWeekDialog(context, defaultName);
    if (!mounted || name == null || name.isEmpty) return;
    _cloneWeekWithName(weekIndex, name);
  }

  void _cloneWeekWithName(int weekIndex, String name) {
    final newId = 'w_${DateTime.now().millisecondsSinceEpoch}';
    final updated = cloneWeekInRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      newWeekName: name,
      newWeekId: newId,
    );
    if (updated == null) return;
    setState(() {
      _routine = updated;
      _selectedWeekIndex = _routine.weeks.length - 1;
      _selectedDayIndex = 0;
    });
  }

  void _deleteWeek(int weekIndex) {
    final updated = deleteWeekFromRoutine(
      routine: _routine,
      weekIndex: weekIndex,
    );
    if (updated == null) return;
    setState(() {
      _routine = updated;
      _selectedWeekIndex = _selectedWeekIndex.clamp(
        0,
        _routine.weeks.isNotEmpty ? _routine.weeks.length - 1 : 0,
      );
    });
  }

  Future<void> _confirmDeleteWeek(BuildContext context, int weekIndex) async {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: l10n.workoutBuilderDeleteWeekTitle,
      message: l10n.workoutBuilderDeleteWeekMessage,
      confirmLabel: l10n.customerDelete,
      cancelLabel: l10n.customerCancel,
      destructive: true,
    );
    if (confirmed && mounted) _deleteWeek(weekIndex);
  }

  void _renameDay(int weekIndex, int dayIndex, String newName) {
    final updated = renameDayInRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      newName: newName,
    );
    if (updated == null) return;
    setState(() => _routine = updated);
  }

  void _renameWeek(int weekIndex, String newName) {
    final updated = renameWeekInRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      newName: newName,
    );
    if (updated == null) return;
    setState(() => _routine = updated);
  }

  void _deleteDay(int weekIndex, int dayIndex) {
    final updated = deleteDayFromRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
    );
    if (updated == null) return;
    setState(() {
      _routine = updated;
      final week =
          _routine.weeks[weekIndex.clamp(0, _routine.weeks.length - 1)];
      _selectedDayIndex = _selectedDayIndex.clamp(
        0,
        week.days.isNotEmpty ? week.days.length - 1 : 0,
      );
    });
  }

  void _addDayToWeek(int weekIndex) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final l10n = AppLocalizations.of(context);
    final week = _routine.weeks[weekIndex];
    final dayId = '${week.id}_d_${DateTime.now().millisecondsSinceEpoch}';
    final updated = addDayToWeekInRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      dayId: dayId,
      dayName: l10n.workoutBuilderDayNumbered(week.days.length + 1),
    );
    if (updated == null) return;
    setState(() {
      _routine = updated;
      _selectedWeekIndex = weekIndex;
      _selectedDayIndex = updated.weeks[weekIndex].days.length - 1;
    });
  }

  void _setDayScheduledWeekday(int weekIndex, int dayIndex, int weekday) {
    final updated = setDayScheduledWeekdayInRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      weekday: weekday,
    );
    if (updated == null) return;
    setState(() => _routine = updated);
  }

  void _addExerciseToDay(int weekIndex, int dayIndex) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    if (dayIndex < 0 || dayIndex >= _routine.weeks[weekIndex].days.length) {
      return;
    }
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final exId = 'e_${DateTime.now().millisecondsSinceEpoch}';
    showAddExerciseDialog(context, theme, cs, (
      name,
      note,
      details, [
      customExerciseId,
    ]) {
      final trimmedName = name.trim();
      if (trimmedName.isEmpty) return;
      final updated = addExerciseToDayInRoutine(
        routine: _routine,
        weekIndex: weekIndex,
        dayIndex: dayIndex,
        exercise: buildExerciseFromPrescription(
          id: exId,
          name: trimmedName,
          note: note,
          setDetails: details,
          customExerciseId: customExerciseId,
        ),
      );
      if (updated == null) return;
      setState(() => _routine = updated);
    }, customerId: widget.customerId);
  }

  void _addExerciseToSuperset(
    int weekIndex,
    int dayIndex,
    String supersetGroupId,
  ) {
    WorkoutSupersetActions.showAddExerciseToSupersetDialog(
      context: context,
      theme: Theme.of(context),
      colorScheme: Theme.of(context).colorScheme,
      routine: _routine,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      supersetGroupId: supersetGroupId,
      customerId: widget.customerId,
      onRoutineChanged: (updated) => setState(() => _routine = updated),
    );
  }

  void _removeExercise(int weekIndex, int dayIndex, String exerciseId) {
    final day =
        weekIndex >= 0 &&
            weekIndex < _routine.weeks.length &&
            dayIndex >= 0 &&
            dayIndex < _routine.weeks[weekIndex].days.length
        ? _routine.weeks[weekIndex].days[dayIndex]
        : null;
    Exercise? removed;
    for (final exercise in day?.exercises ?? const <Exercise>[]) {
      if (exercise.id == exerciseId) {
        removed = exercise;
        break;
      }
    }
    final updated = removeExerciseFromDayInRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      exerciseId: exerciseId,
    );
    if (updated == null) return;
    setState(() => _routine = updated);
    final removedExercise = removed;
    if (removedExercise == null || !mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.workoutBuilderExerciseRemoved),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: l10n.workoutBuilderUndo,
          onPressed: () {
            final restored = addExerciseToDayInRoutine(
              routine: _routine,
              weekIndex: weekIndex,
              dayIndex: dayIndex,
              exercise: removedExercise,
            );
            if (restored == null || !mounted) return;
            setState(() => _routine = restored);
          },
        ),
      ),
    );
  }

  void _duplicateExercise(int weekIndex, int dayIndex, Exercise exercise) {
    final newId = 'e_${DateTime.now().millisecondsSinceEpoch}';
    final duplicated = _builderSession.duplicateExercise(
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      source: exercise,
      newExerciseId: newId,
    );
    if (!duplicated) return;
    setState(() {});
  }

  void _moveExerciseInDay(
    int weekIndex,
    int dayIndex,
    String exerciseId, {
    required bool up,
  }) {
    final updated = moveExerciseInDayInRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      exerciseId: exerciseId,
      up: up,
    );
    if (updated == null) return;
    setState(() => _routine = updated);
  }

  void _updateMobilityItem(
    String id,
    String title,
    String subtitle, {
    String shortTitle = '',
  }) {
    setState(() {
      _routine = updateMobilityItemInRoutine(
        routine: _routine,
        itemId: id,
        title: title,
        subtitle: subtitle,
        shortTitle: shortTitle,
      );
    });
  }

  void _updateExercise(
    int weekIndex,
    int dayIndex,
    String exerciseId, {
    String? name,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
    String? shortName,
    ExercisePrescriptionScope? prescriptionScope,
    List<ExerciseSet>? setDetails,
  }) {
    final updated = updateExerciseInRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      exerciseId: exerciseId,
      name: name,
      sets: sets,
      reps: reps,
      rpe: rpe,
      note: note,
      shortName: shortName,
      prescriptionScope: prescriptionScope,
      setDetails: setDetails,
    );
    if (updated == null) return;
    setState(() => _routine = updated);
  }

  void _addSetToExercise(int weekIndex, int dayIndex, String exerciseId) {
    final updated = addSetToExerciseInRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      exerciseId: exerciseId,
    );
    if (updated == null) return;
    setState(() => _routine = updated);
  }

  void _updateExerciseSet(
    int weekIndex,
    int dayIndex,
    String exerciseId,
    int setIndex, {
    String? line,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
  }) {
    final updated = updateExerciseSetInRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      exerciseId: exerciseId,
      setIndex: setIndex,
      line: line,
      sets: sets,
      reps: reps,
      rpe: rpe,
      note: note,
    );
    if (updated == null) return;
    setState(() => _routine = updated);
  }

  void _removeExerciseSet(
    int weekIndex,
    int dayIndex,
    String exerciseId,
    int setIndex,
  ) {
    final updated = removeExerciseSetInRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      exerciseId: exerciseId,
      setIndex: setIndex,
    );
    if (updated == null) return;
    setState(() => _routine = updated);
  }

  void _assignToSuperset(
    int weekIndex,
    int dayIndex,
    String exerciseId,
    String supersetGroupId,
  ) {
    final updated = WorkoutSupersetActions.assignToSuperset(
      routine: _routine,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      exerciseId: exerciseId,
      supersetGroupId: supersetGroupId,
    );
    if (updated == null) return;
    setState(() => _routine = updated);
  }

  void _removeFromSuperset(int weekIndex, int dayIndex, String exerciseId) {
    final updated = WorkoutSupersetActions.removeFromSuperset(
      routine: _routine,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      exerciseId: exerciseId,
    );
    if (updated == null) return;
    setState(() => _routine = updated);
  }

  @override
  void dispose() {
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
    final l10n = AppLocalizations.of(context);
    try {
      await _planRepo.markPlanCompleted(planId);
      if (!mounted) return;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      setState(() {
        _planCompleted = true;
        _routine = _routine.copyWith(endDate: _routine.endDate ?? today);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutPlanCompleteAction),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutExportError),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildMobilityTab(ThemeData theme, ColorScheme cs) {
    return WorkoutMobilityTab(
      theme: theme,
      colorScheme: cs,
      sections: _routine.mobilitySections,
      selectedSectionIndex: _selectedMobilitySectionIndex,
      itemsForSelectedSection: _mobilityItemsForSelectedSection,
      onAddItem: _addMobilityItem,
      onAddSection: _addMobilitySection,
      onEditSection: _editMobilitySection,
      onDeleteSection: _deleteMobilitySection,
      onSelectSection: (i) => setState(() => _selectedMobilitySectionIndex = i),
      onReorderItems: _reorderMobility,
      onUpdateItem: (itemId, t, s, short) =>
          _updateMobilityItem(itemId, t, s, shortTitle: short),
      onDeleteItem: _removeMobilityItem,
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
      onNewWeek: _addWeek,
      onCloneWeek: _cloneWeek,
      onDeleteWeek: (weekIndex) => _confirmDeleteWeek(context, weekIndex),
      onRenameWeek: _renameWeek,
      onAddDay: _addDayToWeek,
      onRenameDay: _renameDay,
      onDeleteDay: _deleteDay,
      onAddExercise: _addExerciseToDay,
      onDuplicateExercise: _duplicateExercise,
      onRemoveExercise: _removeExercise,
      onMoveExercise: _moveExerciseInDay,
      onUpdateExercise: _updateExercise,
      onAddSetToExercise: _addSetToExercise,
      onUpdateExerciseSet: _updateExerciseSet,
      onRemoveExerciseSet: _removeExerciseSet,
      onAssignToSuperset: _assignToSuperset,
      onRemoveFromSuperset: _removeFromSuperset,
      onAddExerciseToSuperset: _addExerciseToSuperset,
      onSelectWeek: (i) => setState(() {
        _selectedWeekIndex = i;
        _selectedDayIndex = 0;
      }),
      onSelectDay: (i) => setState(() => _selectedDayIndex = i),
      onUpdateScheduledWeekday: _setDayScheduledWeekday,
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
