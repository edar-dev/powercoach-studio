import '../data/models/customer_measurement.dart';
import '../../../l10n/app_localizations.dart';

/// Plottable measurement fields for history charts and exports.
enum MeasurementMetric {
  bodyFatPercent,
  muscleMassKg,
  waistCm,
  chestCm,
  squat1RM,
  benchPress1RM,
  deadlift1RM,
}

extension MeasurementMetricX on MeasurementMetric {
  double? valueOf(CustomerMeasurement measurement) {
    return switch (this) {
      MeasurementMetric.bodyFatPercent => measurement.bodyFatPercent,
      MeasurementMetric.muscleMassKg => measurement.muscleMassKg,
      MeasurementMetric.waistCm => measurement.waistCm,
      MeasurementMetric.chestCm => measurement.chestCm,
      MeasurementMetric.squat1RM => measurement.squat1RM,
      MeasurementMetric.benchPress1RM => measurement.benchPress1RM,
      MeasurementMetric.deadlift1RM => measurement.deadlift1RM,
    };
  }

  String label(AppLocalizations l10n) {
    return switch (this) {
      MeasurementMetric.bodyFatPercent => l10n.measurementBodyFat,
      MeasurementMetric.muscleMassKg => l10n.measurementMuscleMass,
      MeasurementMetric.waistCm => l10n.measurementWaist,
      MeasurementMetric.chestCm => l10n.measurementChest,
      MeasurementMetric.squat1RM => l10n.measurementSquat,
      MeasurementMetric.benchPress1RM => l10n.measurementBench,
      MeasurementMetric.deadlift1RM => l10n.measurementDeadlift,
    };
  }
}

List<MeasurementMetric> measurementMetricsWithData(
  List<CustomerMeasurement> measurements,
) {
  return MeasurementMetric.values
      .where((metric) => measurements.any((m) => metric.valueOf(m) != null))
      .toList();
}
