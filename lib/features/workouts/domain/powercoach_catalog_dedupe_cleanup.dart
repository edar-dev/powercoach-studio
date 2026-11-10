import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/settings/settings_prefs_keys.dart';
import '../../exercise_library/data/custom_exercise_item.dart';
import '../../exercise_library/data/custom_exercise_repository.dart';
import 'exercise_picker_index_helpers.dart';

/// One-shot soft-delete of duplicate PowerCoach catalog rows.
///
/// Mirrors picker dedupe keep rules (oldest [createdAt], then smaller id) and
/// only touches `catalogSource == powercoach`. Prefs-gated so it runs once per
/// install / prefs wipe.
///
/// Pass [rawRoots] when the caller already loaded the tree so we avoid a
/// second round-trip before computing delete ids.
Future<int> ensurePowercoachCatalogDedupeCleanup({
  required CustomExerciseRepository exerciseRepo,
  SharedPreferences? prefs,
  List<CustomExerciseItem>? rawRoots,
}) async {
  final resolvedPrefs = prefs ?? await SharedPreferences.getInstance();
  if (resolvedPrefs.getBool(
        SettingsPrefsKeys.exerciseLibraryPowercoachDedupeCleanupV1,
      ) ==
      true) {
    return 0;
  }

  final roots = rawRoots ?? await exerciseRepo.getTree();
  final toDelete = powercoachIdsToSoftDelete(roots);
  for (final id in toDelete) {
    await exerciseRepo.delete(id);
  }

  await resolvedPrefs.setBool(
    SettingsPrefsKeys.exerciseLibraryPowercoachDedupeCleanupV1,
    true,
  );
  return toDelete.length;
}
