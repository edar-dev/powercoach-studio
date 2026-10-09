import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/analytics/product_analytics.dart';
import '../data/workout_plan_api_model.dart';
import '../data/workout_plan_repository.dart';
import '../data/workout_routine_model.dart';
import 'workout_editor_snapshot.dart';

enum WorkoutEditorSaveState { saved, saving, unsaved, failed }

/// Editor-mode session inputs used for dirty tracking and persistence.
class WorkoutEditorSession {
  const WorkoutEditorSession({
    required this.routine,
    required this.planName,
    required this.initialWeekNumber,
    this.notes,
  });

  final WorkoutRoutine routine;
  final String planName;
  final int initialWeekNumber;
  final String? notes;
}

class WorkoutEditorSaveOutcome {
  const WorkoutEditorSaveOutcome({
    required this.success,
    this.savedRoutine,
    this.savedInitialWeekNumber,
    this.createdPlanId,
    this.error,
  });

  final bool success;
  final WorkoutRoutine? savedRoutine;
  final int? savedInitialWeekNumber;
  final String? createdPlanId;
  final Object? error;
}

typedef WorkoutEditorPlanCreator =
    Future<WorkoutPlanApiModel> Function({
      required String customerId,
      required String name,
      required WorkoutRoutine routine,
      String? pdfHeader,
      bool useCustomPdfHeader,
      int initialWeekNumber,
      String? notes,
    });
typedef WorkoutEditorPlanUpdater =
    Future<WorkoutPlanApiModel> Function({
      required String planId,
      String? name,
      WorkoutRoutine? routine,
      int? initialWeekNumber,
      String? notes,
    });

/// Tracks dirty state, autosave scheduling, and editor-mode plan persistence.
///
/// Dirty snapshots are debounced ([dirtyDebounceDelay], default 300ms) so rapid
/// metadata edits do not re-encode the full routine on every keystroke.
/// Profile large plans in DevTools Timeline — target sustained frames under 32ms
/// while scrolling a 30-exercise day list.
class WorkoutEditorController extends ChangeNotifier {
  WorkoutEditorController({
    WorkoutPlanRepository? planRepo,
    WorkoutEditorPlanCreator? createPlan,
    WorkoutEditorPlanUpdater? updatePlan,
    this.autosaveDelay = const Duration(milliseconds: 2500),
    this.dirtyDebounceDelay = const Duration(milliseconds: 300),
  }) : _createPlan =
           createPlan ??
           (({
             required customerId,
             required name,
             required routine,
             pdfHeader,
             useCustomPdfHeader = false,
             initialWeekNumber = 1,
             notes,
           }) {
             return planRepo!.create(
               customerId: customerId,
               name: name,
               routine: routine,
               pdfHeader: pdfHeader,
               useCustomPdfHeader: useCustomPdfHeader,
               initialWeekNumber: initialWeekNumber,
               notes: notes,
             );
           }),
       _updatePlan =
           updatePlan ??
           (({
             required planId,
             name,
             routine,
             initialWeekNumber,
             notes,
           }) {
             return planRepo!.update(
               planId: planId,
               name: name,
               routine: routine,
               initialWeekNumber: initialWeekNumber,
               notes: notes,
             );
           });

  final Duration autosaveDelay;
  final Duration dirtyDebounceDelay;
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
    final notes = _normalizeOptionalText(session.notes);

    try {
      String? createdPlanId;
      if (loadedPlanId != null) {
        await _updatePlan(
          planId: loadedPlanId!,
          name: toSave.name,
          routine: toSave,
          initialWeekNumber: savedInitialWeek,
          notes: notes,
        );
      } else {
        final created = await _createPlan(
          customerId: customerId,
          name: toSave.name,
          routine: toSave,
          pdfHeader: pdfHeader,
          useCustomPdfHeader: useCustomPdfHeader,
          initialWeekNumber: savedInitialWeek,
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
    } catch (e) {
      saving = false;
      saveState = WorkoutEditorSaveState.failed;
      notifyListeners();
      // First create only — updates already have loadedPlanId.
      if (loadedPlanId == null) {
        ProductAnalytics.firstSaveFailed(
          silent: silent,
          reason: ProductAnalytics.reasonFromError(e),
        );
      }
      return WorkoutEditorSaveOutcome(success: false, error: e);
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
    if (!editorMode || !isDirty || onAutosave == null) {
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
      notes: session.notes,
    );
  }

  String? _normalizeOptionalText(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}
