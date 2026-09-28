import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/settings/settings_prefs_keys.dart';
import '../data/custom_exercise_repository.dart';
import '../data/default_exercise_catalog.dart';
import 'exercise_catalog_source.dart';
import 'exercise_library_import_service.dart';

/// Ensures the built-in PowerCoach exercise catalog exists locally.
///
/// Seeds only when there are no rows with
/// [ExerciseCatalogSource.powercoach] yet (first use / empty library).
/// Manual re-import from the library UI still replaces that catalog.
///
/// After an intentional "clear library", auto-seed is suppressed until the
/// user imports the default catalog again (see
/// [SettingsPrefsKeys.exerciseLibrarySkipAutoSeed]).
class DefaultExerciseCatalogSeeder {
  DefaultExerciseCatalogSeeder({
    CustomExerciseRepository? exerciseRepo,
    ExerciseLibraryImportService? importService,
  })  : _exerciseRepo = exerciseRepo ?? CustomExerciseRepository(),
        _importService = importService ?? ExerciseLibraryImportService();

  final CustomExerciseRepository _exerciseRepo;
  final ExerciseLibraryImportService _importService;

  /// Mark that the coach intentionally emptied the library.
  static Future<void> markAutoSeedSuppressed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SettingsPrefsKeys.exerciseLibrarySkipAutoSeed, true);
  }

  /// Allow auto-seed again (e.g. after manual default-catalog import).
  static Future<void> clearAutoSeedSuppression() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SettingsPrefsKeys.exerciseLibrarySkipAutoSeed);
  }

  /// Returns how many nodes were imported (`0` if already seeded or suppressed).
  Future<int> ensureSeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(SettingsPrefsKeys.exerciseLibrarySkipAutoSeed) == true) {
      return 0;
    }

    final existing = await _exerciseRepo.listFlat(
      catalogSource: ExerciseCatalogSource.powercoach,
    );
    if (existing.isNotEmpty) return 0;

    return _importService.importItems(
      buildDefaultExerciseCatalogJson(),
      fallbackMobilityWhenMissing: false,
      catalogSource: ExerciseCatalogSource.powercoach,
    );
  }
}
