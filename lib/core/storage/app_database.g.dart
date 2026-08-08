// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalEntitiesTable extends LocalEntities
    with TableInfo<$LocalEntitiesTable, LocalEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalEntitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeIdMeta = const VerificationMeta(
    'scopeId',
  );
  @override
  late final GeneratedColumn<String> scopeId = GeneratedColumn<String>(
    'scope_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _localOnlyMeta = const VerificationMeta(
    'localOnly',
  );
  @override
  late final GeneratedColumn<bool> localOnly = GeneratedColumn<bool>(
    'local_only',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("local_only" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    type,
    id,
    scopeId,
    payloadJson,
    updatedAt,
    deleted,
    localOnly,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_entities';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('scope_id')) {
      context.handle(
        _scopeIdMeta,
        scopeId.isAcceptableOrUnknown(data['scope_id']!, _scopeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('local_only')) {
      context.handle(
        _localOnlyMeta,
        localOnly.isAcceptableOrUnknown(data['local_only']!, _localOnlyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, type, id};
  @override
  LocalEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalEntity(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      scopeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      localOnly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}local_only'],
      )!,
    );
  }

  @override
  $LocalEntitiesTable createAlias(String alias) {
    return $LocalEntitiesTable(attachedDatabase, alias);
  }
}

class LocalEntity extends DataClass implements Insertable<LocalEntity> {
  final String userId;
  final int type;
  final String id;
  final String scopeId;
  final String payloadJson;
  final DateTime updatedAt;
  final bool deleted;
  final bool localOnly;
  const LocalEntity({
    required this.userId,
    required this.type,
    required this.id,
    required this.scopeId,
    required this.payloadJson,
    required this.updatedAt,
    required this.deleted,
    required this.localOnly,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['type'] = Variable<int>(type);
    map['id'] = Variable<String>(id);
    map['scope_id'] = Variable<String>(scopeId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['deleted'] = Variable<bool>(deleted);
    map['local_only'] = Variable<bool>(localOnly);
    return map;
  }

  LocalEntitiesCompanion toCompanion(bool nullToAbsent) {
    return LocalEntitiesCompanion(
      userId: Value(userId),
      type: Value(type),
      id: Value(id),
      scopeId: Value(scopeId),
      payloadJson: Value(payloadJson),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      localOnly: Value(localOnly),
    );
  }

  factory LocalEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalEntity(
      userId: serializer.fromJson<String>(json['userId']),
      type: serializer.fromJson<int>(json['type']),
      id: serializer.fromJson<String>(json['id']),
      scopeId: serializer.fromJson<String>(json['scopeId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      localOnly: serializer.fromJson<bool>(json['localOnly']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'type': serializer.toJson<int>(type),
      'id': serializer.toJson<String>(id),
      'scopeId': serializer.toJson<String>(scopeId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'localOnly': serializer.toJson<bool>(localOnly),
    };
  }

  LocalEntity copyWith({
    String? userId,
    int? type,
    String? id,
    String? scopeId,
    String? payloadJson,
    DateTime? updatedAt,
    bool? deleted,
    bool? localOnly,
  }) => LocalEntity(
    userId: userId ?? this.userId,
    type: type ?? this.type,
    id: id ?? this.id,
    scopeId: scopeId ?? this.scopeId,
    payloadJson: payloadJson ?? this.payloadJson,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    localOnly: localOnly ?? this.localOnly,
  );
  LocalEntity copyWithCompanion(LocalEntitiesCompanion data) {
    return LocalEntity(
      userId: data.userId.present ? data.userId.value : this.userId,
      type: data.type.present ? data.type.value : this.type,
      id: data.id.present ? data.id.value : this.id,
      scopeId: data.scopeId.present ? data.scopeId.value : this.scopeId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      localOnly: data.localOnly.present ? data.localOnly.value : this.localOnly,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalEntity(')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('id: $id, ')
          ..write('scopeId: $scopeId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('localOnly: $localOnly')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    type,
    id,
    scopeId,
    payloadJson,
    updatedAt,
    deleted,
    localOnly,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalEntity &&
          other.userId == this.userId &&
          other.type == this.type &&
          other.id == this.id &&
          other.scopeId == this.scopeId &&
          other.payloadJson == this.payloadJson &&
          other.updatedAt == this.updatedAt &&
          other.deleted == this.deleted &&
          other.localOnly == this.localOnly);
}

class LocalEntitiesCompanion extends UpdateCompanion<LocalEntity> {
  final Value<String> userId;
  final Value<int> type;
  final Value<String> id;
  final Value<String> scopeId;
  final Value<String> payloadJson;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<bool> localOnly;
  final Value<int> rowid;
  const LocalEntitiesCompanion({
    this.userId = const Value.absent(),
    this.type = const Value.absent(),
    this.id = const Value.absent(),
    this.scopeId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.localOnly = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalEntitiesCompanion.insert({
    required String userId,
    required int type,
    required String id,
    required String scopeId,
    required String payloadJson,
    required DateTime updatedAt,
    this.deleted = const Value.absent(),
    this.localOnly = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       type = Value(type),
       id = Value(id),
       scopeId = Value(scopeId),
       payloadJson = Value(payloadJson),
       updatedAt = Value(updatedAt);
  static Insertable<LocalEntity> custom({
    Expression<String>? userId,
    Expression<int>? type,
    Expression<String>? id,
    Expression<String>? scopeId,
    Expression<String>? payloadJson,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<bool>? localOnly,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (type != null) 'type': type,
      if (id != null) 'id': id,
      if (scopeId != null) 'scope_id': scopeId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (localOnly != null) 'local_only': localOnly,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalEntitiesCompanion copyWith({
    Value<String>? userId,
    Value<int>? type,
    Value<String>? id,
    Value<String>? scopeId,
    Value<String>? payloadJson,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<bool>? localOnly,
    Value<int>? rowid,
  }) {
    return LocalEntitiesCompanion(
      userId: userId ?? this.userId,
      type: type ?? this.type,
      id: id ?? this.id,
      scopeId: scopeId ?? this.scopeId,
      payloadJson: payloadJson ?? this.payloadJson,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      localOnly: localOnly ?? this.localOnly,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (scopeId.present) {
      map['scope_id'] = Variable<String>(scopeId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (localOnly.present) {
      map['local_only'] = Variable<bool>(localOnly.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalEntitiesCompanion(')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('id: $id, ')
          ..write('scopeId: $scopeId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('localOnly: $localOnly, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalEntitiesTable localEntities = $LocalEntitiesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [localEntities];
}

typedef $$LocalEntitiesTableCreateCompanionBuilder =
    LocalEntitiesCompanion Function({
      required String userId,
      required int type,
      required String id,
      required String scopeId,
      required String payloadJson,
      required DateTime updatedAt,
      Value<bool> deleted,
      Value<bool> localOnly,
      Value<int> rowid,
    });
typedef $$LocalEntitiesTableUpdateCompanionBuilder =
    LocalEntitiesCompanion Function({
      Value<String> userId,
      Value<int> type,
      Value<String> id,
      Value<String> scopeId,
      Value<String> payloadJson,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<bool> localOnly,
      Value<int> rowid,
    });

class $$LocalEntitiesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalEntitiesTable> {
  $$LocalEntitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopeId => $composableBuilder(
    column: $table.scopeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get localOnly => $composableBuilder(
    column: $table.localOnly,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalEntitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalEntitiesTable> {
  $$LocalEntitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopeId => $composableBuilder(
    column: $table.scopeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get localOnly => $composableBuilder(
    column: $table.localOnly,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalEntitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalEntitiesTable> {
  $$LocalEntitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scopeId =>
      $composableBuilder(column: $table.scopeId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<bool> get localOnly =>
      $composableBuilder(column: $table.localOnly, builder: (column) => column);
}

class $$LocalEntitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalEntitiesTable,
          LocalEntity,
          $$LocalEntitiesTableFilterComposer,
          $$LocalEntitiesTableOrderingComposer,
          $$LocalEntitiesTableAnnotationComposer,
          $$LocalEntitiesTableCreateCompanionBuilder,
          $$LocalEntitiesTableUpdateCompanionBuilder,
          (
            LocalEntity,
            BaseReferences<_$AppDatabase, $LocalEntitiesTable, LocalEntity>,
          ),
          LocalEntity,
          PrefetchHooks Function()
        > {
  $$LocalEntitiesTableTableManager(_$AppDatabase db, $LocalEntitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalEntitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalEntitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalEntitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> scopeId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<bool> localOnly = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalEntitiesCompanion(
                userId: userId,
                type: type,
                id: id,
                scopeId: scopeId,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                deleted: deleted,
                localOnly: localOnly,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required int type,
                required String id,
                required String scopeId,
                required String payloadJson,
                required DateTime updatedAt,
                Value<bool> deleted = const Value.absent(),
                Value<bool> localOnly = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalEntitiesCompanion.insert(
                userId: userId,
                type: type,
                id: id,
                scopeId: scopeId,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                deleted: deleted,
                localOnly: localOnly,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalEntitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalEntitiesTable,
      LocalEntity,
      $$LocalEntitiesTableFilterComposer,
      $$LocalEntitiesTableOrderingComposer,
      $$LocalEntitiesTableAnnotationComposer,
      $$LocalEntitiesTableCreateCompanionBuilder,
      $$LocalEntitiesTableUpdateCompanionBuilder,
      (
        LocalEntity,
        BaseReferences<_$AppDatabase, $LocalEntitiesTable, LocalEntity>,
      ),
      LocalEntity,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalEntitiesTableTableManager get localEntities =>
      $$LocalEntitiesTableTableManager(_db, _db.localEntities);
}
