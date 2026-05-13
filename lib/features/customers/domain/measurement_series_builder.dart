import '../data/models/customer_measurement.dart';
import 'measurement_metric.dart';

const int kMeasurementSeriesMaxPoints = 200;

class MeasurementChartPoint {
  const MeasurementChartPoint({required this.date, required this.value});

  final DateTime date;
  final double value;
}

class MeasurementSeriesBuilder {
  const MeasurementSeriesBuilder._();

  static List<MeasurementChartPoint> buildSeries(
    List<CustomerMeasurement> measurements,
    MeasurementMetric metric,
  ) {
    final sorted = List<CustomerMeasurement>.from(measurements)
      ..sort((a, b) => a.measurementDate.compareTo(b.measurementDate));

    final points = <MeasurementChartPoint>[];
    for (final measurement in sorted) {
      final value = metric.valueOf(measurement);
      if (value == null) {
        continue;
      }
      points.add(
        MeasurementChartPoint(
          date: DateTime(
            measurement.measurementDate.year,
            measurement.measurementDate.month,
            measurement.measurementDate.day,
          ),
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
