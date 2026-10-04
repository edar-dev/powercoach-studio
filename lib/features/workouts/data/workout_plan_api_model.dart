import 'dart:convert';

import 'workout_routine_model.dart';

/// Local workout plan DTO (Drift / repository layer).
///
/// Writers persist [planData] as a nested JSON Map in entity payloads.
/// [fromJson] normalizes String|Map into the in-memory [planData] String so
/// typed accessors keep working.
///
/// Plan-level lifecycle/schedule markers ([archivedAt], [completedAt],
/// [startDate], [endDate], [currentWeek]) live as **top-level** payload fields.
/// Readers fall back to legacy keys inside [planData] when top-level is absent.
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
    this.archivedAt,
    this.completedAt,
    this.startDate,
    this.endDate,
    this.currentWeek,
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
  final DateTime? archivedAt;
  final DateTime? completedAt;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? currentWeek;
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

  /// Parsed routine from [planData], with top-level schedule overlaid.
  ///
  /// Throws on invalid JSON (same cast path as the string-only
  /// `planDataToRoutine` shim).
  WorkoutRoutine get routine {
    final map = Map<String, dynamic>.from(
      jsonDecode(planData) as Map<String, dynamic>,
    );
    // Top-level schedule is authoritative when present.
    if (startDate != null) {
      map['startDate'] = DateTime(
        startDate!.year,
        startDate!.month,
        startDate!.day,
      ).toIso8601String();
    }
    if (endDate != null) {
      map['endDate'] = DateTime(
        endDate!.year,
        endDate!.month,
        endDate!.day,
      ).toIso8601String();
    }
    if (currentWeek != null) {
      map['currentWeek'] = currentWeek;
    }
    return WorkoutRoutine.fromJson(map);
  }

  bool get isArchived => archivedAt != null;

  static WorkoutPlanApiModel fromJson(Map<String, dynamic> json) {
    final planData = _normalizePlanDataField(json['planData']);
    final nested = _decodePlanDataMap(planData);

    return WorkoutPlanApiModel(
      id: json['id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      theme: json['theme'] as String?,
      initialWeekNumber: json['initialWeekNumber'] as int? ?? 1,
      planData: planData,
      pdfHeader: json['pdfHeader'] as String?,
      useCustomPdfHeader: json['useCustomPdfHeader'] as bool? ?? false,
      phase: json['phase'] as String?,
      tags: json['tags'] as String?,
      notes: json['notes'] as String?,
      archivedAt: _parseOptionalDate(json['archivedAt']) ??
          _parseOptionalDate(nested['archivedAt']),
      completedAt: _parseOptionalDate(json['completedAt']) ??
          _parseOptionalDate(nested['completedAt']),
      startDate: _parseOptionalDateOnly(json['startDate']) ??
          _parseOptionalDateOnly(nested['startDate']),
      endDate: _parseOptionalDateOnly(json['endDate']) ??
          _parseOptionalDateOnly(nested['endDate']),
      currentWeek: _parseOptionalInt(json['currentWeek']) ??
          _parseOptionalInt(nested['currentWeek']),
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

  static Map<String, dynamic> _decodePlanDataMap(String planData) {
    try {
      final decoded = jsonDecode(planData);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return const <String, dynamic>{};
    } catch (_) {
      return const <String, dynamic>{};
    }
  }

  static DateTime? _parseOptionalDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  static DateTime? _parseOptionalDateOnly(dynamic v) {
    final parsed = _parseOptionalDate(v);
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static int? _parseOptionalInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static DateTime _parseDateTime(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString()) ?? DateTime.now();
  }
}
