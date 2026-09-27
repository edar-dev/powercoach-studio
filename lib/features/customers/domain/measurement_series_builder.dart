import '../data/models/customer_measurement.dart';
import 'measurement_metric.dart';

const int kMeasurementSeriesMaxPoints = 200;

/// Chart / list time window for measurement history surfaces.
enum MeasurementHistoryRange {
  days30,
  months3,
  months6,
  all;

  int? get lookbackDays => switch (this) {
        MeasurementHistoryRange.days30 => 30,
        MeasurementHistoryRange.months3 => 90,
        MeasurementHistoryRange.months6 => 180,
        MeasurementHistoryRange.all => null,
      };
}

class MeasurementChartPoint {
  const MeasurementChartPoint({required this.date, required this.value});

  final DateTime date;
  final double value;
}

class MeasurementSeriesBuilder {
  const MeasurementSeriesBuilder._();

  static List<MeasurementChartPoint> buildSeries(
    List<CustomerMeasurement> measurements,
    MeasurementMetric metric, {
    MeasurementHistoryRange range = MeasurementHistoryRange.all,
    DateTime? referenceDate,
  }) {
    final sorted = List<CustomerMeasurement>.from(measurements)
      ..sort((a, b) => a.measurementDate.compareTo(b.measurementDate));

    final lookback = range.lookbackDays;
    final clock = referenceDate ?? DateTime.now();
    final today = DateTime(clock.year, clock.month, clock.day);
    final cutoff = lookback == null
        ? null
        : today.subtract(Duration(days: lookback));

    final points = <MeasurementChartPoint>[];
    for (final measurement in sorted) {
      final value = metric.valueOf(measurement);
      if (value == null) {
        continue;
      }
      final day = DateTime(
        measurement.measurementDate.year,
        measurement.measurementDate.month,
        measurement.measurementDate.day,
      );
      if (cutoff != null && day.isBefore(cutoff)) {
        continue;
      }
      points.add(
        MeasurementChartPoint(
          date: day,
          value: value,
        ),
      );
    }

    if (points.length <= kMeasurementSeriesMaxPoints) {
      return points;
    }
    return _downsample(points, kMeasurementSeriesMaxPoints);
  }

  static List<MeasurementChartPoint> _downsample(
    List<MeasurementChartPoint> points,
    int maxPoints,
  ) {
    if (points.length <= maxPoints) {
      return points;
    }
    final step = points.length / maxPoints;
    final sampled = <MeasurementChartPoint>[];
    for (var i = 0; i < maxPoints; i++) {
      final index = (i * step).floor().clamp(0, points.length - 1);
      sampled.add(points[index]);
    }
    return sampled;
  }
}
