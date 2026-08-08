import 'package:drift/drift.dart';

import 'app_database_connection.dart';

part 'app_database.g.dart';

/// Cached entities for offline-first (customers, plans, measurements, records, …).
class LocalEntities extends Table {
  TextColumn get userId => text()();
  IntColumn get type => integer()();
  TextColumn get id => text()();
  TextColumn get scopeId => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  BoolColumn get localOnly => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {userId, type, id};
}

@DriftDatabase(tables: [LocalEntities])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? createAppDatabaseExecutor());

  @override
  int get schemaVersion => 2;

  /// v1 shipped a `PendingOperations` outbox and `SyncMetaEntries` table for
  /// remote sync replay. The app is local-first only (see `docs/sync-strategy.md`);
  /// those tables were never read after Wave A and are dropped here.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await customStatement('DROP TABLE IF EXISTS pending_operations;');
            await customStatement('DROP TABLE IF EXISTS sync_meta_entries;');
          }
        },
      );
}
