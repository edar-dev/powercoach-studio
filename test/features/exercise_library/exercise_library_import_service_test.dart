import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/exercise_library/data/custom_exercise_repository.dart';
import 'package:powercoach_studio/features/exercise_library/domain/exercise_library_import_service.dart';
import 'package:powercoach_studio/features/integrations/hevy/domain/exercise_catalog_source.dart';

class _FakeExerciseRepo extends CustomExerciseRepository {
  _FakeExerciseRepo(this._created);

  final List<Map<String, dynamic>> _created;
  var nextId = 1;

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final id = 'id_${nextId++}';
    _created.add(body);
    return {'id': id, 'name': body['name']};
  }
}

void main() {
  group('ExerciseLibraryImportService', () {
    test('imports parents before children using legacy ids', () async {
      final created = <Map<String, dynamic>>[];
      final service = ExerciseLibraryImportService(
        exerciseRepo: _FakeExerciseRepo(created),
      );

      final count = await service.importItems(
        [
          {
            'id': 'legacy_child',
            'name': 'Child',
            'parentId': 'legacy_parent',
            'isMobility': false,
          },
          {
            'id': 'legacy_parent',
            'name': 'Parent',
            'isMobility': false,
          },
        ],
        fallbackMobilityWhenMissing: false,
        catalogSource: ExerciseCatalogSource.manual,
      );

      expect(count, 2);
      expect(created.first['name'], 'Parent');
      expect(created.last['parentId'], isNotNull);
    });
  });
}
