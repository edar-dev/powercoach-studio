import '../../data/workout_routine_model.dart';

/// v5 superset prescription display: summary is taken from the lead (first) exercise
/// in the group. Each exercise still stores its own sets in the plan JSON.
String supersetPrescriptionSummary(Exercise leadExercise) {
  final details = leadExercise.effectiveSetDetails;
  if (details.isEmpty) return '';
  final lines = details
      .map((set) => set.displayText.trim())
      .where((line) => line.isNotEmpty);
  return lines.join(' · ');
}

List<Exercise> getSupersetExercises({
  required WorkoutRoutine routine,
  required int weekIndex,
  required int dayIndex,
  required String supersetGroupId,
}) {
  if (weekIndex < 0 || weekIndex >= routine.weeks.length) return const [];
  final week = routine.weeks[weekIndex];
  if (dayIndex < 0 || dayIndex >= week.days.length) return const [];
  return week.days[dayIndex].exercises
      .where((e) => e.supersetGroupId == supersetGroupId)
      .toList(growable: false);
}

/// Returns list of superset group options for the day (id + label) for "Add to superset" menu.
List<({String id, String label})> getSupersetGroupOptions(Day day) {
  final byId = <String, List<Exercise>>{};
  for (final e in day.exercises) {
    final id = e.supersetGroupId;
    if (id != null && id.isNotEmpty) {
      byId.putIfAbsent(id, () => []).add(e);
    }
  }
  return byId.entries
      .map((e) => (id: e.key, label: e.value.map((x) => x.name).join(' + ')))
      .toList();
}
