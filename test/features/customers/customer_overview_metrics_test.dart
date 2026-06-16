import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/customers/data/models/customer.dart';
import 'package:powercoach_studio/features/customers/data/models/customer_measurement.dart';
import 'package:powercoach_studio/features/customers/domain/customer_overview_metrics.dart';
import 'package:powercoach_studio/features/customers/domain/measurement_metric.dart';

Customer _customer({double? weightKg}) {
  return Customer(
    id: 'c1',
    userId: 'u1',
    name: 'Marco',
    weightKg: weightKg,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

CustomerMeasurement _measurement({
  required DateTime date,
  double? muscleMassKg,
  double? bodyFatPercent,
}) {
  return CustomerMeasurement(
    id: 'm-${date.millisecondsSinceEpoch}',
    customerId: 'c1',
    userId: 'u1',
    measurementDate: date,
    muscleMassKg: muscleMassKg,
    bodyFatPercent: bodyFatPercent,
    createdAt: date,
    updatedAt: date,
  );
}

void main() {
  group('CustomerOverviewMetrics', () {
    test('uses profile weight and latest muscle mass', () {
      final snapshot = CustomerOverviewMetrics.build(
        customer: _customer(weightKg: 82),
        measurements: [
          _measurement(
            date: DateTime(2026, 5, 1),
            muscleMassKg: 38,
          ),
          _measurement(
            date: DateTime(2026, 5, 10),
            muscleMassKg: 39,
          ),
        ],
        muscleMassLabel: 'Muscle Mass',
        bodyFatLabel: 'Body fat',
      );

      expect(snapshot.weightKg, 82);
      expect(snapshot.weightFromProfile, isTrue);
      expect(snapshot.secondaryValue, 39);
      expect(snapshot.hasMeasurements, isTrue);
      expect(snapshot.sparklineMetric, MeasurementMetric.muscleMassKg);
      expect(snapshot.sparklinePoints.length, 2);
    });

    test('showSecondaryTrend requires at least two recent samples', () {
      final snapshot = CustomerOverviewMetrics.build(
        customer: _customer(),
        measurements: [
          _measurement(
            date: DateTime(2026, 5, 10),
            muscleMassKg: 39,
          ),
        ],
        muscleMassLabel: 'Muscle Mass',
        bodyFatLabel: 'Body fat',
      );

      expect(snapshot.showSecondaryTrend, isFalse);
    });

    test('formatTrendPercent includes sign', () {
      expect(
        CustomerOverviewMetrics.formatTrendPercent(2.34),
        '+2.3%',
      );
      expect(
        CustomerOverviewMetrics.formatTrendPercent(-1.2),
        '-1.2%',
      );
    });

    test('empty measurements shows no sparkline', () {
      final snapshot = CustomerOverviewMetrics.build(
        customer: _customer(weightKg: 75),
        measurements: const [],
        muscleMassLabel: 'Muscle Mass',
        bodyFatLabel: 'Body fat',
      );

      expect(snapshot.hasMeasurements, isFalse);
      expect(snapshot.sparklinePoints, isEmpty);
      expect(snapshot.secondaryValue, isNull);
    });
  });
}
