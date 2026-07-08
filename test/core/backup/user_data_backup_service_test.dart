import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:powercoach_studio/core/backup/backup_entity_groups.dart';
import 'package:powercoach_studio/core/backup/user_data_backup_codec.dart';
import 'package:powercoach_studio/core/backup/user_data_backup_service.dart';
import 'package:powercoach_studio/core/storage/offline_local_store.dart';
import 'package:powercoach_studio/core/sync/offline_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_path_provider_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    PathProviderPlatform.instance = FakePathProviderPlatform(
      prefix: 'powercoach_backup_service_test_',
    );
  });

  const uid = '__legacy__';

  setUp(() async {
    await OfflineLocalStore.instance.clear();
  });

  ParsedUserBackup backupWith({
    required Map<String, dynamic> customer,
    required Map<String, dynamic> exercise,
  }) {
    return ParsedUserBackup(
      entities: [customer, exercise],
      pendingOperations: const [],
      syncMeta: const [],
      profileJson: null,
      notificationsEnabled: true,
      reminders: const [],
    );
  }

  Map<String, dynamic> customerEntity({
    required String id,
    required String name,
    required DateTime updatedAt,
  }) {
    return <String, dynamic>{
      'id': id,
      'type': OfflineEntityType.customer.name,
      'scopeId': id,
      'payload': <String, dynamic>{'id': id, 'name': name, 'userId': uid},
      'updatedAt': updatedAt.toIso8601String(),
      'deleted': false,
      'localOnly': false,
    };
  }

  Map<String, dynamic> customExerciseEntity({
    required String id,
    required DateTime updatedAt,
  }) {
    return <String, dynamic>{
      'id': id,
      'type': OfflineEntityType.customExercise.name,
      'scopeId': 'global',
      'payload': <String, dynamic>{'id': id, 'name': 'Curl', 'userId': uid},
      'updatedAt': updatedAt.toIso8601String(),
      'deleted': false,
      'localOnly': false,
    };
  }

  test('mergeRestore with customers group only updates customers', () async {
    final store = OfflineLocalStore.instance;
    await store.upsertEntityForUser(
      uid,
      customerEntity(
        id: 'local-c',
        name: 'Local',
        updatedAt: DateTime.utc(2026, 1, 1),
      ),
    );
    await store.upsertEntityForUser(
      uid,
      customExerciseEntity(
        id: 'local-e',
        updatedAt: DateTime.utc(2026, 1, 1),
      ),
    );

    final parsed = backupWith(
      customer: customerEntity(
        id: 'import-c',
        name: 'Imported',
        updatedAt: DateTime.utc(2026, 6, 1),
      ),
      exercise: customExerciseEntity(
        id: 'import-e',
        updatedAt: DateTime.utc(2026, 6, 1),
      ),
    );

    await UserDataBackupService.instance.mergeRestore(
      parsed,
      uid,
      groups: {BackupEntityGroup.customers},
    );

    final customers = await store.readEntities(OfflineEntityType.customer);
    final exercises = await store.readEntities(OfflineEntityType.customExercise);

    expect(customers.map((e) => e.id), contains('import-c'));
    expect(exercises.map((e) => e.id), contains('local-e'));
    expect(exercises.map((e) => e.id), isNot(contains('import-e')));
  });

  test('restoreParsed partial replace swaps only selected entity types', () async {
    final store = OfflineLocalStore.instance;
    await store.upsertEntityForUser(
      uid,
      customerEntity(
        id: 'keep-c',
        name: 'Keep',
        updatedAt: DateTime.utc(2026, 1, 1),
      ),
    );
    await store.upsertEntityForUser(
      uid,
      customExerciseEntity(
        id: 'old-e',
        updatedAt: DateTime.utc(2026, 1, 1),
      ),
    );

    final parsed = backupWith(
      customer: customerEntity(
        id: 'new-c',
        name: 'New',
        updatedAt: DateTime.utc(2026, 6, 1),
      ),
      exercise: customExerciseEntity(
        id: 'new-e',
        updatedAt: DateTime.utc(2026, 6, 1),
      ),
    );

    await UserDataBackupService.instance.restoreParsed(
      parsed,
      uid,
      groups: {BackupEntityGroup.exerciseLibrary},
    );

    final customers = await store.readEntities(OfflineEntityType.customer);
    final exercises = await store.readEntities(OfflineEntityType.customExercise);

    expect(customers.map((e) => e.id), contains('keep-c'));
    expect(exercises.map((e) => e.id), contains('new-e'));
    expect(exercises.map((e) => e.id), isNot(contains('old-e')));
  });
}
