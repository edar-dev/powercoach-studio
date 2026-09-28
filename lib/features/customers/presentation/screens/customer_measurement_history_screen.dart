import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../core/pdf/pdf_export_labels_l10n.dart';
import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/customer_measurement_repository.dart';
import '../../data/models/customer_measurement.dart';
import '../../domain/export_measurement_csv_usecase.dart';
import '../../domain/export_measurement_pdf_usecase.dart';
import '../../domain/measurement_metric.dart';
import '../../domain/measurement_series_builder.dart';
import '../customer_measurement_history_export.dart';
import '../widgets/measurement_history_chart.dart';

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
  MeasurementHistoryRange _range = MeasurementHistoryRange.all;
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

    return Scaffold(
      backgroundColor: MarketingDarkColors.bgAlt,
      appBar: AppBar(
        backgroundColor: MarketingDarkColors.bgAlt,
        foregroundColor: MarketingDarkColors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          l10n.measurementHistoryTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: MarketingDarkColors.text,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: MarketingDarkColors.slate300,
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_measurements.isNotEmpty)
            PopupMenuButton<String>(
              color: MarketingDarkColors.surface800,
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
                  child: Text(
                    l10n.measurementExportCsv,
                    style: const TextStyle(color: MarketingDarkColors.text),
                  ),
                ),
                PopupMenuItem(
                  value: 'pdf',
                  child: Text(
                    l10n.measurementExportPdf,
                    style: const TextStyle(color: MarketingDarkColors.text),
                  ),
                ),
              ],
            ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: ColoredBox(
            color: MarketingDarkColors.border,
            child: SizedBox(height: 1, width: double.infinity),
          ),
        ),
      ),
      body: _buildBody(context, l10n),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: MarketingDarkColors.brandLight),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Color(0xFFF87171),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.measurementHistoryLoadError,
                style: const TextStyle(color: MarketingDarkColors.text),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _load,
                style: FilledButton.styleFrom(
                  backgroundColor: MarketingDarkColors.brand,
                ),
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
              const Icon(
                Icons.show_chart,
                size: 48,
                color: MarketingDarkColors.slate500,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.measurementsEmpty,
                style: const TextStyle(
                  fontSize: 16,
                  color: MarketingDarkColors.slate300,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.measurementsEmptyHint,
                style: const TextStyle(color: MarketingDarkColors.slate500),
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
        : MeasurementSeriesBuilder.buildSeries(
            _measurements,
            selectedMetric,
            range: _range,
          );

    return RefreshIndicator(
      color: MarketingDarkColors.brandLight,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (metrics.isNotEmpty)
            DropdownButtonFormField<MeasurementMetric>(
              initialValue: selectedMetric,
              dropdownColor: MarketingDarkColors.surface800,
              style: const TextStyle(color: MarketingDarkColors.text),
              decoration: InputDecoration(
                labelText: l10n.measurementHistoryMetricLabel,
                labelStyle: const TextStyle(color: MarketingDarkColors.slate400),
                filled: true,
                fillColor: MarketingDarkColors.surfaceInput,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(MarketingDarkColors.radiusXl),
                  borderSide:
                      const BorderSide(color: MarketingDarkColors.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(MarketingDarkColors.radiusXl),
                  borderSide:
                      const BorderSide(color: MarketingDarkColors.borderSubtle),
                ),
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final r in MeasurementHistoryRange.values)
                ChoiceChip(
                  label: Text(_rangeLabel(l10n, r)),
                  selected: _range == r,
                  onSelected: (_) => setState(() => _range = r),
                  selectedColor:
                      MarketingDarkColors.brand.withValues(alpha: 0.25),
                  backgroundColor: MarketingDarkColors.surface800,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _range == r
                        ? MarketingDarkColors.brandSoft
                        : MarketingDarkColors.slate400,
                  ),
                  side: BorderSide(
                    color: _range == r
                        ? MarketingDarkColors.brandMid
                        : MarketingDarkColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (selectedMetric != null && points.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MarketingDarkColors.surfaceElevated,
                borderRadius:
                    BorderRadius.circular(MarketingDarkColors.radiusXl),
                border: Border.all(color: MarketingDarkColors.border),
              ),
              child: Text(
                measurementHistoryNoMetricDataMessage(l10n),
                style: const TextStyle(color: MarketingDarkColors.slate400),
              ),
            )
          else if (selectedMetric != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MarketingDarkColors.surfaceElevated,
                borderRadius:
                    BorderRadius.circular(MarketingDarkColors.radius2xl),
                border: Border.all(color: MarketingDarkColors.borderSubtle),
              ),
              child: MeasurementHistoryChart(
                points: points,
                metricLabel: selectedMetric.label(l10n),
                dateAxisLabel: l10n.measurementDate,
                valueAxisLabel: selectedMetric.label(l10n),
                dark: true,
              ),
            ),
        ],
      ),
    );
  }

  String _rangeLabel(AppLocalizations l10n, MeasurementHistoryRange range) {
    return switch (range) {
      MeasurementHistoryRange.days30 => l10n.measurementHistoryRange30d,
      MeasurementHistoryRange.months3 => l10n.measurementHistoryRange3m,
      MeasurementHistoryRange.months6 => l10n.measurementHistoryRange6m,
      MeasurementHistoryRange.all => l10n.measurementHistoryRangeAll,
    };
  }
}
