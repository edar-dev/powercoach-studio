import '../data/custom_exercise_item.dart';
import 'exercise_library_tree_helpers.dart';

/// Muscle-group filter chips for the exercise library (no schema field — name heuristics).
enum ExerciseLibraryMuscleGroup {
  all,
  chest,
  back,
  legs,
  shoulders,
  arms,
  core,
}

/// Guesses a muscle group from an exercise [name] using IT/EN keywords.
///
/// Returns `null` when no keyword matches. Matching is case-insensitive;
/// longer / more specific phrases are listed first so they win over broad
/// tokens (e.g. `back squat` → legs before bare `back` → back).
ExerciseLibraryMuscleGroup? guessMuscleGroupFromName(String name) {
  final n = name.toLowerCase().trim();
  if (n.isEmpty) return null;

  for (final rule in _muscleKeywordRules) {
    if (n.contains(rule.$1)) return rule.$2;
  }
  return null;
}

/// Keeps root families whose name (or any descendant name) matches [filter].
///
/// Prefer showing **root families** as cards; this does not flatten leaves.
List<CustomExerciseItem> filterExerciseRootsByMuscle(
  List<CustomExerciseItem> roots,
  ExerciseLibraryMuscleGroup filter,
) {
  if (filter == ExerciseLibraryMuscleGroup.all) return roots;

  return roots.where((root) {
    if (guessMuscleGroupFromName(root.name) == filter) return true;
    for (final node in flattenExerciseTree(root.children)) {
      if (guessMuscleGroupFromName(node.name) == filter) return true;
    }
    return false;
  }).toList();
}

