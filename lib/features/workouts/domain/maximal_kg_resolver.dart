import '../../customers/data/models/customer_measurement.dart';
import 'maximal_ref.dart';

/// Minimal custom-massimale lookup for PR1 (full entity lands in a later PR).
class MaximalCustomKg {
  const MaximalCustomKg({
    required this.id,
    required this.weightKg,
  });

  final String id;
  final double weightKg;
}

/// Resolves a linked massimale to kg from measurements and/or custom entries.
class MaximalKgResolver {
  MaximalKgResolver._();

  /// Default mode matches product spec: historic max across measurement history.
  static const MaximalResolveMode defaultMode =
      MaximalResolveMode.massimoStorico;

  static double? resolve({
    required MaximalRef? ref,
    required Iterable<CustomerMeasurement> measurements,
    Iterable<MaximalCustomKg> customs = const [],
    MaximalResolveMode mode = defaultMode,
  }) {
    if (ref == null) return null;

    if (ref.isCustom) {
      final id = ref.maximalId;
      if (id == null || id.isEmpty) return null;
      for (final custom in customs) {
        if (custom.id == id) return custom.weightKg;
      }
      return null;
    }

    final lift = ref.lift;
    if (lift == null) return null;
    return _resolveFromMeasurements(
      measurements: measurements,
      lift: lift,
      mode: mode,
    );
  }

  static double? _resolveFromMeasurements({
    required Iterable<CustomerMeasurement> measurements,
    required MaximalLift lift,
    required MaximalResolveMode mode,
  }) {
    final values = <_DatedLiftKg>[];
    for (final m in measurements) {
      final kg = _liftKg(m, lift);
      if (kg == null) continue;
      values.add(
        _DatedLiftKg(
          kg: kg,
          measurementDate: m.measurementDate,
          updatedAt: m.updatedAt,
        ),
      );
    }
    if (values.isEmpty) return null;

    switch (mode) {
      case MaximalResolveMode.ultimo:
        values.sort(_compareNewestFirst);
        return values.first.kg;
      case MaximalResolveMode.massimoStorico:
        var maxKg = values.first.kg;
        for (final v in values.skip(1)) {
          if (v.kg > maxKg) maxKg = v.kg;
        }
        return maxKg;
    }
  }

  static double? _liftKg(CustomerMeasurement m, MaximalLift lift) {
    switch (lift) {
      case MaximalLift.squat:
        return m.squat1RM;
      case MaximalLift.bench:
        return m.benchPress1RM;
      case MaximalLift.deadlift:
        return m.deadlift1RM;
    }
  }

  static int _compareNewestFirst(_DatedLiftKg a, _DatedLiftKg b) {
    final byDate = b.measurementDate.compareTo(a.measurementDate);
    if (byDate != 0) return byDate;
    return b.updatedAt.compareTo(a.updatedAt);
  }
}

class _DatedLiftKg {
  const _DatedLiftKg({
    required this.kg,
    required this.measurementDate,
    required this.updatedAt,
  });

  final double kg;
  final DateTime measurementDate;
  final DateTime updatedAt;
}
