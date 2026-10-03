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

    test('coach entity types use cloud SoT + Drift cache loci', () {
      for (final type in OfflineEntityType.values) {
        final entry = DataCatalogRegistry.byDriftType(type)!;
        expect(
          entry.locus,
          DataStorageLocus.supabaseCoachEntities,
          reason: '${type.name} SoT locus',
        );
        expect(
          entry.cacheLocus,
          DataStorageLocus.driftLocalEntities,
          reason: '${type.name} cache locus',
        );
        expect(entry.remoteTable, CoachEntityRowContract.remoteTable);
        expect(
          entry.remoteRowFields,
          CoachEntityRowContract.remoteRowFields,
        );
        expect(entry.softDelete, isTrue);
        expect(
          entry.softDeleteColumn,
          CoachEntityRowContract.softDeleteColumn,
        );
        expect(entry.rlsNote, CoachEntityRowContract.rlsNote);
        expect(entry.softFkNote, isNotNull);
        expect(entry.includedInBackup, isTrue);
        expect(entry.backupKey, 'entities');
      }
    });

    test('coach_entities type CHECK matches OfflineEntityType names', () {
      expect(
        CoachEntityRowContract.typeCheckValues.toSet(),
        equals(OfflineEntityType.values.map((e) => e.name).toSet()),
      );
      expect(
        CoachEntityRowContract.typeCheckValues,
        isNot(contains('exerciseRecord')),
        reason: 'Legacy exerciseRecord must stay excluded from cloud CHECK.',
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

    test('prefs buckets stay SharedPreferences (not coach_entities)', () {
      for (final id in <String>[
        DataCatalogRegistry.userProfile,
        DataCatalogRegistry.pdfBrand,
        DataCatalogRegistry.userPreferences,
        DataCatalogRegistry.workoutDraft,
        DataCatalogRegistry.cloudBackupMeta,
      ]) {
        final entry = DataCatalogRegistry.byCatalogId(id)!;
        expect(entry.locus, DataStorageLocus.sharedPreferences);
        expect(entry.cacheLocus, isNull);
        expect(entry.remoteTable, isNull);
        expect(entry.softDelete, isFalse);
      }
    });

    test('scopeIdPattern matches entity ownership rules', () {
      expect(
        DataCatalogRegistry.byDriftType(OfflineEntityType.customer)!
            .scopeIdPattern,
        'userId',
      );
      expect(
        DataCatalogRegistry.byDriftType(OfflineEntityType.workoutPlan)!
            .scopeIdPattern,
        'customerId',
      );
      expect(
        DataCatalogRegistry.byDriftType(OfflineEntityType.measurement)!
            .scopeIdPattern,
        'customerId',
      );
      expect(
        DataCatalogRegistry.byDriftType(OfflineEntityType.customerNote)!
            .scopeIdPattern,
        'customerId',
      );
      expect(
        DataCatalogRegistry.byDriftType(OfflineEntityType.customExercise)!
            .scopeIdPattern,
        'library',
      );
    });

    test('customer soft refs and customExercise parentId are declared', () {
      final plan = DataCatalogRegistry.byCatalogId(
        DataCatalogRegistry.workoutPlan,
      )!;
      final meas = DataCatalogRegistry.byCatalogId(
        DataCatalogRegistry.measurement,
      )!;
      final note = DataCatalogRegistry.byCatalogId(
        DataCatalogRegistry.customerNote,
      )!;
      final exercise = DataCatalogRegistry.byCatalogId(
        DataCatalogRegistry.customExercise,
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
      expect(
        note.references.any(
          (r) =>
              r.fieldPath == 'customerId' &&
              r.targetCatalogId == DataCatalogRegistry.customer,
        ),
        isTrue,
      );
      expect(
        exercise.references.any(
          (r) =>
              r.fieldPath == 'parentId' &&
              r.targetCatalogId == DataCatalogRegistry.customExercise,
        ),
        isTrue,
      );
    });

    test('toJsonDocument is stable and serializable', () {
      final doc = DataCatalogRegistry.toJsonDocument();
      expect(doc['schemaVersion'], 2);
      expect(doc['exportFormat'], 'powercoach_data_catalog_v2');
      final coach = doc['coachEntities'] as Map<String, dynamic>;
      expect(coach['remoteTable'], 'public.coach_entities');
      expect(
        coach['remoteRowFields'],
        containsAll(<String>[
          'user_id',
          'type',
          'id',
          'scope_id',
          'payload',
          'updated_at',
          'deleted',
        ]),
      );
      final entries = doc['entries'] as List<dynamic>;
      expect(entries.length, DataCatalogRegistry.entries.length);
      expect(
        entries.every((e) => (e as Map)['catalogId'] != null),
        isTrue,
      );
      final cloudEntries = entries
          .cast<Map<String, dynamic>>()
          .where((e) => e['locus'] == 'supabaseCoachEntities');
      expect(cloudEntries.length, OfflineEntityType.values.length);
      expect(
        cloudEntries.every((e) => e['cacheLocus'] == 'driftLocalEntities'),
        isTrue,
      );
    });

    test('catalog ids are unique', () {
      final ids = DataCatalogRegistry.entries.map((e) => e.catalogId).toList();
      expect(ids.toSet().length, ids.length);
    });
  });
}