/// Ordered (keyword, group) rules — first match wins.
const _muscleKeywordRules = <(String, ExerciseLibraryMuscleGroup)>[
  // Shoulders (specific raises before generic tokens)
  ('alzate laterali', ExerciseLibraryMuscleGroup.shoulders),
  ('alzate frontali', ExerciseLibraryMuscleGroup.shoulders),
  ('lateral raise', ExerciseLibraryMuscleGroup.shoulders),
  ('front raise', ExerciseLibraryMuscleGroup.shoulders),
  ('military press', ExerciseLibraryMuscleGroup.shoulders),
  ('shoulder press', ExerciseLibraryMuscleGroup.shoulders),
  ('overhead press', ExerciseLibraryMuscleGroup.shoulders),
  ('military', ExerciseLibraryMuscleGroup.shoulders),
  ('deltoid', ExerciseLibraryMuscleGroup.shoulders),
  ('deltoide', ExerciseLibraryMuscleGroup.shoulders),
  ('shoulder', ExerciseLibraryMuscleGroup.shoulders),
  ('spalle', ExerciseLibraryMuscleGroup.shoulders),
  ('spalla', ExerciseLibraryMuscleGroup.shoulders),
  ('ohp', ExerciseLibraryMuscleGroup.shoulders),

  // Chest
  ('chest press', ExerciseLibraryMuscleGroup.chest),
  ('chest fly', ExerciseLibraryMuscleGroup.chest),
  ('bench press', ExerciseLibraryMuscleGroup.chest),
  ('pec deck', ExerciseLibraryMuscleGroup.chest),
  ('push-up', ExerciseLibraryMuscleGroup.chest),
  ('push up', ExerciseLibraryMuscleGroup.chest),
  ('pushup', ExerciseLibraryMuscleGroup.chest),
  ('chest', ExerciseLibraryMuscleGroup.chest),
  ('petto', ExerciseLibraryMuscleGroup.chest),
  ('panca', ExerciseLibraryMuscleGroup.chest),
  ('bench', ExerciseLibraryMuscleGroup.chest),

  // Legs (before bare "back" so "back squat" → legs).
  // Core-ish "leg raise" is listed under Core below, ahead of bare "leg ".
  ('leg press', ExerciseLibraryMuscleGroup.legs),
  ('leg curl', ExerciseLibraryMuscleGroup.legs),
  ('leg extension', ExerciseLibraryMuscleGroup.legs),
  ('hip thrust', ExerciseLibraryMuscleGroup.legs),
  ('back squat', ExerciseLibraryMuscleGroup.legs),
  ('front squat', ExerciseLibraryMuscleGroup.legs),
  ('affondi', ExerciseLibraryMuscleGroup.legs),
  ('affondo', ExerciseLibraryMuscleGroup.legs),
  ('lunge', ExerciseLibraryMuscleGroup.legs),
  ('squat', ExerciseLibraryMuscleGroup.legs),
  ('hamstring', ExerciseLibraryMuscleGroup.legs),
  ('polpacci', ExerciseLibraryMuscleGroup.legs),
  ('polpaccio', ExerciseLibraryMuscleGroup.legs),
  ('glutei', ExerciseLibraryMuscleGroup.legs),
  ('glute', ExerciseLibraryMuscleGroup.legs),
  ('gambe', ExerciseLibraryMuscleGroup.legs),
  ('quad', ExerciseLibraryMuscleGroup.legs),
  ('calf', ExerciseLibraryMuscleGroup.legs),

  // Back / posterior (stacco = back)
  ('lat pulldown', ExerciseLibraryMuscleGroup.back),
  ('lat machine', ExerciseLibraryMuscleGroup.back),
  ('pull-down', ExerciseLibraryMuscleGroup.back),
  ('pull down', ExerciseLibraryMuscleGroup.back),
  ('pulldown', ExerciseLibraryMuscleGroup.back),
  ('pull-up', ExerciseLibraryMuscleGroup.back),
  ('pull up', ExerciseLibraryMuscleGroup.back),
  ('pullup', ExerciseLibraryMuscleGroup.back),
  ('pullover', ExerciseLibraryMuscleGroup.back),
  ('pull over', ExerciseLibraryMuscleGroup.back),
  ('face pull', ExerciseLibraryMuscleGroup.back),
  ('back extension', ExerciseLibraryMuscleGroup.back),
  ('hyperextension', ExerciseLibraryMuscleGroup.back),
  ('good morning', ExerciseLibraryMuscleGroup.back),
  ('deadlift', ExerciseLibraryMuscleGroup.back),
  ('stacco', ExerciseLibraryMuscleGroup.back),
  ('rematore', ExerciseLibraryMuscleGroup.back),
  ('rowing', ExerciseLibraryMuscleGroup.back),
  ('trazioni', ExerciseLibraryMuscleGroup.back),
  ('trazione', ExerciseLibraryMuscleGroup.back),
  ('schiena', ExerciseLibraryMuscleGroup.back),
  ('row', ExerciseLibraryMuscleGroup.back),
  ('pull', ExerciseLibraryMuscleGroup.back),
  ('back', ExerciseLibraryMuscleGroup.back),

  // Arms
  ('skull crusher', ExerciseLibraryMuscleGroup.arms),
  ('french press', ExerciseLibraryMuscleGroup.arms),
  ('tricipiti', ExerciseLibraryMuscleGroup.arms),
  ('tricipite', ExerciseLibraryMuscleGroup.arms),
  ('triceps', ExerciseLibraryMuscleGroup.arms),
  ('tricip', ExerciseLibraryMuscleGroup.arms),
  ('bicipiti', ExerciseLibraryMuscleGroup.arms),
  ('bicipite', ExerciseLibraryMuscleGroup.arms),
  ('biceps', ExerciseLibraryMuscleGroup.arms),
  ('bicip', ExerciseLibraryMuscleGroup.arms),
  ('pushdown', ExerciseLibraryMuscleGroup.arms),
  ('avambracci', ExerciseLibraryMuscleGroup.arms),
  ('forearm', ExerciseLibraryMuscleGroup.arms),
  ('braccia', ExerciseLibraryMuscleGroup.arms),
  ('curl', ExerciseLibraryMuscleGroup.arms),
  ('arms', ExerciseLibraryMuscleGroup.arms),

  // Core (before bare "leg " so hanging leg raise stays core)
  ('russian twist', ExerciseLibraryMuscleGroup.core),
  ('hanging knee', ExerciseLibraryMuscleGroup.core),
  ('leg raise', ExerciseLibraryMuscleGroup.core),
  ('addominali', ExerciseLibraryMuscleGroup.core),
  ('addome', ExerciseLibraryMuscleGroup.core),
  ('abdominal', ExerciseLibraryMuscleGroup.core),
  ('sit-up', ExerciseLibraryMuscleGroup.core),
  ('sit up', ExerciseLibraryMuscleGroup.core),
  ('situp', ExerciseLibraryMuscleGroup.core),
  ('plank', ExerciseLibraryMuscleGroup.core),
  ('crunch', ExerciseLibraryMuscleGroup.core),
  ('core', ExerciseLibraryMuscleGroup.core),
  ('abs', ExerciseLibraryMuscleGroup.core),

  // Broad "leg " token last among leg-ish matches
  ('leg ', ExerciseLibraryMuscleGroup.legs),
];
