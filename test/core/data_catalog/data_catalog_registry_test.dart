import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/data_catalog/data_catalog.dart';
import 'package:powercoach_studio/core/sync/offline_models.dart';

void main() {
  group('DataCatalogRegistry', () {
    test('covers every OfflineEntityType value exactly once', () {
      final driftTypes = DataCatalogRegistry.driftEntries
          .map((e) => e.driftType)
          .whereType<OfflineEntityType>()
          .toList();

      expect(
        driftTypes.toSet(),
        equals(OfflineEntityType.values.toSet()),
        reason: 'Registry must include an entry for every OfflineEntityType. '
            'Add a catalog entry when the enum grows.',
      );
      expect(
        driftTypes.length,
        OfflineEntityType.values.length,
        reason: 'Each OfflineEntityType must map to exactly one catalog entry.',
      );
    });

    test('includes expected non-Drift buckets', () {
      final ids = DataCatalogRegistry.entries.map((e) => e.catalogId).toSet();
      expect(
        ids,
        containsAll(<String>[
          DataCatalogRegistry.userProfile,
          DataCatalogRegistry.pdfBrand,
          DataCatalogRegistry.userPreferences,
          DataCatalogRegistry.planData,
          DataCatalogRegistry.workoutDraft,
          DataCatalogRegistry.cloudBackupMeta,
        ]),
      );
    });

    test('customer → workoutPlan / measurement soft refs are declared', () {
      final plan = DataCatalogRegistry.byCatalogId(
        DataCatalogRegistry.workoutPlan,
      )!;
      final meas = DataCatalogRegistry.byCatalogId(
        DataCatalogRegistry.measurement,
      )!;

      expect(
        plan.references.any(
          (r) =>
              r.fieldPath == 'customerId' &&
              r.targetCatalogId == DataCatalogRegistry.customer,
        ),
        isTrue,
      );
      expect(
        meas.references.any(
          (r) =>
              r.fieldPath == 'customerId' &&
              r.targetCatalogId == DataCatalogRegistry.customer,
        ),
        isTrue,
      );
    });

    test('toJsonDocument is stable and serializable', () {
      final doc = DataCatalogRegistry.toJsonDocument();
      expect(doc['schemaVersion'], 1);
      expect(doc['exportFormat'], 'powercoach_data_catalog_v1');
      final entries = doc['entries'] as List<dynamic>;
      expect(entries.length, DataCatalogRegistry.entries.length);
      expect(
        entries.every((e) => (e as Map)['catalogId'] != null),
        isTrue,
      );
    });

    test('catalog ids are unique', () {
      final ids = DataCatalogRegistry.entries.map((e) => e.catalogId).toList();
      expect(ids.toSet().length, ids.length);
    });
  });
}
