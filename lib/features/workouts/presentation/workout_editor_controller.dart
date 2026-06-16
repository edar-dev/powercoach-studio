import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/workout_plan_api_model.dart';
import '../data/workout_plan_repository.dart';
import '../data/workout_routine_model.dart';
import '../domain/workout_routine_plan_encoder.dart';
import 'workout_editor_snapshot.dart';

enum WorkoutEditorSaveState { saved, saving, unsaved }

/// Editor-mode session inputs used for dirty tracking and persistence.
class WorkoutEditorSession {
  const WorkoutEditorSession({
    required this.routine,
    required this.planName,
    required this.initialWeekNumber,
    this.phase,
    this.tags,
    this.notes,
  });

  final WorkoutRoutine routine;
  final String planName;
  final int initialWeekNumber;
  final String? phase;
  final String? tags;
  final String? notes;
}

class WorkoutEditorSaveOutcome {
  const WorkoutEditorSaveOutcome({
    required this.success,
    this.savedRoutine,
    this.savedInitialWeekNumber,
    this.createdPlanId,
  });

  final bool success;
  final WorkoutRoutine? savedRoutine;
  final int? savedInitialWeekNumber;
  final String? createdPlanId;
}

typedef WorkoutEditorPlanGetter =
    Future<WorkoutPlanApiModel?> Function(String planId);
typedef WorkoutEditorPlanCreator =
    Future<WorkoutPlanApiModel> Function({
      required String customerId,
      required String name,
      required String planDataJson,
      String? pdfHeader,
      bool useCustomPdfHeader,
      int initialWeekNumber,
      String? phase,
      String? tags,
      String? notes,
    });
typedef WorkoutEditorPlanUpdater =
    Future<WorkoutPlanApiModel> Function({
      required String planId,
      String? name,
      String? planDataJson,
      int? initialWeekNumber,
      String? phase,
      String? tags,
      String? notes,
    });

/// Tracks dirty state, autosave scheduling, and editor-mode plan persistence.
class WorkoutEditorController extends ChangeNotifier {
  WorkoutEditorController({
    WorkoutPlanRepository? planRepo,
    WorkoutEditorPlanGetter? getPlanById,
    WorkoutEditorPlanCreator? createPlan,
    WorkoutEditorPlanUpdater? updatePlan,
    this.autosaveDelay = const Duration(milliseconds: 2500),
    this.dirtyDebounceDelay = const Duration(milliseconds: 300),
  }) : _getPlanById =
           getPlanById ?? ((planId) => planRepo!.getById(planId)),
       _createPlan =
           createPlan ??
           (({
             required customerId,
             required name,
             required planDataJson,
             pdfHeader,
             useCustomPdfHeader = false,
             initialWeekNumber = 1,
             phase,
             tags,
             notes,
           }) {
             return planRepo!.create(
               customerId: customerId,
               name: name,
               planDataJson: planDataJson,
               pdfHeader: pdfHeader,
               useCustomPdfHeader: useCustomPdfHeader,
               initialWeekNumber: initialWeekNumber,
               phase: phase,
               tags: tags,
               notes: notes,
             );
           }),
       _updatePlan =
           updatePlan ??
           (({
             required planId,
             name,
             planDataJson,
             initialWeekNumber,
             phase,
             tags,
             notes,
           }) {
             return planRepo!.update(
               planId: planId,
               name: name,
               planDataJson: planDataJson,
               initialWeekNumber: initialWeekNumber,
               phase: phase,
               tags: tags,
               notes: notes,
             );
           });

  final Duration autosaveDelay;
  final Duration dirtyDebounceDelay;
  final WorkoutEditorPlanGetter _getPlanById;
  final WorkoutEditorPlanCreator _createPlan;
  final WorkoutEditorPlanUpdater _updatePlan;

  String? loadedPlanId;
  int initialWeekNumber = 1;
  bool saving = false;
  bool trackingSuspended = false;
  WorkoutEditorSaveState saveState = WorkoutEditorSaveState.saved;

  String? _savedSnapshot;
  String? _lastObservedSnapshot;
  Timer? _autosaveTimer;
  Timer? _dirtyDebounceTimer;

  bool isDirtyFor(WorkoutEditorSession session) => isWorkoutEditorDirty(
    savedSnapshot: _savedSnapshot,
    currentSnapshot: _snapshotFor(session),
  );

  bool get isDirty {
    if (_savedSnapshot == null || _lastObservedSnapshot == null) {
      return false;
    }
    return _savedSnapshot != _lastObservedSnapshot;
  }

  bool shouldShowManualSaveButton({
    required bool loading,
    required bool editorMode,
  }) {
    if (loading) return false;
    if (!editorMode) return true;
    if (loadedPlanId == null) return true;
    return saveState != WorkoutEditorSaveState.saved;
  }

  void markLoaded({
    required WorkoutEditorSession session,
    String? planId,
    int? loadedInitialWeekNumber,
  }) {
    loadedPlanId = planId;
    if (loadedInitialWeekNumber != null) {
      initialWeekNumber = loadedInitialWeekNumber;
    }
    _captureSnapshot(session);
    trackingSuspended = false;
    notifyListeners();
  }

