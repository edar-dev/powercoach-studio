import '../data/custom_exercise_repository.dart';
import '../data/default_exercise_catalog.dart';
import 'exercise_catalog_source.dart';
import 'exercise_library_import_service.dart';

/// Ensures the built-in PowerCoach exercise catalog exists locally.
///
/// Seeds only when there are no rows with
/// [ExerciseCatalogSource.powercoach] yet (first use / empty library).
/// Manual re-import from the library UI still replaces that catalog.
class DefaultExerciseCatalogSeeder {
  DefaultExerciseCatalogSeeder({
    CustomExerciseRepository? exerciseRepo,
    ExerciseLibraryImportService? importService,
  })  : _exerciseRepo = exerciseRepo ?? CustomExerciseRepository(),
        _importService = importService ?? ExerciseLibraryImportService();

  final CustomExerciseRepository _exerciseRepo;
  final ExerciseLibraryImportService _importService;

  /// Returns how many nodes were imported (`0` if already seeded).
  Future<int> ensureSeeded() async {
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
