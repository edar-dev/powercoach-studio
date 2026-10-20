/// Coach-authored custom massimale for a customer (cloud SoT + Drift cache).
///
/// Entity type string: `customerMaximal` (`OfflineEntityType.customerMaximal`).
/// Not related to the removed legacy `exerciseRecord` product surface.
class CustomerMaximal {
  const CustomerMaximal({
    required this.id,
    required this.customerId,
    required this.label,
    required this.weightKg,
    required this.updatedAt,
    this.linkedExerciseKey,
  });

  final String id;
  final String customerId;
  final String label;
  final double weightKg;
  final DateTime updatedAt;

  /// Optional catalog / exercise key for future association UX.
  final String? linkedExerciseKey;

  static CustomerMaximal fromJson(Map<String, dynamic> json) {
    return CustomerMaximal(
      id: json['id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      weightKg: _toDouble(json['weightKg']) ?? 0,
      updatedAt: _parseDateTime(json['updatedAt']),
      linkedExerciseKey: _optionalString(json['linkedExerciseKey']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'customerId': customerId,
      'label': label,
      'weightKg': weightKg,
      'updatedAt': updatedAt.toIso8601String(),
      if (linkedExerciseKey != null) 'linkedExerciseKey': linkedExerciseKey,
    };
  }

  CustomerMaximal copyWith({
    String? id,
    String? customerId,
    String? label,
    double? weightKg,
    DateTime? updatedAt,
    String? linkedExerciseKey,
    bool clearLinkedExerciseKey = false,
  }) {
    return CustomerMaximal(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      label: label ?? this.label,
      weightKg: weightKg ?? this.weightKg,
      updatedAt: updatedAt ?? this.updatedAt,
      linkedExerciseKey: clearLinkedExerciseKey
          ? null
          : (linkedExerciseKey ?? this.linkedExerciseKey),
    );
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

  static String? _optionalString(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }
}
