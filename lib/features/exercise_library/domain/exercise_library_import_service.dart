import '../../integrations/hevy/domain/exercise_catalog_source.dart';
import '../data/custom_exercise_repository.dart';

/// Imports exercise catalog JSON items respecting parent ordering.
class ExerciseLibraryImportService {
  ExerciseLibraryImportService({CustomExerciseRepository? exerciseRepo})
    : _exerciseRepo = exerciseRepo ?? CustomExerciseRepository();

  final CustomExerciseRepository _exerciseRepo;

  Future<int> importItems(
    List<Map<String, dynamic>> items, {
    required bool fallbackMobilityWhenMissing,
    String catalogSource = ExerciseCatalogSource.manual,
  }) async {
    final importedByLegacyId = <String, String>{};
    var importedCount = 0;
    final pending = List<Map<String, dynamic>>.from(items);
    while (pending.isNotEmpty) {
      var createdInPass = 0;
      final unresolvedForNextPass = <Map<String, dynamic>>[];
      for (final item in pending) {
        final name = item['name']?.toString().trim() ?? '';
        if (name.isEmpty) continue;

        final rawParentId = item['parentId']?.toString();
        final hasParent = rawParentId != null && rawParentId.isNotEmpty;
        if (hasParent && !importedByLegacyId.containsKey(rawParentId)) {
          unresolvedForNextPass.add(item);
          continue;
        }

        final parentId = hasParent ? importedByLegacyId[rawParentId] : null;
        final rawMobility = item['isMobility'];
        final itemIsMobility = rawMobility is bool
            ? rawMobility
            : fallbackMobilityWhenMissing;
        final created = await _exerciseRepo.create(<String, dynamic>{
          'name': name,
          'description': item['description']?.toString(),
          if (parentId != null) 'parentId': parentId,
          'sortOrder': item['sortOrder'],
          'isMobility': itemIsMobility,
          'catalogSource': catalogSource,
        });
        final legacyId = item['id']?.toString();
        if (legacyId != null && legacyId.isNotEmpty) {
          importedByLegacyId[legacyId] = created['id']?.toString() ?? '';
        }
        importedCount++;
        createdInPass++;
      }

      if (createdInPass == 0) {
        for (final item in unresolvedForNextPass) {
          final name = item['name']?.toString().trim() ?? '';
          if (name.isEmpty) continue;
          final rawMobility = item['isMobility'];
          final itemIsMobility = rawMobility is bool
              ? rawMobility
              : fallbackMobilityWhenMissing;
          final created = await _exerciseRepo.create(<String, dynamic>{
            'name': name,
            'description': item['description']?.toString(),
            'sortOrder': item['sortOrder'],
            'isMobility': itemIsMobility,
            'catalogSource': catalogSource,
          });
          final legacyId = item['id']?.toString();
          if (legacyId != null && legacyId.isNotEmpty) {
            importedByLegacyId[legacyId] = created['id']?.toString() ?? '';
          }
          importedCount++;
        }
        break;
      }

      pending
        ..clear()
        ..addAll(unresolvedForNextPass);
    }
    return importedCount;
  }
}
