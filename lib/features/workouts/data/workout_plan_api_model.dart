import 'dart:convert';

import 'workout_routine_model.dart';

/// Local workout plan DTO (Drift / repository layer).
///
/// Writers persist [planData] as a nested JSON Map in entity payloads.
/// [fromJson] normalizes String|Map into the in-memory [planData] String so
/// typed accessors keep working. Lifecycle fields ([archivedAt] /
/// [completedAt]) live in the same blob outside the routine's structural fields.
class WorkoutPlanApiModel {
  const WorkoutPlanApiModel({
    required this.id,
    required this.customerId,
    required this.userId,
    required this.name,
    this.theme,
    this.initialWeekNumber = 1,
    required this.planData,
    this.pdfHeader,
    this.useCustomPdfHeader = false,
    this.phase,
    this.tags,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.rowVersion = 1,
  });

  final String id;
  final String customerId;
  final String userId;
  final String name;
  final String? theme;
  final int initialWeekNumber;
  final String planData;
  final String? pdfHeader;
  final bool useCustomPdfHeader;
  final String? phase;
  final String? tags;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int rowVersion;

  /// Decoded [planData] map. Returns `{}` when JSON is invalid or not an object.
  Map<String, dynamic> get planDataMap {
    try {
      final decoded = jsonDecode(planData);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return const <String, dynamic>{};
    } catch (_) {
      return const <String, dynamic>{};
    }
  }

  /// Parsed routine from [planData]. Throws on invalid JSON (same cast path as
  /// the string-only `planDataToRoutine` shim).
  WorkoutRoutine get routine {
    final map = jsonDecode(planData) as Map<String, dynamic>;
    return WorkoutRoutine.fromJson(map);
  }

  DateTime? get archivedAt => _lifecycleDate('archivedAt');

  DateTime? get completedAt => _lifecycleDate('completedAt');

  bool get isArchived => archivedAt != null;

  DateTime? _lifecycleDate(String key) {
    final raw = planDataMap[key];
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString());
  }

  static WorkoutPlanApiModel fromJson(Map<String, dynamic> json) {
    return WorkoutPlanApiModel(
      id: json['id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      theme: json['theme'] as String?,
      initialWeekNumber: json['initialWeekNumber'] as int? ?? 1,
      planData: _normalizePlanDataField(json['planData']),
      pdfHeader: json['pdfHeader'] as String?,
      useCustomPdfHeader: json['useCustomPdfHeader'] as bool? ?? false,
      phase: json['phase'] as String?,
      tags: json['tags'] as String?,
      notes: json['notes'] as String?,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      rowVersion: (json['rowVersion'] as num?)?.toInt() ?? 1,
    );
  }

  /// Normalizes payload planData (String|Map) into the in-memory String field.
  ///
  /// Maps are jsonEncoded; null / unsupported shapes become `'{}'`.
  static String _normalizePlanDataField(dynamic raw) {
    if (raw == null) return '{}';
    if (raw is String) return raw;
    if (raw is Map) {
      return jsonEncode(Map<String, dynamic>.from(raw));
    }
    return '{}';
  }

  static DateTime _parseDateTime(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString()) ?? DateTime.now();
  }
}
