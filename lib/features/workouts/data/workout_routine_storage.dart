import 'workout_draft_store.dart';
import 'workout_routine_model.dart';

/// Persists [WorkoutRoutine] as JSON in SharedPreferences.
class WorkoutRoutineStorage {
  static Future<WorkoutRoutine> load() async {
    return const SharedPrefsWorkoutDraftStore().load();
  }

  static Future<void> save(WorkoutRoutine routine) async {
    await const SharedPrefsWorkoutDraftStore().save(routine);
  }
}