  void suspendTracking() {
    trackingSuspended = true;
  }

  void scheduleContentChanged({
    required WorkoutEditorSession session,
    required bool editorMode,
    required bool loading,
    Future<void> Function()? onAutosave,
  }) {
    if (!editorMode || trackingSuspended || loading) {
      return;
    }
    _dirtyDebounceTimer?.cancel();
    _dirtyDebounceTimer = Timer(dirtyDebounceDelay, () {
      notifyContentChanged(
        session: session,
        editorMode: editorMode,
        loading: loading,
        onAutosave: onAutosave,
      );
    });
  }

  void notifyContentChanged({
    required WorkoutEditorSession session,
    required bool editorMode,
    required bool loading,
    Future<void> Function()? onAutosave,
  }) {
    if (!editorMode || trackingSuspended || loading) {
      return;
    }
    final current = _snapshotFor(session);
    if (_lastObservedSnapshot == current) {
      return;
    }
    _lastObservedSnapshot = current;
    final nextState = isDirtyFor(session)
        ? WorkoutEditorSaveState.unsaved
        : WorkoutEditorSaveState.saved;
    if (saveState != nextState) {
      saveState = nextState;
      notifyListeners();
    }
    _scheduleAutosave(editorMode: editorMode, onAutosave: onAutosave);
  }

  Future<WorkoutEditorSaveOutcome> save({
    required WorkoutEditorSession session,
    required String customerId,
    String? pdfHeader,
    bool useCustomPdfHeader = false,
    bool silent = false,
  }) async {
    if (saving) {
      return const WorkoutEditorSaveOutcome(success: false);
    }
    _autosaveTimer?.cancel();
    saving = true;
    saveState = WorkoutEditorSaveState.saving;
    notifyListeners();

    final name = session.planName.trim();
    final toSave = session.routine.copyWith(
      name: name.isEmpty ? session.routine.name : name,
    );
    final savedInitialWeek = session.initialWeekNumber >= 1
        ? session.initialWeekNumber
        : initialWeekNumber;
    final phase = _normalizeOptionalText(session.phase);
    final tags = _normalizeOptionalText(session.tags);
    final notes = _normalizeOptionalText(session.notes);

    try {
      String? createdPlanId;
      if (loadedPlanId != null) {
        final existingPlan = await _getPlanById(loadedPlanId!);
        await _updatePlan(
          planId: loadedPlanId!,
          name: toSave.name,
          planDataJson: encodeWorkoutRoutinePlanData(
            toSave,
            existingPlanData: existingPlan?.planData,
          ),
          initialWeekNumber: savedInitialWeek,
          phase: phase,
          tags: tags,
          notes: notes,
        );
      } else {
        final created = await _createPlan(
          customerId: customerId,
          name: toSave.name,
          planDataJson: encodeWorkoutRoutinePlanData(toSave),
          pdfHeader: pdfHeader,
          useCustomPdfHeader: useCustomPdfHeader,
          initialWeekNumber: savedInitialWeek,
          phase: phase,
          tags: tags,
          notes: notes,
        );
        createdPlanId = created.id;
        loadedPlanId = created.id;
      }

      initialWeekNumber = savedInitialWeek;
      _captureSnapshot(
        WorkoutEditorSession(
          routine: toSave,
          planName: toSave.name,
          initialWeekNumber: savedInitialWeek,
          phase: phase,
          tags: tags,
          notes: notes,
        ),
      );
      saving = false;
      notifyListeners();
      return WorkoutEditorSaveOutcome(
        success: true,
        savedRoutine: toSave,
        savedInitialWeekNumber: savedInitialWeek,
        createdPlanId: createdPlanId,
      );
    } catch (_) {
      saving = false;
      saveState = WorkoutEditorSaveState.unsaved;
      notifyListeners();
      return const WorkoutEditorSaveOutcome(success: false);
    }
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _dirtyDebounceTimer?.cancel();
    super.dispose();
  }

  void _scheduleAutosave({
    required bool editorMode,
    Future<void> Function()? onAutosave,
  }) {
    _autosaveTimer?.cancel();
    if (!editorMode || loadedPlanId == null || !isDirty || onAutosave == null) {
      return;
    }
    _autosaveTimer = Timer(autosaveDelay, () {
      unawaited(onAutosave());
    });
  }

  void _captureSnapshot(WorkoutEditorSession session) {
    final snapshot = _snapshotFor(session);
    _savedSnapshot = snapshot;
    _lastObservedSnapshot = snapshot;
    saveState = WorkoutEditorSaveState.saved;
  }

  String _snapshotFor(WorkoutEditorSession session) {
    return buildWorkoutEditorSnapshot(
      routine: session.routine,
      planName: session.planName,
      initialWeekNumber: session.initialWeekNumber >= 1
          ? session.initialWeekNumber
          : initialWeekNumber,
      phase: session.phase,
      tags: session.tags,
      notes: session.notes,
    );
  }

  String? _normalizeOptionalText(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}
