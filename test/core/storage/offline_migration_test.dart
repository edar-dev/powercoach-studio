import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:powercoach_studio/core/storage/app_database.dart';
import 'package:powercoach_studio/core/storage/offline_migration.dart';
import 'package:powercoach_studio/core/sync/offline_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_path_provider_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  AppDatabase openTestDatabase(String suffix) {
    PathProviderPlatform.instance = FakePathProviderPlatform(
      prefix: 'powercoach_offline_migration_${suffix}_',
    );
    return AppDatabase();
  }

  test('migrates legacy entities and drops legacy pending ops key from SharedPreferences', () async {
    final now = DateTime(2026, 1, 10, 9);
    final entityJson = jsonEncode([
      {
        'id': 'local_customer_99',
        'type': OfflineEntityType.customer.index,
        'scopeId': '__legacy__',
        'payload': {
          'id': 'local_customer_99',
          'userId': '__legacy__',
          'name': 'Legacy Mario',
        },
        'updatedAt': now.toIso8601String(),
        'deleted': false,
        'localOnly': false,
      },
    ]);
    final pendingJson = jsonEncode([
      {
        'id': 'op-legacy-1',
        'userId': '',
        'entityType': OfflineEntityType.customer.index,
        'entityId': 'local_customer_99',
        'scopeId': '__legacy__',
        'operationType': OfflineOperationType.update.index,
        'path': '/customers/local_customer_99',
        'payload': {'id': 'local_customer_99', 'name': 'Legacy Mario'},
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'retryCount': 0,
        'status': PendingOperationStatus.pending.index,
      },
    ]);

    SharedPreferences.setMockInitialValues(<String, Object>{
      OfflineMigration.legacyEntitiesKey: entityJson,
      OfflineMigration.legacyPendingKey: pendingJson,
    });

    final db = openTestDatabase('migrate');
    final migration = OfflineMigration();

    await migration.migrateFromSharedPreferencesIfNeeded(
      db: db,
      defaultUserId: '__legacy__',
    );

    final entityRows = await db.select(db.localEntities).get();
    expect(entityRows, hasLength(1));
    expect(entityRows.single.id, 'local_customer_99');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(OfflineMigration.migrationPrefsKey), isTrue);
    expect(prefs.getString(OfflineMigration.legacyEntitiesKey), isNull);
    expect(prefs.getString(OfflineMigration.legacyPendingKey), isNull);
  });

  test('skips migration when flag already set', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      OfflineMigration.migrationPrefsKey: true,
      OfflineMigration.legacyEntitiesKey: jsonEncode([
        {
          'id': 'should-not-import',
          'type': OfflineEntityType.customer.index,
          'scopeId': '__legacy__',
          'payload': {'id': 'should-not-import', 'name': 'Skip'},
          'updatedAt': DateTime(2026, 1, 1).toIso8601String(),
          'deleted': false,
          'localOnly': false,
        },
      ]),
    });

    final db = openTestDatabase('skip');
    final migration = OfflineMigration();

    await migration.migrateFromSharedPreferencesIfNeeded(
      db: db,
      defaultUserId: '__legacy__',
    );

    expect(await db.select(db.localEntities).get(), isEmpty);
  });
}
