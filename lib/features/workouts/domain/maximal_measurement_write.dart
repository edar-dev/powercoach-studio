import '../../customers/data/customer_measurement_repository.dart';
import '../../customers/data/models/customer_measurement.dart';
import 'maximal_ref.dart';

/// Writes a big-3 1RM from the builder Massimali flow.
///
/// Prefers updating the **latest** measurement row (by [CustomerMeasurement.measurementDate],
/// then [CustomerMeasurement.updatedAt]). If none exist, creates a new measurement with
/// only that lift set.
Future<CustomerMeasurement> upsertMeasurementLift1Rm({
  required CustomerMeasurementRepository repository,
  required String customerId,
  required MaximalLift lift,
  required double weightKg,
}) async {
  final list = await repository.getByCustomerId(customerId);
  final sorted = List<CustomerMeasurement>.from(list)
    ..sort((a, b) {
      final byDate = b.measurementDate.compareTo(a.measurementDate);
      if (byDate != 0) return byDate;
      return b.updatedAt.compareTo(a.updatedAt);
    });

  final field = _liftJsonKey(lift);
  if (sorted.isNotEmpty) {
    final latest = sorted.first;
    return repository.update(customerId, latest.id, {
      field: weightKg,
      'expectedRowVersion': latest.rowVersion,
    });
  }

  return repository.create(customerId, {
    'measurementDate': CustomerMeasurement.toDateString(DateTime.now()),
    field: weightKg,
  });
}

String _liftJsonKey(MaximalLift lift) {
  switch (lift) {
    case MaximalLift.squat:
      return 'squat1RM';
    case MaximalLift.bench:
      return 'benchPress1RM';
    case MaximalLift.deadlift:
      return 'deadlift1RM';
  }
}
