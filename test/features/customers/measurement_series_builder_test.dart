import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/customers/data/models/customer_measurement.dart';
import 'package:powercoach_studio/features/customers/domain/measurement_metric.dart';
import 'package:powercoach_studio/features/customers/domain/measurement_series_builder.dart';

CustomerMeasurement _measurement({
  required String id,
  required DateTime date,
  double? bodyFatPercent,
  double? muscleMassKg,
}) {
  final stamp = DateTime(2026, 1, 1);
  return CustomerMeasurement(
    id: id,
    customerId: 'c1',
    userId: 'u1',
    measurementDate: date,
    bodyFatPercent: bodyFatPercent,
    muscleMassKg: muscleMassKg,
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

    test('builds muscle mass series', () {
      final points = MeasurementSeriesBuilder.buildSeries(
        [
          _measurement(
            id: 'a',
            date: DateTime(2026, 5, 1),
            muscleMassKg: 38,
          ),
          _measurement(
            id: 'b',
            date: DateTime(2026, 5, 15),
            muscleMassKg: 39,
          ),
        ],
        MeasurementMetric.muscleMassKg,
      );

      expect(points, hasLength(2));
      expect(points.last.value, 39);
    });
  });
}
