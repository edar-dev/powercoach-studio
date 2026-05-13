import '../data/models/customer_measurement.dart';
import 'measurement_metric.dart';

class MeasurementPeriodDelta {
  const MeasurementPeriodDelta({
    required this.recentAverage,
    required this.previousAverage,
    required this.recentCount,
    required this.previousCount,
  });

  final double? recentAverage;
  final double? previousAverage;
  final int recentCount;
  final int previousCount;

  double? get percentChange {
    final previous = previousAverage;
    final recent = recentAverage;
    if (previous == null || recent == null || previous == 0) {
      return null;
    }
    return ((recent - previous) / previous) * 100;
  }
}

class MeasurementPeriodCompare {
  const MeasurementPeriodCompare._();

  static MeasurementPeriodDelta compareLast30Days(
    List<CustomerMeasurement> measurements,
    MeasurementMetric metric, {
    DateTime? referenceDate,
  }) {
    final reference = referenceDate ?? DateTime.now();
    final today = DateTime(reference.year, reference.month, reference.day);
    final recentStart = today.subtract(const Duration(days: 30));
    final previousStart = today.subtract(const Duration(days: 60));

    final recentValues = <double>[];
    final previousValues = <double>[];

    for (final measurement in measurements) {
      final value = metric.valueOf(measurement);
      if (value == null) {
        continue;
      }
      final day = DateTime(
        measurement.measurementDate.year,
        measurement.measurementDate.month,
        measurement.measurementDate.day,
      );
      if (!day.isBefore(recentStart) && !day.isAfter(today)) {
        recentValues.add(value);
      } else if (!day.isBefore(previousStart) && day.isBefore(recentStart)) {
        previousValues.add(value);
      }
    }

    return MeasurementPeriodDelta(
      recentAverage: _average(recentValues),
      previousAverage: _average(previousValues),
      recentCount: recentValues.length,
      previousCount: previousValues.length,
    );
  }

  static double? _average(List<double> values) {
    if (values.isEmpty) {
      return null;
    }
    return values.reduce((a, b) => a + b) / values.length;
  }
}
