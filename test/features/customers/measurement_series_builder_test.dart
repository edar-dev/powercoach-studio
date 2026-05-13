import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/customers/data/models/customer_measurement.dart';
import 'package:powercoach_studio/features/customers/domain/measurement_metric.dart';
import 'package:powercoach_studio/features/customers/domain/measurement_period_compare.dart';
import 'package:powercoach_studio/features/customers/domain/measurement_series_builder.dart';

CustomerMeasurement _measurement({
  required String id,
  required DateTime date,
  double? bodyFatPercent,
  double? waistCm,
}) {
  final stamp = DateTime(2026, 1, 1);
  return CustomerMeasurement(
    id: id,
    customerId: 'c1',
    userId: 'u1',
    measurementDate: date,
    bodyFatPercent: bodyFatPercent,
    waistCm: waistCm,
    createdAt: stamp,
    updatedAt: stamp,
  );
}

void main() {
  group('MeasurementSeriesBuilder', () {
    test('sorts points by date and ignores null values', () {
      final points = MeasurementSeriesBuilder.buildSeries(
        [
          _measurement(id: '2', date: DateTime(2026, 2, 1), bodyFatPercent: 18),
          _measurement(id: '1', date: DateTime(2026, 1, 1), bodyFatPercent: 20),
          _measurement(id: '3', date: DateTime(2026, 3, 1)),
        ],
        MeasurementMetric.bodyFatPercent,
      );

      expect(points, hasLength(2));
      expect(points.first.date, DateTime(2026, 1, 1));
      expect(points.last.value, 18);
    });
  });

  group('MeasurementPeriodCompare', () {
    test('computes averages for recent and previous 30-day windows', () {
      final reference = DateTime(2026, 5, 31);
      final delta = MeasurementPeriodCompare.compareLast30Days(
        [
          _measurement(
            id: 'recent',
            date: DateTime(2026, 5, 20),
            waistCm: 80,
          ),
          _measurement(
            id: 'previous',
            date: DateTime(2026, 4, 20),
            waistCm: 90,
          ),
        ],
        MeasurementMetric.waistCm,
        referenceDate: reference,
      );

      expect(delta.recentAverage, 80);
      expect(delta.previousAverage, 90);
      expect(delta.percentChange, closeTo(-11.111, 0.01));
    });
  });
}
