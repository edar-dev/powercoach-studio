/// Customer measurement model (local-first payload).
/// 1RM (kg), skinfolds (mm), BIA, circumferences (cm).
class CustomerMeasurement {
  const CustomerMeasurement({
    required this.id,
    required this.customerId,
    required this.userId,
    required this.measurementDate,
    this.squat1RM,
    this.benchPress1RM,
    this.deadlift1RM,
    this.tricepsSkinfold,
    this.bicepsSkinfold,
    this.subscapularSkinfold,
    this.iliacSkinfold,
    this.abdominalSkinfold,
    this.thighSkinfold,
    this.bodyFatPercent,
    this.muscleMassKg,
    this.waterPercent,
    this.fatMassKg,
    this.chestCm,
    this.waistCm,
    this.armsCm,
    this.thighsCm,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.rowVersion = 1,
  });

  final String id;
  final String customerId;
  final String userId;
  final DateTime measurementDate;
  final double? squat1RM;
  final double? benchPress1RM;
  final double? deadlift1RM;
  final double? tricepsSkinfold;
  final double? bicepsSkinfold;
  final double? subscapularSkinfold;
  final double? iliacSkinfold;
  final double? abdominalSkinfold;
  final double? thighSkinfold;
  final double? bodyFatPercent;
  final double? muscleMassKg;
  final double? waterPercent;
  final double? fatMassKg;
  final double? chestCm;
  final double? waistCm;
  final double? armsCm;
  final double? thighsCm;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int rowVersion;

  static CustomerMeasurement fromJson(Map<String, dynamic> json) {
    return CustomerMeasurement(
      id: json['id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      measurementDate: _parseDate(json['measurementDate']),
      squat1RM: _toDouble(json['squat1RM']),
      benchPress1RM: _toDouble(json['benchPress1RM']),
      deadlift1RM: _toDouble(json['deadlift1RM']),
      tricepsSkinfold: _toDouble(json['tricepsSkinfold']),
      bicepsSkinfold: _toDouble(json['bicepsSkinfold']),
      subscapularSkinfold: _toDouble(json['subscapularSkinfold']),
      iliacSkinfold: _toDouble(json['iliacSkinfold']),
      abdominalSkinfold: _toDouble(json['abdominalSkinfold']),
      thighSkinfold: _toDouble(json['thighSkinfold']),
      bodyFatPercent: _toDouble(json['bodyFatPercent']),
      muscleMassKg: _toDouble(json['muscleMassKg']),
      waterPercent: _toDouble(json['waterPercent']),
      fatMassKg: _toDouble(json['fatMassKg']),
      chestCm: _toDouble(json['chestCm']),
      waistCm: _toDouble(json['waistCm']),
      armsCm: _toDouble(json['armsCm']),
      thighsCm: _toDouble(json['thighsCm']),
      notes: json['notes'] as String?,
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

  /// Format date for API (yyyy-MM-dd).
  static String toDateString(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toCreateBody() {
    return {
      'measurementDate': toDateString(measurementDate),
      'squat1RM': squat1RM,
      'benchPress1RM': benchPress1RM,
      'deadlift1RM': deadlift1RM,
      'tricepsSkinfold': tricepsSkinfold,
      'bicepsSkinfold': bicepsSkinfold,
      'subscapularSkinfold': subscapularSkinfold,
      'iliacSkinfold': iliacSkinfold,
      'abdominalSkinfold': abdominalSkinfold,
      'thighSkinfold': thighSkinfold,
      'bodyFatPercent': bodyFatPercent,
      'muscleMassKg': muscleMassKg,
      'waterPercent': waterPercent,
      'fatMassKg': fatMassKg,
      'chestCm': chestCm,
      'waistCm': waistCm,
      'armsCm': armsCm,
      'thighsCm': thighsCm,
      'notes': notes?.trim().isEmpty ?? true ? null : notes,
    };
  }

  Map<String, dynamic> toUpdateBody() => {
        ...toCreateBody(),
        'expectedRowVersion': rowVersion,
      };
}
