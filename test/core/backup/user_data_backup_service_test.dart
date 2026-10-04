import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:powercoach_studio/core/backup/user_data_backup_codec.dart';
import 'package:powercoach_studio/core/backup/user_data_backup_service.dart';
import 'package:powercoach_studio/core/settings/settings_prefs_keys.dart';
import 'package:powercoach_studio/core/storage/offline_local_store.dart';
import 'package:powercoach_studio/core/sync/offline_models.dart';
import 'package:powercoach_studio/features/exercise_library/data/pinned_exercises_store.dart';
import 'package:powercoach_studio/features/exercise_library/data/recent_exercises_store.dart';
import 'package:powercoach_studio/features/settings/data/user_preferences_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_path_provider_platform.dart';
import '../../support/fake_macos_notifications_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    PathProviderPlatform.instance = FakePathProviderPlatform(
      prefix: 'powercoach_backup_service_test_',
    );
    registerFakeMacOSNotificationsPlatform();
  });

  const uid = '__legacy__';

  /// Drift-only restore path for legacy envelope tests (no Supabase).
  late UserDataBackupService backup;

  setUp(() async {
    await OfflineLocalStore.instance.clear();
    backup = UserDataBackupService();
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
      preferences: const BackupPreferences(notificationsEnabled: true),
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

  test('mergeRestore updates all entity types by newest updatedAt', () async {
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

    await backup.mergeRestore(parsed, uid);

    final customers = await store.readEntities(OfflineEntityType.customer);
    final exercises = await store.readEntities(OfflineEntityType.customExercise);

    expect(customers.map((e) => e.id), contains('import-c'));
    expect(customers.map((e) => e.id), contains('local-c'));
    expect(exercises.map((e) => e.id), contains('local-e'));
    expect(exercises.map((e) => e.id), contains('import-e'));
  });

  test('restoreParsed full replace swaps all entity types', () async {
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

    await backup.restoreParsed(parsed, uid);

    final customers = await store.readEntities(OfflineEntityType.customer);
    final exercises = await store.readEntities(OfflineEntityType.customExercise);

    expect(customers.map((e) => e.id), contains('new-c'));
    expect(customers.map((e) => e.id), isNot(contains('keep-c')));
    expect(exercises.map((e) => e.id), contains('new-e'));
    expect(exercises.map((e) => e.id), isNot(contains('old-e')));
  });

  test('restoreParsed skips legacy exerciseRecord rows without crash', () async {
    final parsed = ParsedUserBackup(
      entities: [
        customerEntity(
          id: 'c1',
          name: 'Safe',
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
        <String, dynamic>{
          'id': 'legacy-record',
          'type': 'exerciseRecord',
          'scopeId': 'c1',
          'payload': <String, dynamic>{'id': 'legacy-record', 'value': 100},
          'updatedAt': DateTime.utc(2026, 1, 1).toIso8601String(),
          'deleted': false,
          'localOnly': false,
        },
      ],
      pendingOperations: const [],
      syncMeta: const [],
      profileJson: null,
      preferences: const BackupPreferences(notificationsEnabled: true),
      reminders: const [],
    );

    await backup.restoreParsed(parsed, uid);

    final customers = await OfflineLocalStore.instance.readEntities(
      OfflineEntityType.customer,
    );
    expect(customers.map((e) => e.id), contains('c1'));
    expect(customers.map((e) => e.id), isNot(contains('legacy-record')));
  });

  test('restoreParsed always restores all entity types (restore-all)', () async {
    final store = OfflineLocalStore.instance;
    await store.upsertEntityForUser(
      uid,
      customerEntity(
        id: 'old-c',
        name: 'Old',
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

    final planEntity = <String, dynamic>{
      'id': 'plan-1',
      'type': OfflineEntityType.workoutPlan.name,
      'scopeId': 'import-c',
      'payload': <String, dynamic>{
        'id': 'plan-1',
        'customerId': 'import-c',
        'name': 'Imported plan',
        'userId': uid,
      },
      'updatedAt': DateTime.utc(2026, 6, 1).toIso8601String(),
      'deleted': false,
      'localOnly': false,
    };

    final parsed = ParsedUserBackup(
      entities: [
        customerEntity(
          id: 'import-c',
          name: 'Imported',
          updatedAt: DateTime.utc(2026, 6, 1),
        ),
        customExerciseEntity(
          id: 'import-e',
          updatedAt: DateTime.utc(2026, 6, 1),
        ),
        planEntity,
      ],
      pendingOperations: const [],
      syncMeta: const [],
      profileJson: null,
      preferences: const BackupPreferences(notificationsEnabled: true),
      reminders: const [],
    );

    // No entity-group filter: replace swaps every known type in one call.
    await backup.restoreParsed(parsed, uid);

    final customers = await store.readEntities(OfflineEntityType.customer);
    final exercises = await store.readEntities(OfflineEntityType.customExercise);
    final plans = await store.readEntities(OfflineEntityType.workoutPlan);

    expect(customers.map((e) => e.id), contains('import-c'));
    expect(customers.map((e) => e.id), isNot(contains('old-c')));
    expect(exercises.map((e) => e.id), contains('import-e'));
    expect(exercises.map((e) => e.id), isNot(contains('old-e')));
    expect(plans.map((e) => e.id), contains('plan-1'));
  });

  test('mergeRestore always merges all known types without group filter', () async {
    final store = OfflineLocalStore.instance;
    await store.upsertEntityForUser(
      uid,
      customerEntity(
        id: 'keep-c',
        name: 'Keep',
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

    await backup.mergeRestore(parsed, uid);

    final customers = await store.readEntities(OfflineEntityType.customer);
    final exercises = await store.readEntities(OfflineEntityType.customExercise);
    expect(customers.map((e) => e.id), containsAll(['keep-c', 'new-c']));
    expect(exercises.map((e) => e.id), contains('new-e'));
  });

  test('buildExportMap omits pendingOperations and syncMeta and includes prefs', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'settings_notifications_enabled': false,
      'app_locale_code': 'en',
      'settings_calendar_reminders_enabled': true,
      'settings_calendar_reminder_lead_hours': 6,
      'workout_builder_include_mobility_default_v1': false,
    });
    final map = await backup.buildExportMap(uid);
    expect(map.containsKey('pendingOperations'), isFalse);
    expect(map.containsKey('syncMeta'), isFalse);
    final prefs = map['preferences'] as Map<String, dynamic>;
    expect(prefs['settings_notifications_enabled'], isFalse);
    expect(prefs['app_locale_code'], 'en');
    expect(prefs['settings_calendar_reminders_enabled'], isTrue);
    expect(prefs['settings_calendar_reminder_lead_hours'], 6);
    expect(prefs['workout_builder_include_mobility_default_v1'], isFalse);
  });

  test('restoreParsed ignores legacy pendingOperations in envelope', () async {
    registerFakeMacOSNotificationsPlatform();
    final parsed = ParsedUserBackup(
      entities: [
        customerEntity(
          id: 'c1',
          name: 'Legacy-safe',
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      ],
      pendingOperations: [
        <String, dynamic>{
          'id': 'should-ignore',
          'userId': uid,
          'entityType': OfflineEntityType.customer.name,
          'entityId': 'c1',
          'scopeId': 'c1',
          'operationType': 'update',
          'path': '/x',
          'payload': <String, dynamic>{},
          'createdAt': DateTime.utc(2026, 1, 1).toIso8601String(),
          'updatedAt': DateTime.utc(2026, 1, 1).toIso8601String(),
          'status': 0,
        },
      ],
      syncMeta: [
        <String, dynamic>{'metaKey': 'k', 'metaValue': 'v'},
      ],
      profileJson: null,
      preferences: const BackupPreferences(notificationsEnabled: true),
      reminders: const [],
    );

    await backup.restoreParsed(parsed, uid);

    final customers = await OfflineLocalStore.instance.readEntities(
      OfflineEntityType.customer,
    );
    expect(customers.map((e) => e.id), contains('c1'));
  });

  test('export/import round-trips pinned and recent exercise ids', () async {
    registerFakeMacOSNotificationsPlatform();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PinnedExercisesStore.instance.replaceAll({'ex-a', 'ex-b'});
    await RecentExercisesStore.instance.replaceAll(['ex-b', 'ex-c']);

    final map = await backup.buildExportMap(uid);
    final prefs = map['preferences'] as Map<String, dynamic>;
    expect(prefs[SettingsPrefsKeys.pinnedExerciseIdsJson], isA<List>());
    expect(prefs[SettingsPrefsKeys.recentExerciseIdsJson], isA<List>());
    expect(
      (prefs[SettingsPrefsKeys.pinnedExerciseIdsJson] as List).toSet(),
      {'ex-a', 'ex-b'},
    );
    expect(prefs[SettingsPrefsKeys.recentExerciseIdsJson], ['ex-b', 'ex-c']);

    await PinnedExercisesStore.instance.replaceAll({});
    await RecentExercisesStore.instance.replaceAll([]);

    await UserPreferencesRepository.instance.applyFromBackupMap(prefs);
    expect(await PinnedExercisesStore.instance.getPinnedIds(), {'ex-a', 'ex-b'});
    expect(await RecentExercisesStore.instance.getRecentIds(), ['ex-b', 'ex-c']);
  });
}
