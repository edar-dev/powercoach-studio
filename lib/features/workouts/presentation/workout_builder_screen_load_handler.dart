import '../../customers/data/models/customer.dart' show Customer;
import '../data/workout_routine_model.dart';
import 'workout_builder_load_helpers.dart';
import 'workout_builder_routine_coordinator.dart';

/// Normalized editor load outcome for applying to workout builder screen state.
class WorkoutBuilderEditorLoadApplication {
  const WorkoutBuilderEditorLoadApplication({
    required this.routine,
    required this.weekIndex,
    required this.dayIndex,
    required this.initialWeekNumber,
    required this.phase,
    required this.tags,
    required this.notes,
    required this.planCompleted,
    required this.planArchived,
    required this.customer,
    required this.loadedPlanId,
    required this.clearDeepLink,
  });

  final WorkoutRoutine? routine;
  final int weekIndex;
  final int dayIndex;
  final int initialWeekNumber;
  final String phase;
  final String tags;
  final String notes;
  final bool planCompleted;
  final bool planArchived;
  final Customer? customer;
  final String? loadedPlanId;
  final bool clearDeepLink;

  factory WorkoutBuilderEditorLoadApplication.fromResult(
    WorkoutBuilderEditorLoadResult result, {
    int? pendingWeekIndex,
    int? pendingDayIndex,
  }) {
    var clearDeepLink = false;
    if (result.routine != null &&
        pendingWeekIndex != null &&
        pendingDayIndex != null &&
        resolveWorkoutBuilderDeepLinkSelection(
              result.routine!,
              pendingWeekIndex: pendingWeekIndex,
              pendingDayIndex: pendingDayIndex,
            ) !=
            null) {
      clearDeepLink = true;
    }
    return WorkoutBuilderEditorLoadApplication(
      routine: result.routine,
      weekIndex: result.weekIndex,
      dayIndex: result.dayIndex,
      initialWeekNumber: result.loadedInitialWeek,
      phase: result.phase,
      tags: result.tags,
      notes: result.notes,
      planCompleted: result.planCompleted,
      planArchived: result.planArchived,
      customer: result.customer,
      loadedPlanId: result.loadedPlanId,
      clearDeepLink: clearDeepLink,
    );
  }

  factory WorkoutBuilderEditorLoadApplication.fallback({
    required int initialWeekNumber,
  }) {
    return WorkoutBuilderEditorLoadApplication(
      routine: null,
      weekIndex: 0,
      dayIndex: 0,
      initialWeekNumber: initialWeekNumber,
      phase: '',
      tags: '',
      notes: '',
      planCompleted: false,
      planArchived: false,
      customer: null,
      loadedPlanId: null,
      clearDeepLink: false,
    );
  }
}

/// Loads workout builder data via [WorkoutBuilderRoutineCoordinator].
class WorkoutBuilderScreenLoadHandler {
  const WorkoutBuilderScreenLoadHandler({
    required this.coordinator,
  });

  final WorkoutBuilderRoutineCoordinator coordinator;

  Future<WorkoutRoutine> loadStandalone() => coordinator.loadStandaloneDraft();

  Future<WorkoutBuilderEditorLoadApplication> loadEditor({
    required String customerId,
    String? planId,
    int? pendingWeekIndex,
    int? pendingDayIndex,
    required int fallbackInitialWeekNumber,
  }) async {
    try {
      final result = await coordinator.loadEditorPlan(
        customerId: customerId,
        planId: planId,
        pendingWeekIndex: pendingWeekIndex,
        pendingDayIndex: pendingDayIndex,
      );
      return WorkoutBuilderEditorLoadApplication.fromResult(
        result,
        pendingWeekIndex: pendingWeekIndex,
        pendingDayIndex: pendingDayIndex,
      );
    } catch (_) {
      return WorkoutBuilderEditorLoadApplication.fallback(
        initialWeekNumber: fallbackInitialWeekNumber,
      );
    }
  }
}
