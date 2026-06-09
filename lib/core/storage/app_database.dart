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

/// Outbox of mutations to replay when online.
@DataClassName('PendingOpRow')
class PendingOperations extends Table {
  TextColumn get opUuid => text()();
  TextColumn get userId => text()();
  IntColumn get entityType => integer()();
  TextColumn get entityId => text()();
  TextColumn get scopeId => text()();
  IntColumn get operationType => integer()();
  TextColumn get path => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get baseUpdatedAt => dateTime().nullable()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  IntColumn get status => integer()();
  TextColumn get conflictRemoteJson => text().nullable()();
  TextColumn get errorMessage => text().nullable()();

  @override
  Set<Column> get primaryKey => {opUuid};
}

/// Optional key/value per user (last sync markers, cursors).
class SyncMetaEntries extends Table {
  TextColumn get userId => text()();
  TextColumn get metaKey => text()();
  TextColumn get metaValue => text()();

  @override
  Set<Column> get primaryKey => {userId, metaKey};
}

@DriftDatabase(tables: [LocalEntities, PendingOperations, SyncMetaEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? createAppDatabaseExecutor());

  @override
  int get schemaVersion => 1;
}
