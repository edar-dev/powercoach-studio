import '../data/models/customer.dart';
import '../data/models/customer_measurement.dart';
import 'measurement_metric.dart';
import 'measurement_period_compare.dart';
import 'measurement_series_builder.dart';

/// Display-ready metrics for the customer overview tab.
class CustomerOverviewSnapshot {
  const CustomerOverviewSnapshot({
    required this.weightKg,
    required this.weightFromProfile,
    required this.secondaryLabel,
    required this.secondaryValue,
    required this.secondaryUnit,
    required this.secondaryTrend,
    required this.sparklinePoints,
    required this.sparklineMetric,
    required this.lastMeasurementDate,
    required this.hasMeasurements,
  });

  final double? weightKg;
  final bool weightFromProfile;
  final String secondaryLabel;
  final double? secondaryValue;
  final String secondaryUnit;
  final MeasurementPeriodDelta? secondaryTrend;
  final List<MeasurementChartPoint> sparklinePoints;
  final MeasurementMetric? sparklineMetric;
  final DateTime? lastMeasurementDate;
  final bool hasMeasurements;

  bool get showSecondaryTrend {
    final trend = secondaryTrend;
    if (trend == null) return false;
    return trend.percentChange != null && trend.recentCount >= 2;
  }
}

class CustomerOverviewMetrics {
  const CustomerOverviewMetrics._();

  static CustomerOverviewSnapshot build({
    required Customer customer,
    required List<CustomerMeasurement> measurements,
    required String muscleMassLabel,
    required String bodyFatLabel,
  }) {
    final sorted = List<CustomerMeasurement>.from(measurements)
      ..sort((a, b) => b.measurementDate.compareTo(a.measurementDate));

    final latest = sorted.isEmpty ? null : sorted.first;
    final lastDate = latest?.measurementDate;

    final muscleMass = latest?.muscleMassKg;
    final bodyFat = latest?.bodyFatPercent;

    final secondaryMetric = muscleMass != null
        ? MeasurementMetric.muscleMassKg
        : (bodyFat != null ? MeasurementMetric.bodyFatPercent : null);

    final secondaryLabel = secondaryMetric == MeasurementMetric.muscleMassKg
        ? muscleMassLabel
        : (secondaryMetric == MeasurementMetric.bodyFatPercent
            ? bodyFatLabel
            : muscleMassLabel);

    final secondaryValue = secondaryMetric == MeasurementMetric.muscleMassKg
        ? muscleMass
        : bodyFat;

    final secondaryUnit =
        secondaryMetric == MeasurementMetric.bodyFatPercent ? '%' : 'kg';

    MeasurementPeriodDelta? secondaryTrend;
    if (secondaryMetric != null) {
      secondaryTrend = MeasurementPeriodCompare.compareLast30Days(
        measurements,
        secondaryMetric,
      );
    }

    MeasurementMetric? sparklineMetric;
    if (measurements.any(
      (m) => m.muscleMassKg != null,
    )) {
      sparklineMetric = MeasurementMetric.muscleMassKg;
    } else if (measurements.any((m) => m.bodyFatPercent != null)) {
      sparklineMetric = MeasurementMetric.bodyFatPercent;
    } else if (measurements.any((m) => m.waistCm != null)) {
      sparklineMetric = MeasurementMetric.waistCm;
    }

    final sparklinePoints = sparklineMetric == null
        ? const <MeasurementChartPoint>[]
        : _sparklineSeries(measurements, sparklineMetric);

    return CustomerOverviewSnapshot(
      weightKg: customer.weightKg,
      weightFromProfile: customer.weightKg != null,
      secondaryLabel: secondaryLabel,
      secondaryValue: secondaryValue,
      secondaryUnit: secondaryUnit,
      secondaryTrend: secondaryTrend,
      sparklinePoints: sparklinePoints,
      sparklineMetric: sparklineMetric,
      lastMeasurementDate: lastDate,
      hasMeasurements: sorted.isNotEmpty,
    );
  }

  static List<MeasurementChartPoint> _sparklineSeries(
    List<CustomerMeasurement> measurements,
    MeasurementMetric metric,
  ) {
    final series = MeasurementSeriesBuilder.buildSeries(measurements, metric);
    if (series.length <= 8) {
      return series;
    }
    return series.sublist(series.length - 8);
  }

  static String formatTrendPercent(double percent) {
    final sign = percent > 0 ? '+' : '';
    return '$sign${percent.toStringAsFixed(1)}%';
  }

  static String formatMetricValue(double value, {required bool isPercent}) {
    if (isPercent) {
      return value.toStringAsFixed(1);
    }
    final rounded = value.roundToDouble();
    if ((value - rounded).abs() < 0.05) {
      return rounded.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }
}
