/// Exercise record for a customer: custom exercise + value + unit + date.
/// Stored locally as an offline entity payload.
class CustomerExerciseRecord {
  const CustomerExerciseRecord({
    required this.id,
    required this.customerId,
    required this.customExerciseId,
    this.exerciseName,
    required this.value,
    required this.unit,
    required this.recordedAt,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.rowVersion = 1,
  });

  final String id;
  final String customerId;
  final String customExerciseId;
  final String? exerciseName;
  final double value;
  final String unit;
  final DateTime recordedAt;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int rowVersion;

  static CustomerExerciseRecord fromJson(Map<String, dynamic> json) {
    return CustomerExerciseRecord(
      id: json['id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      customExerciseId: json['customExerciseId']?.toString() ?? '',
      exerciseName: json['exerciseName'] as String?,
      value: _toDouble(json['value']) ?? 0,
      unit: json['unit'] as String? ?? '',
      recordedAt: _parseDate(json['recordedAt']),
      note: json['note'] as String?,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      rowVersion: (json['rowVersion'] as num?)?.toInt() ?? 1,
    );
  }

  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString()) ?? DateTime.now();
  }

  static DateTime _parseDateTime(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString()) ?? DateTime.now();
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static String toDateString(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String get displayName {
    final name = exerciseName?.trim();
    if (name == null || name.isEmpty) return customExerciseId;
    return name;
  }

  Map<String, dynamic> toCreateBody() => {
        'customExerciseId': customExerciseId,
        'value': value,
        'unit': unit,
        'recordedAt': toDateString(recordedAt),
        if (note != null && note!.trim().isNotEmpty) 'note': note,
      };

  Map<String, dynamic> toUpdateBody() => {
        'value': value,
        'unit': unit,
        'recordedAt': toDateString(recordedAt),
        if (note != null && note!.trim().isNotEmpty) 'note': note,
      };
}
