import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../core/pdf/pdf_export_labels_l10n.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/customer_measurement_repository.dart';
import '../../data/models/customer_measurement.dart';
import '../../domain/export_measurement_csv_usecase.dart';
import '../../domain/export_measurement_pdf_usecase.dart';
import '../../domain/measurement_metric.dart';
import '../../domain/measurement_period_compare.dart';
import '../../domain/measurement_series_builder.dart';
import '../customer_measurement_history_export.dart';
import '../widgets/measurement_history_chart.dart';
import '../widgets/measurement_history_period_compare_card.dart';

class CustomerMeasurementHistoryScreen extends StatefulWidget {
  const CustomerMeasurementHistoryScreen({
    super.key,
    required this.customerId,
    this.customerName,
  });

  final String customerId;
  final String? customerName;

  @override
  State<CustomerMeasurementHistoryScreen> createState() =>
      _CustomerMeasurementHistoryScreenState();
}

class _CustomerMeasurementHistoryScreenState
    extends State<CustomerMeasurementHistoryScreen> {
  final CustomerMeasurementRepository _repository =
      CustomerMeasurementRepository();

  List<CustomerMeasurement> _measurements = [];
  MeasurementMetric? _selectedMetric;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final measurements = await _repository.getByCustomerId(widget.customerId);
      if (!mounted) return;
      final metrics = measurementMetricsWithData(measurements);
      setState(() {
        _measurements = measurements;
        _loading = false;
        _selectedMetric =
            _selectedMetric != null && metrics.contains(_selectedMetric)
            ? _selectedMetric
            : (metrics.isNotEmpty ? metrics.first : null);
      });
    } catch (error, stackTrace) {
      await Sentry.captureException(error, stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.measurementHistoryTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_measurements.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                final baseName = widget.customerName?.trim().isNotEmpty == true
                    ? widget.customerName!.trim()
                    : widget.customerId;
                if (value == 'csv') {
                  shareCustomerMeasurementExport(
                    context: context,
                    l10n: l10n,
                    export: () =>
                        exportMeasurementsToCsv(_measurements, baseName),
                  );
                } else if (value == 'pdf') {
                  final labels = l10n.toPdfExportLabels();
                  shareCustomerMeasurementExport(
                    context: context,
                    l10n: l10n,
                    showProgress: true,
                    export: () async {
                      final header =
                          await resolveCustomerMeasurementPdfCoachHeader(
                            context,
                          );
                      return exportMeasurementsToPdf(
                        _measurements,
                        l10n.measurementHistoryExportPdfTitle(baseName),
                        labels: labels,
                        coachHeader: header,
                      );
                    },
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'csv',
                  child: Text(l10n.measurementExportCsv),
                ),
                PopupMenuItem(
                  value: 'pdf',
                  child: Text(l10n.measurementExportPdf),
                ),
              ],
            ),
        ],
      ),
      body: _buildBody(context, theme, colorScheme, l10n),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                l10n.measurementHistoryLoadError,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _load,
                child: Text(l10n.customersRetry),
              ),
            ],
          ),
        ),
      );
    }
    if (_measurements.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.show_chart,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.measurementsEmpty,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.measurementsEmptyHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final metrics = measurementMetricsWithData(_measurements);
    final selectedMetric = _selectedMetric;
    final points = selectedMetric == null
        ? const <MeasurementChartPoint>[]
        : MeasurementSeriesBuilder.buildSeries(_measurements, selectedMetric);
    final periodDelta = selectedMetric == null
        ? const MeasurementPeriodDelta(
            recentAverage: null,
            previousAverage: null,
            recentCount: 0,
            previousCount: 0,
          )
        : MeasurementPeriodCompare.compareLast30Days(
            _measurements,
            selectedMetric,
          );

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (metrics.isNotEmpty)
            DropdownButtonFormField<MeasurementMetric>(
              initialValue: selectedMetric,
              decoration: InputDecoration(
                labelText: l10n.measurementHistoryMetricLabel,
                border: const OutlineInputBorder(),
              ),
              items: [
                for (final metric in metrics)
                  DropdownMenuItem(
                    value: metric,
                    child: Text(metric.label(l10n)),
                  ),
              ],
              onChanged: (metric) {
                if (metric == null) return;
                setState(() => _selectedMetric = metric);
              },
            ),
          const SizedBox(height: 16),
          if (selectedMetric != null && points.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  measurementHistoryNoMetricDataMessage(l10n),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else if (selectedMetric != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: MeasurementHistoryChart(
                  points: points,
                  metricLabel: selectedMetric.label(l10n),
                  dateAxisLabel: l10n.measurementDate,
                  valueAxisLabel: selectedMetric.label(l10n),
                ),
              ),
            ),
          const SizedBox(height: 16),
          MeasurementHistoryPeriodCompareCard(
            delta: periodDelta,
            metricLabel: selectedMetric?.label(l10n) ?? '',
          ),
        ],
      ),
    );
  }
}
