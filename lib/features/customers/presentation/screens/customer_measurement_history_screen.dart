import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/export/export_artifact.dart';
import '../../../../core/export/export_share.dart';
import '../../../../core/pdf/pdf_coach_header.dart';
import '../../../../core/pdf/pdf_export_labels_l10n.dart';
import '../../../../core/storage/local_user_profile_store.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/app_snackbar.dart';
import '../../../../widgets/pdf_export_progress_dialog.dart';
import '../../data/customer_measurement_repository.dart';
import '../../data/models/customer_measurement.dart';
import '../../domain/export_measurement_csv_usecase.dart';
import '../../domain/export_measurement_pdf_usecase.dart';
import '../../domain/measurement_metric.dart';
import '../../domain/measurement_period_compare.dart';
import '../../domain/measurement_series_builder.dart';
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
  final CustomerMeasurementRepository _repository = CustomerMeasurementRepository();

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
      if (!mounted) {
        return;
      }
      final metrics = measurementMetricsWithData(measurements);
      setState(() {
        _measurements = measurements;
        _loading = false;
        _selectedMetric = _selectedMetric != null && metrics.contains(_selectedMetric)
            ? _selectedMetric
            : (metrics.isNotEmpty ? metrics.first : null);
      });
    } catch (error, stackTrace) {
      await Sentry.captureException(error, stackTrace: stackTrace);
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _shareExport(
    Future<ExportArtifact> Function() export, {
    bool showProgress = false,
  }) async {
    final l10n = AppLocalizations.of(context);
    final labels = l10n.toPdfExportLabels();
    if (showProgress) {
      await showPdfExportProgressDialog(
        context,
        message: labels.exportGenerating,
      );
    }
    try {
      final artifact = await export();
      if (showProgress && mounted) {
        hidePdfExportProgressDialog(context);
      }
      await shareExportArtifact(artifact);
      if (!mounted) {
        return;
      }
      showAppSnackBar(context, content: Text(l10n.measurementExportSuccess));
    } catch (error, stackTrace) {
      if (showProgress && mounted) {
        hidePdfExportProgressDialog(context);
      }
      await Sentry.captureException(error, stackTrace: stackTrace);
      if (!mounted) {
        return;
      }
      showAppSnackBar(
        context,
        content: Text(l10n.measurementExportError),
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
      );
    }
  }

  Future<PdfCoachHeaderInfo> _resolvePdfCoachHeader() async {
    final labels = AppLocalizations.of(context).toPdfExportLabels();
    final uid = Supabase.instance.client.auth.currentUser?.id ?? '';
    final profile = await LocalUserProfileStore.instance.read(uid);
    final email = Supabase.instance.client.auth.currentUser?.email;
    return buildPdfCoachHeader(
      labels: labels,
      profile: profile,
      authEmail: email,
    );
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
                  _shareExport(
                    () => exportMeasurementsToCsv(_measurements, baseName),
                  );
                } else if (value == 'pdf') {
                  final labels = l10n.toPdfExportLabels();
                  _shareExport(
                    showProgress: true,
                    () async {
                      final header = await _resolvePdfCoachHeader();
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
              Icon(Icons.show_chart, size: 48, color: colorScheme.onSurfaceVariant),
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
        : MeasurementPeriodCompare.compareLast30Days(_measurements, selectedMetric);

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
                if (metric == null) {
                  return;
                }
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
          _PeriodCompareCard(
            delta: periodDelta,
            metricLabel: selectedMetric?.label(l10n) ?? '',
          ),
        ],
      ),
    );
  }
}

class _PeriodCompareCard extends StatelessWidget {
  const _PeriodCompareCard({
    required this.delta,
    required this.metricLabel,
  });

  final MeasurementPeriodDelta delta;
  final String metricLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final percent = delta.percentChange;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.measurementHistoryCompareTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.measurementHistoryCompareSubtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            if (delta.recentCount == 0 && delta.previousCount == 0)
              Text(
                l10n.measurementHistoryCompareInsufficient,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            else ...[
              _CompareRow(
                label: l10n.measurementHistoryCompareRecent,
                value: delta.recentAverage,
                count: delta.recentCount,
              ),
              const SizedBox(height: 8),
              _CompareRow(
                label: l10n.measurementHistoryComparePrevious,
                value: delta.previousAverage,
                count: delta.previousCount,
              ),
              if (percent != null) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.measurementHistoryCompareDelta(
                    metricLabel,
                    _formatSignedPercent(percent),
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: percent <= 0 ? colorScheme.tertiary : colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  String _formatSignedPercent(double value) {
    final sign = value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(1)}%';
  }
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({
    required this.label,
    required this.value,
    required this.count,
  });

  final String label;
  final double? value;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final valueLabel = value == null
        ? l10n.measurementHistoryCompareNoData
        : value!.toStringAsFixed(1);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Text(
          valueLabel,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(width: 8),
        Text(
          l10n.measurementHistoryCompareSampleCount(count),
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
