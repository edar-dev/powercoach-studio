import '../../exercise_library/data/custom_exercise_item.dart';
import '../data/workout_routine_model.dart';
import 'exercise_picker_index_helpers.dart';

/// Builds workout display names that keep parent › variant context.
///
/// Returns a map of exercise id → enriched name for day exercises whose
/// [Exercise.name] is still the bare library leaf name (parent context lost).
Map<String, String> libraryExerciseNamesToEnrich({
  required Day day,
  required List<CustomExerciseItem> libraryRoots,
}) {
  final index = buildExercisePickerIndex(libraryRoots);
  final byId = <String, CustomExerciseItem>{
    for (final item in index.flat) item.id: item,
  };
  final updates = <String, String>{};

  for (final exercise in day.exercises) {
    final libraryId = exercise.customExerciseId;
    if (libraryId == null || libraryId.isEmpty) continue;
    final item = byId[libraryId];
    if (item == null) continue;
    if (!index.parentNameById.containsKey(libraryId)) continue;
    // Only rewrite when the stored name is still the bare variant leaf.
    if (exercise.name.trim() != item.name.trim()) continue;
    final display = exercisePickerDisplayName(item, index.parentNameById);
    if (display != exercise.name) {
      updates[exercise.id] = display;
    }
  }
  return updates;
}
