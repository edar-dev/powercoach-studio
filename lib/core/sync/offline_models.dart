import 'dart:convert';

enum OfflineEntityType {
  customer,
  workoutPlan,
  measurement,
  exerciseRecord,
  customExercise,
}

enum OfflineOperationType {
  create,
  update,
  delete,
}

enum PendingOperationStatus {
  pending,
  syncing,
  failed,
  conflict,
  completed,
  deadLetter,
  blockedAuth,
}

class OfflineEntity {
  const OfflineEntity({
    required this.id,
    required this.type,
    required this.scopeId,
    required this.payload,
    required this.updatedAt,
    this.deleted = false,
    this.localOnly = false,
  });

  final String id;
  final OfflineEntityType type;
  final String scopeId;
  final Map<String, dynamic> payload;
  final DateTime updatedAt;
  final bool deleted;
  final bool localOnly;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'scopeId': scopeId,
        'payload': payload,
        'updatedAt': updatedAt.toIso8601String(),
        'deleted': deleted,
        'localOnly': localOnly,
      };

  static OfflineEntity fromJson(Map<String, dynamic> json) {
    return OfflineEntity(
      id: json['id']?.toString() ?? '',
      type: OfflineEntityType.values.firstWhere(
        (v) => v.name == json['type'],
        orElse: () => OfflineEntityType.customer,
      ),
      scopeId: json['scopeId']?.toString() ?? '',
      payload: (json['payload'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      deleted: json['deleted'] as bool? ?? false,
      localOnly: json['localOnly'] as bool? ?? false,
    );
  }
}

class PendingOperation {
  const PendingOperation({
    required this.id,
    required this.userId,
    required this.entityType,
    required this.entityId,
    required this.scopeId,
    required this.operationType,
    required this.path,
    required this.payload,
    required this.createdAt,
    required this.updatedAt,
    this.baseUpdatedAt,
    this.retryCount = 0,
    this.status = PendingOperationStatus.pending,
    this.conflictRemotePayload,
    this.errorMessage,
  });

  final String id;
  /// Coach Supabase user id; scopes outbox and sync.
  final String userId;
  final OfflineEntityType entityType;
  final String entityId;
  final String scopeId;
  final OfflineOperationType operationType;
  final String path;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? baseUpdatedAt;
  final int retryCount;
  final PendingOperationStatus status;
  final Map<String, dynamic>? conflictRemotePayload;
  final String? errorMessage;

  PendingOperation copyWith({
    int? retryCount,
    PendingOperationStatus? status,
    DateTime? updatedAt,
    Map<String, dynamic>? conflictRemotePayload,
    bool clearConflictRemote = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PendingOperation(
      id: id,
      userId: userId,
      entityType: entityType,
      entityId: entityId,
      scopeId: scopeId,
      operationType: operationType,
      path: path,
      payload: payload,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      baseUpdatedAt: baseUpdatedAt,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      conflictRemotePayload: clearConflictRemote
          ? null
          : (conflictRemotePayload ?? this.conflictRemotePayload),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'entityType': entityType.name,
        'entityId': entityId,
        'scopeId': scopeId,
        'operationType': operationType.name,
        'path': path,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'baseUpdatedAt': baseUpdatedAt?.toIso8601String(),
        'retryCount': retryCount,
        'status': status.name,
        'conflictRemotePayload': conflictRemotePayload,
        'errorMessage': errorMessage,
      };

  static PendingOperation fromJson(Map<String, dynamic> json) {
    return PendingOperation(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      entityType: OfflineEntityType.values.firstWhere(
        (v) => v.name == json['entityType'],
        orElse: () => OfflineEntityType.customer,
      ),
      entityId: json['entityId']?.toString() ?? '',
      scopeId: json['scopeId']?.toString() ?? '',
      operationType: OfflineOperationType.values.firstWhere(
        (v) => v.name == json['operationType'],
        orElse: () => OfflineOperationType.update,
      ),
      path: json['path']?.toString() ?? '',
      payload: (json['payload'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      baseUpdatedAt: json['baseUpdatedAt'] == null
          ? null
          : DateTime.tryParse(json['baseUpdatedAt'].toString()),
      retryCount: json['retryCount'] as int? ?? 0,
      status: PendingOperationStatus.values.firstWhere(
        (v) => v.name == json['status'],
        orElse: () => PendingOperationStatus.pending,
      ),
      conflictRemotePayload: (json['conflictRemotePayload'] as Map?)?.cast<String, dynamic>(),
      errorMessage: json['errorMessage']?.toString(),
    );
  }
}

String encodeJsonList(List<Map<String, dynamic>> list) => jsonEncode(list);
