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

class $PendingOperationsTable extends PendingOperations
    with TableInfo<$PendingOperationsTable, PendingOpRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingOperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opUuidMeta = const VerificationMeta('opUuid');
  @override
  late final GeneratedColumn<String> opUuid = GeneratedColumn<String>(
    'op_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<int> entityType = GeneratedColumn<int>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
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
  static const VerificationMeta _operationTypeMeta = const VerificationMeta(
    'operationType',
  );
  @override
  late final GeneratedColumn<int> operationType = GeneratedColumn<int>(
    'operation_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
  static const VerificationMeta _baseUpdatedAtMeta = const VerificationMeta(
    'baseUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> baseUpdatedAt =
      GeneratedColumn<DateTime>(
        'base_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conflictRemoteJsonMeta =
      const VerificationMeta('conflictRemoteJson');
  @override
  late final GeneratedColumn<String> conflictRemoteJson =
      GeneratedColumn<String>(
        'conflict_remote_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    opUuid,
    userId,
    entityType,
    entityId,
    scopeId,
    operationType,
    path,
    payloadJson,
    createdAt,
    updatedAt,
    baseUpdatedAt,
    retryCount,
    status,
    conflictRemoteJson,
    errorMessage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingOpRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_uuid')) {
      context.handle(
        _opUuidMeta,
        opUuid.isAcceptableOrUnknown(data['op_uuid']!, _opUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_opUuidMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('scope_id')) {
      context.handle(
        _scopeIdMeta,
        scopeId.isAcceptableOrUnknown(data['scope_id']!, _scopeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeIdMeta);
    }
    if (data.containsKey('operation_type')) {
      context.handle(
        _operationTypeMeta,
        operationType.isAcceptableOrUnknown(
          data['operation_type']!,
          _operationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
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
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('base_updated_at')) {
      context.handle(
        _baseUpdatedAtMeta,
        baseUpdatedAt.isAcceptableOrUnknown(
          data['base_updated_at']!,
          _baseUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('conflict_remote_json')) {
      context.handle(
        _conflictRemoteJsonMeta,
        conflictRemoteJson.isAcceptableOrUnknown(
          data['conflict_remote_json']!,
          _conflictRemoteJsonMeta,
        ),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {opUuid};
  @override
  PendingOpRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingOpRow(
      opUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_uuid'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      scopeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_id'],
      )!,
      operationType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}operation_type'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      baseUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}base_updated_at'],
      ),
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      conflictRemoteJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conflict_remote_json'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
    );
  }

  @override
  $PendingOperationsTable createAlias(String alias) {
    return $PendingOperationsTable(attachedDatabase, alias);
  }
}

class PendingOpRow extends DataClass implements Insertable<PendingOpRow> {
  final String opUuid;
  final String userId;
  final int entityType;
  final String entityId;
  final String scopeId;
  final int operationType;
  final String path;
  final String payloadJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? baseUpdatedAt;
  final int retryCount;
  final int status;
  final String? conflictRemoteJson;
  final String? errorMessage;
  const PendingOpRow({
    required this.opUuid,
    required this.userId,
    required this.entityType,
    required this.entityId,
    required this.scopeId,
    required this.operationType,
    required this.path,
    required this.payloadJson,
    required this.createdAt,
    required this.updatedAt,
    this.baseUpdatedAt,
    required this.retryCount,
    required this.status,
    this.conflictRemoteJson,
    this.errorMessage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['op_uuid'] = Variable<String>(opUuid);
    map['user_id'] = Variable<String>(userId);
    map['entity_type'] = Variable<int>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['scope_id'] = Variable<String>(scopeId);
    map['operation_type'] = Variable<int>(operationType);
    map['path'] = Variable<String>(path);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || baseUpdatedAt != null) {
      map['base_updated_at'] = Variable<DateTime>(baseUpdatedAt);
    }
    map['retry_count'] = Variable<int>(retryCount);
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || conflictRemoteJson != null) {
      map['conflict_remote_json'] = Variable<String>(conflictRemoteJson);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    return map;
  }

  PendingOperationsCompanion toCompanion(bool nullToAbsent) {
    return PendingOperationsCompanion(
      opUuid: Value(opUuid),
      userId: Value(userId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      scopeId: Value(scopeId),
      operationType: Value(operationType),
      path: Value(path),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      baseUpdatedAt: baseUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(baseUpdatedAt),
      retryCount: Value(retryCount),
      status: Value(status),
      conflictRemoteJson: conflictRemoteJson == null && nullToAbsent
          ? const Value.absent()
          : Value(conflictRemoteJson),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
    );
  }

  factory PendingOpRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingOpRow(
      opUuid: serializer.fromJson<String>(json['opUuid']),
      userId: serializer.fromJson<String>(json['userId']),
      entityType: serializer.fromJson<int>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      scopeId: serializer.fromJson<String>(json['scopeId']),
      operationType: serializer.fromJson<int>(json['operationType']),
      path: serializer.fromJson<String>(json['path']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      baseUpdatedAt: serializer.fromJson<DateTime?>(json['baseUpdatedAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      status: serializer.fromJson<int>(json['status']),
      conflictRemoteJson: serializer.fromJson<String?>(
        json['conflictRemoteJson'],
      ),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opUuid': serializer.toJson<String>(opUuid),
      'userId': serializer.toJson<String>(userId),
      'entityType': serializer.toJson<int>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'scopeId': serializer.toJson<String>(scopeId),
      'operationType': serializer.toJson<int>(operationType),
      'path': serializer.toJson<String>(path),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'baseUpdatedAt': serializer.toJson<DateTime?>(baseUpdatedAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'status': serializer.toJson<int>(status),
      'conflictRemoteJson': serializer.toJson<String?>(conflictRemoteJson),
      'errorMessage': serializer.toJson<String?>(errorMessage),
    };
  }

  PendingOpRow copyWith({
    String? opUuid,
    String? userId,
    int? entityType,
    String? entityId,
    String? scopeId,
    int? operationType,
    String? path,
    String? payloadJson,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> baseUpdatedAt = const Value.absent(),
    int? retryCount,
    int? status,
    Value<String?> conflictRemoteJson = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
  }) => PendingOpRow(
    opUuid: opUuid ?? this.opUuid,
    userId: userId ?? this.userId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    scopeId: scopeId ?? this.scopeId,
    operationType: operationType ?? this.operationType,
    path: path ?? this.path,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    baseUpdatedAt: baseUpdatedAt.present
        ? baseUpdatedAt.value
        : this.baseUpdatedAt,
    retryCount: retryCount ?? this.retryCount,
    status: status ?? this.status,
    conflictRemoteJson: conflictRemoteJson.present
        ? conflictRemoteJson.value
        : this.conflictRemoteJson,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
  );
  PendingOpRow copyWithCompanion(PendingOperationsCompanion data) {
    return PendingOpRow(
      opUuid: data.opUuid.present ? data.opUuid.value : this.opUuid,
      userId: data.userId.present ? data.userId.value : this.userId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      scopeId: data.scopeId.present ? data.scopeId.value : this.scopeId,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      path: data.path.present ? data.path.value : this.path,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      baseUpdatedAt: data.baseUpdatedAt.present
          ? data.baseUpdatedAt.value
          : this.baseUpdatedAt,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      status: data.status.present ? data.status.value : this.status,
      conflictRemoteJson: data.conflictRemoteJson.present
          ? data.conflictRemoteJson.value
          : this.conflictRemoteJson,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingOpRow(')
          ..write('opUuid: $opUuid, ')
          ..write('userId: $userId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('scopeId: $scopeId, ')
          ..write('operationType: $operationType, ')
          ..write('path: $path, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('baseUpdatedAt: $baseUpdatedAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('status: $status, ')
          ..write('conflictRemoteJson: $conflictRemoteJson, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    opUuid,
    userId,
    entityType,
    entityId,
    scopeId,
    operationType,
    path,
    payloadJson,
    createdAt,
    updatedAt,
    baseUpdatedAt,
    retryCount,
    status,
    conflictRemoteJson,
    errorMessage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingOpRow &&
          other.opUuid == this.opUuid &&
          other.userId == this.userId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.scopeId == this.scopeId &&
          other.operationType == this.operationType &&
          other.path == this.path &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.baseUpdatedAt == this.baseUpdatedAt &&
          other.retryCount == this.retryCount &&
          other.status == this.status &&
          other.conflictRemoteJson == this.conflictRemoteJson &&
          other.errorMessage == this.errorMessage);
}

class PendingOperationsCompanion extends UpdateCompanion<PendingOpRow> {
  final Value<String> opUuid;
  final Value<String> userId;
  final Value<int> entityType;
  final Value<String> entityId;
  final Value<String> scopeId;
  final Value<int> operationType;
  final Value<String> path;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> baseUpdatedAt;
  final Value<int> retryCount;
  final Value<int> status;
  final Value<String?> conflictRemoteJson;
  final Value<String?> errorMessage;
  final Value<int> rowid;
  const PendingOperationsCompanion({
    this.opUuid = const Value.absent(),
    this.userId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.scopeId = const Value.absent(),
    this.operationType = const Value.absent(),
    this.path = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.baseUpdatedAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.status = const Value.absent(),
    this.conflictRemoteJson = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingOperationsCompanion.insert({
    required String opUuid,
    required String userId,
    required int entityType,
    required String entityId,
    required String scopeId,
    required int operationType,
    required String path,
    required String payloadJson,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.baseUpdatedAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    required int status,
    this.conflictRemoteJson = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : opUuid = Value(opUuid),
       userId = Value(userId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       scopeId = Value(scopeId),
       operationType = Value(operationType),
       path = Value(path),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       status = Value(status);
  static Insertable<PendingOpRow> custom({
    Expression<String>? opUuid,
    Expression<String>? userId,
    Expression<int>? entityType,
    Expression<String>? entityId,
    Expression<String>? scopeId,
    Expression<int>? operationType,
    Expression<String>? path,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? baseUpdatedAt,
    Expression<int>? retryCount,
    Expression<int>? status,
    Expression<String>? conflictRemoteJson,
    Expression<String>? errorMessage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opUuid != null) 'op_uuid': opUuid,
      if (userId != null) 'user_id': userId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (scopeId != null) 'scope_id': scopeId,
      if (operationType != null) 'operation_type': operationType,
      if (path != null) 'path': path,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (baseUpdatedAt != null) 'base_updated_at': baseUpdatedAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (status != null) 'status': status,
      if (conflictRemoteJson != null)
        'conflict_remote_json': conflictRemoteJson,
      if (errorMessage != null) 'error_message': errorMessage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingOperationsCompanion copyWith({
    Value<String>? opUuid,
    Value<String>? userId,
    Value<int>? entityType,
    Value<String>? entityId,
    Value<String>? scopeId,
    Value<int>? operationType,
    Value<String>? path,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? baseUpdatedAt,
    Value<int>? retryCount,
    Value<int>? status,
    Value<String?>? conflictRemoteJson,
    Value<String?>? errorMessage,
    Value<int>? rowid,
  }) {
    return PendingOperationsCompanion(
      opUuid: opUuid ?? this.opUuid,
      userId: userId ?? this.userId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      scopeId: scopeId ?? this.scopeId,
      operationType: operationType ?? this.operationType,
      path: path ?? this.path,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      baseUpdatedAt: baseUpdatedAt ?? this.baseUpdatedAt,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      conflictRemoteJson: conflictRemoteJson ?? this.conflictRemoteJson,
      errorMessage: errorMessage ?? this.errorMessage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opUuid.present) {
      map['op_uuid'] = Variable<String>(opUuid.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<int>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (scopeId.present) {
      map['scope_id'] = Variable<String>(scopeId.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<int>(operationType.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (baseUpdatedAt.present) {
      map['base_updated_at'] = Variable<DateTime>(baseUpdatedAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (conflictRemoteJson.present) {
      map['conflict_remote_json'] = Variable<String>(conflictRemoteJson.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingOperationsCompanion(')
          ..write('opUuid: $opUuid, ')
          ..write('userId: $userId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('scopeId: $scopeId, ')
          ..write('operationType: $operationType, ')
          ..write('path: $path, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('baseUpdatedAt: $baseUpdatedAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('status: $status, ')
          ..write('conflictRemoteJson: $conflictRemoteJson, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetaEntriesTable extends SyncMetaEntries
    with TableInfo<$SyncMetaEntriesTable, SyncMetaEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetaEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metaKeyMeta = const VerificationMeta(
    'metaKey',
  );
  @override
  late final GeneratedColumn<String> metaKey = GeneratedColumn<String>(
    'meta_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metaValueMeta = const VerificationMeta(
    'metaValue',
  );
  @override
  late final GeneratedColumn<String> metaValue = GeneratedColumn<String>(
    'meta_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [userId, metaKey, metaValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_meta_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetaEntry> instance, {
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
    if (data.containsKey('meta_key')) {
      context.handle(
        _metaKeyMeta,
        metaKey.isAcceptableOrUnknown(data['meta_key']!, _metaKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_metaKeyMeta);
    }
    if (data.containsKey('meta_value')) {
      context.handle(
        _metaValueMeta,
        metaValue.isAcceptableOrUnknown(data['meta_value']!, _metaValueMeta),
      );
    } else if (isInserting) {
      context.missing(_metaValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, metaKey};
  @override
  SyncMetaEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetaEntry(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      metaKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meta_key'],
      )!,
      metaValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meta_value'],
      )!,
    );
  }

  @override
  $SyncMetaEntriesTable createAlias(String alias) {
    return $SyncMetaEntriesTable(attachedDatabase, alias);
  }
}

class SyncMetaEntry extends DataClass implements Insertable<SyncMetaEntry> {
  final String userId;
  final String metaKey;
  final String metaValue;
  const SyncMetaEntry({
    required this.userId,
    required this.metaKey,
    required this.metaValue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['meta_key'] = Variable<String>(metaKey);
    map['meta_value'] = Variable<String>(metaValue);
    return map;
  }

  SyncMetaEntriesCompanion toCompanion(bool nullToAbsent) {
    return SyncMetaEntriesCompanion(
      userId: Value(userId),
      metaKey: Value(metaKey),
      metaValue: Value(metaValue),
    );
  }

  factory SyncMetaEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetaEntry(
      userId: serializer.fromJson<String>(json['userId']),
      metaKey: serializer.fromJson<String>(json['metaKey']),
      metaValue: serializer.fromJson<String>(json['metaValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'metaKey': serializer.toJson<String>(metaKey),
      'metaValue': serializer.toJson<String>(metaValue),
    };
  }

  SyncMetaEntry copyWith({
    String? userId,
    String? metaKey,
    String? metaValue,
  }) => SyncMetaEntry(
    userId: userId ?? this.userId,
    metaKey: metaKey ?? this.metaKey,
    metaValue: metaValue ?? this.metaValue,
  );
  SyncMetaEntry copyWithCompanion(SyncMetaEntriesCompanion data) {
    return SyncMetaEntry(
      userId: data.userId.present ? data.userId.value : this.userId,
      metaKey: data.metaKey.present ? data.metaKey.value : this.metaKey,
      metaValue: data.metaValue.present ? data.metaValue.value : this.metaValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaEntry(')
          ..write('userId: $userId, ')
          ..write('metaKey: $metaKey, ')
          ..write('metaValue: $metaValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, metaKey, metaValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetaEntry &&
          other.userId == this.userId &&
          other.metaKey == this.metaKey &&
          other.metaValue == this.metaValue);
}

class SyncMetaEntriesCompanion extends UpdateCompanion<SyncMetaEntry> {
  final Value<String> userId;
  final Value<String> metaKey;
  final Value<String> metaValue;
  final Value<int> rowid;
  const SyncMetaEntriesCompanion({
    this.userId = const Value.absent(),
    this.metaKey = const Value.absent(),
    this.metaValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetaEntriesCompanion.insert({
    required String userId,
    required String metaKey,
    required String metaValue,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       metaKey = Value(metaKey),
       metaValue = Value(metaValue);
  static Insertable<SyncMetaEntry> custom({
    Expression<String>? userId,
    Expression<String>? metaKey,
    Expression<String>? metaValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (metaKey != null) 'meta_key': metaKey,
      if (metaValue != null) 'meta_value': metaValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetaEntriesCompanion copyWith({
    Value<String>? userId,
    Value<String>? metaKey,
    Value<String>? metaValue,
    Value<int>? rowid,
  }) {
    return SyncMetaEntriesCompanion(
      userId: userId ?? this.userId,
      metaKey: metaKey ?? this.metaKey,
      metaValue: metaValue ?? this.metaValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (metaKey.present) {
      map['meta_key'] = Variable<String>(metaKey.value);
    }
    if (metaValue.present) {
      map['meta_value'] = Variable<String>(metaValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaEntriesCompanion(')
          ..write('userId: $userId, ')
          ..write('metaKey: $metaKey, ')
          ..write('metaValue: $metaValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalEntitiesTable localEntities = $LocalEntitiesTable(this);
  late final $PendingOperationsTable pendingOperations =
      $PendingOperationsTable(this);
  late final $SyncMetaEntriesTable syncMetaEntries = $SyncMetaEntriesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localEntities,
    pendingOperations,
    syncMetaEntries,
  ];
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
typedef $$PendingOperationsTableCreateCompanionBuilder =
    PendingOperationsCompanion Function({
      required String opUuid,
      required String userId,
      required int entityType,
      required String entityId,
      required String scopeId,
      required int operationType,
      required String path,
      required String payloadJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> baseUpdatedAt,
      Value<int> retryCount,
      required int status,
      Value<String?> conflictRemoteJson,
      Value<String?> errorMessage,
      Value<int> rowid,
    });
typedef $$PendingOperationsTableUpdateCompanionBuilder =
    PendingOperationsCompanion Function({
      Value<String> opUuid,
      Value<String> userId,
      Value<int> entityType,
      Value<String> entityId,
      Value<String> scopeId,
      Value<int> operationType,
      Value<String> path,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> baseUpdatedAt,
      Value<int> retryCount,
      Value<int> status,
      Value<String?> conflictRemoteJson,
      Value<String?> errorMessage,
      Value<int> rowid,
    });

class $$PendingOperationsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingOperationsTable> {
  $$PendingOperationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opUuid => $composableBuilder(
    column: $table.opUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopeId => $composableBuilder(
    column: $table.scopeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get baseUpdatedAt => $composableBuilder(
    column: $table.baseUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conflictRemoteJson => $composableBuilder(
    column: $table.conflictRemoteJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingOperationsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingOperationsTable> {
  $$PendingOperationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opUuid => $composableBuilder(
    column: $table.opUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopeId => $composableBuilder(
    column: $table.scopeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get baseUpdatedAt => $composableBuilder(
    column: $table.baseUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conflictRemoteJson => $composableBuilder(
    column: $table.conflictRemoteJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingOperationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingOperationsTable> {
  $$PendingOperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opUuid =>
      $composableBuilder(column: $table.opUuid, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get scopeId =>
      $composableBuilder(column: $table.scopeId, builder: (column) => column);

  GeneratedColumn<int> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get baseUpdatedAt => $composableBuilder(
    column: $table.baseUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get conflictRemoteJson => $composableBuilder(
    column: $table.conflictRemoteJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );
}

class $$PendingOperationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingOperationsTable,
          PendingOpRow,
          $$PendingOperationsTableFilterComposer,
          $$PendingOperationsTableOrderingComposer,
          $$PendingOperationsTableAnnotationComposer,
          $$PendingOperationsTableCreateCompanionBuilder,
          $$PendingOperationsTableUpdateCompanionBuilder,
          (
            PendingOpRow,
            BaseReferences<
              _$AppDatabase,
              $PendingOperationsTable,
              PendingOpRow
            >,
          ),
          PendingOpRow,
          PrefetchHooks Function()
        > {
  $$PendingOperationsTableTableManager(
    _$AppDatabase db,
    $PendingOperationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingOperationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingOperationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingOperationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> opUuid = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> scopeId = const Value.absent(),
                Value<int> operationType = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> baseUpdatedAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<String?> conflictRemoteJson = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingOperationsCompanion(
                opUuid: opUuid,
                userId: userId,
                entityType: entityType,
                entityId: entityId,
                scopeId: scopeId,
                operationType: operationType,
                path: path,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                baseUpdatedAt: baseUpdatedAt,
                retryCount: retryCount,
                status: status,
                conflictRemoteJson: conflictRemoteJson,
                errorMessage: errorMessage,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String opUuid,
                required String userId,
                required int entityType,
                required String entityId,
                required String scopeId,
                required int operationType,
                required String path,
                required String payloadJson,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> baseUpdatedAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                required int status,
                Value<String?> conflictRemoteJson = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingOperationsCompanion.insert(
                opUuid: opUuid,
                userId: userId,
                entityType: entityType,
                entityId: entityId,
                scopeId: scopeId,
                operationType: operationType,
                path: path,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                baseUpdatedAt: baseUpdatedAt,
                retryCount: retryCount,
                status: status,
                conflictRemoteJson: conflictRemoteJson,
                errorMessage: errorMessage,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingOperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingOperationsTable,
      PendingOpRow,
      $$PendingOperationsTableFilterComposer,
      $$PendingOperationsTableOrderingComposer,
      $$PendingOperationsTableAnnotationComposer,
      $$PendingOperationsTableCreateCompanionBuilder,
      $$PendingOperationsTableUpdateCompanionBuilder,
      (
        PendingOpRow,
        BaseReferences<_$AppDatabase, $PendingOperationsTable, PendingOpRow>,
      ),
      PendingOpRow,
      PrefetchHooks Function()
    >;
typedef $$SyncMetaEntriesTableCreateCompanionBuilder =
    SyncMetaEntriesCompanion Function({
      required String userId,
      required String metaKey,
      required String metaValue,
      Value<int> rowid,
    });
typedef $$SyncMetaEntriesTableUpdateCompanionBuilder =
    SyncMetaEntriesCompanion Function({
      Value<String> userId,
      Value<String> metaKey,
      Value<String> metaValue,
      Value<int> rowid,
    });

class $$SyncMetaEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetaEntriesTable> {
  $$SyncMetaEntriesTableFilterComposer({
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

  ColumnFilters<String> get metaKey => $composableBuilder(
    column: $table.metaKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metaValue => $composableBuilder(
    column: $table.metaValue,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetaEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetaEntriesTable> {
  $$SyncMetaEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get metaKey => $composableBuilder(
    column: $table.metaKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metaValue => $composableBuilder(
    column: $table.metaValue,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetaEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetaEntriesTable> {
  $$SyncMetaEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get metaKey =>
      $composableBuilder(column: $table.metaKey, builder: (column) => column);

  GeneratedColumn<String> get metaValue =>
      $composableBuilder(column: $table.metaValue, builder: (column) => column);
}

class $$SyncMetaEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetaEntriesTable,
          SyncMetaEntry,
          $$SyncMetaEntriesTableFilterComposer,
          $$SyncMetaEntriesTableOrderingComposer,
          $$SyncMetaEntriesTableAnnotationComposer,
          $$SyncMetaEntriesTableCreateCompanionBuilder,
          $$SyncMetaEntriesTableUpdateCompanionBuilder,
          (
            SyncMetaEntry,
            BaseReferences<_$AppDatabase, $SyncMetaEntriesTable, SyncMetaEntry>,
          ),
          SyncMetaEntry,
          PrefetchHooks Function()
        > {
  $$SyncMetaEntriesTableTableManager(
    _$AppDatabase db,
    $SyncMetaEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetaEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetaEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetaEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> metaKey = const Value.absent(),
                Value<String> metaValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetaEntriesCompanion(
                userId: userId,
                metaKey: metaKey,
                metaValue: metaValue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String metaKey,
                required String metaValue,
                Value<int> rowid = const Value.absent(),
              }) => SyncMetaEntriesCompanion.insert(
                userId: userId,
                metaKey: metaKey,
                metaValue: metaValue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetaEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetaEntriesTable,
      SyncMetaEntry,
      $$SyncMetaEntriesTableFilterComposer,
      $$SyncMetaEntriesTableOrderingComposer,
      $$SyncMetaEntriesTableAnnotationComposer,
      $$SyncMetaEntriesTableCreateCompanionBuilder,
      $$SyncMetaEntriesTableUpdateCompanionBuilder,
      (
        SyncMetaEntry,
        BaseReferences<_$AppDatabase, $SyncMetaEntriesTable, SyncMetaEntry>,
      ),
      SyncMetaEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalEntitiesTableTableManager get localEntities =>
      $$LocalEntitiesTableTableManager(_db, _db.localEntities);
  $$PendingOperationsTableTableManager get pendingOperations =>
      $$PendingOperationsTableTableManager(_db, _db.pendingOperations);
  $$SyncMetaEntriesTableTableManager get syncMetaEntries =>
      $$SyncMetaEntriesTableTableManager(_db, _db.syncMetaEntries);
}
