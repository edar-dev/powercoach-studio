/// Big-3 lifts whose 1RM lives on [CustomerMeasurement].
enum MaximalLift {
  squat,
  bench,
  deadlift;

  static MaximalLift? fromJson(String? value) {
    if (value == null) return null;
    for (final lift in values) {
      if (lift.name == value) return lift;
    }
    return null;
  }

  String toJson() => name;
}

/// How the coach resolves a measurement-linked massimale when history has
/// multiple values. UI-local in v1; default is historic max per product spec.
enum MaximalResolveMode {
  /// Latest non-null 1RM by [CustomerMeasurement.measurementDate] (then
  /// [CustomerMeasurement.updatedAt]).
  ultimo,

  /// Max of all non-null 1RM values for the linked lift.
  massimoStorico,
}

/// Discriminator for [MaximalRef] JSON `type`.
enum MaximalRefKind {
  measurement,
  custom,
}

/// Association from a plan [Exercise] to a massimale source.
///
/// JSON:
/// - `{ "type": "measurement", "lift": "bench" }`
/// - `{ "type": "custom", "maximalId": "…" }`
class MaximalRef {
  const MaximalRef._({
    required this.kind,
    this.lift,
    this.maximalId,
  });

  const MaximalRef.measurement({required MaximalLift lift})
      : this._(kind: MaximalRefKind.measurement, lift: lift);

  const MaximalRef.custom({required String maximalId})
      : this._(kind: MaximalRefKind.custom, maximalId: maximalId);

  final MaximalRefKind kind;
  final MaximalLift? lift;
  final String? maximalId;

  bool get isMeasurement => kind == MaximalRefKind.measurement;
  bool get isCustom => kind == MaximalRefKind.custom;

  Map<String, dynamic> toJson() {
    switch (kind) {
      case MaximalRefKind.measurement:
        return {
          'type': 'measurement',
          'lift': lift!.toJson(),
        };
      case MaximalRefKind.custom:
        return {
          'type': 'custom',
          'maximalId': maximalId,
        };
    }
  }

  /// Returns null when [json] is null, not a map, or structurally invalid.
  static MaximalRef? fromJson(Object? json) {
    if (json == null) return null;
    if (json is! Map) return null;
    final map = Map<String, dynamic>.from(json);
    final type = _asTrimmedString(map['type']);
    switch (type) {
      case 'measurement':
        final lift = MaximalLift.fromJson(_asTrimmedString(map['lift']));
        if (lift == null) return null;
        return MaximalRef.measurement(lift: lift);
      case 'custom':
        final id = _asTrimmedString(map['maximalId']);
        if (id == null || id.isEmpty) return null;
        return MaximalRef.custom(maximalId: id);
      default:
        return null;
    }
  }

  static String? _asTrimmedString(Object? value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    // Wrong JSON types (num/bool/map) → treat as invalid, do not throw.
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MaximalRef &&
        other.kind == kind &&
        other.lift == lift &&
        other.maximalId == maximalId;
  }

  @override
  int get hashCode => Object.hash(kind, lift, maximalId);

  @override
  String toString() => 'MaximalRef(${toJson()})';
}
