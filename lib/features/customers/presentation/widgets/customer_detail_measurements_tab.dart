import 'package:flutter/material.dart';
import 'package:powercoach_studio/core/routing/app_navigation.dart';
import 'package:powercoach_studio/core/theme/marketing_dark_colors.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import 'package:powercoach_studio/core/ui/widgets/app_snackbar.dart';
import 'package:powercoach_studio/features/customers/data/customer_measurement_repository.dart';
import 'package:powercoach_studio/features/customers/data/models/customer_measurement.dart';
import 'package:powercoach_studio/features/customers/domain/customer_overview_metrics.dart';
import 'package:powercoach_studio/features/customers/domain/measurement_metric.dart';
import 'package:powercoach_studio/features/customers/domain/measurement_series_builder.dart';
import 'package:powercoach_studio/features/customers/presentation/screens/customer_measurement_form_screen.dart';
import 'package:powercoach_studio/features/customers/presentation/widgets/measurement_history_chart.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

class CustomerDetailMeasurementsTab extends StatefulWidget {
  const CustomerDetailMeasurementsTab({
    super.key,
    required this.customerId,
    required this.measurements,
    required this.loading,
    required this.measurementRepo,
    required this.onReload,
    this.customerName,
  });

  final String customerId;
  final List<CustomerMeasurement> measurements;
  final bool loading;
  final CustomerMeasurementRepository measurementRepo;
  final VoidCallback onReload;
  final String? customerName;

  @override
  State<CustomerDetailMeasurementsTab> createState() =>
      _CustomerDetailMeasurementsTabState();
}

class _CustomerDetailMeasurementsTabState
    extends State<CustomerDetailMeasurementsTab> {
  MeasurementMetric? _selectedMetric;
  MeasurementHistoryRange _range = MeasurementHistoryRange.days30;

  @override
  void didUpdateWidget(covariant CustomerDetailMeasurementsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.measurements != widget.measurements) {
      _syncMetricSelection();
    }
  }

  @override
  void initState() {
    super.initState();
    _syncMetricSelection();
  }

  void _syncMetricSelection() {
    final metrics = measurementMetricsWithData(widget.measurements);
    if (metrics.isEmpty) {
      _selectedMetric = null;
      return;
    }
    if (_selectedMetric == null || !metrics.contains(_selectedMetric)) {
      _selectedMetric = metrics.first;
    }
  }

  CustomerMeasurement? _previousFor(CustomerMeasurement? current) {
    if (widget.measurements.isEmpty) return null;
    final sorted = List<CustomerMeasurement>.from(widget.measurements)
      ..sort((a, b) => b.measurementDate.compareTo(a.measurementDate));
    if (current == null) return sorted.first;
    final idx = sorted.indexWhere((m) => m.id == current.id);
    if (idx < 0 || idx + 1 >= sorted.length) return null;
    return sorted[idx + 1];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (widget.loading) {
      return const Center(
        child: CircularProgressIndicator(color: MarketingDarkColors.brandLight),
      );
    }
    if (widget.measurements.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.straighten,
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
                style: const TextStyle(
                  fontSize: 13,
                  color: MarketingDarkColors.slate500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _openForm(context),
                icon: const Icon(Icons.add),
                label: Text(l10n.measurementAdd),
                style: FilledButton.styleFrom(
                  backgroundColor: MarketingDarkColors.brand,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final metrics = measurementMetricsWithData(widget.measurements);
    final selected = _selectedMetric;
    final points = selected == null
        ? const <MeasurementChartPoint>[]
        : MeasurementSeriesBuilder.buildSeries(
            widget.measurements,
            selected,
            range: _range,
          );
    final currentValue = points.isEmpty ? null : points.last.value;
    final sorted = List<CustomerMeasurement>.from(widget.measurements)
      ..sort((a, b) => b.measurementDate.compareTo(a.measurementDate));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      children: [
        _Toolbar(
          l10n: l10n,
          metrics: metrics,
          selectedMetric: selected,
          range: _range,
          onMetricChanged: (m) => setState(() => _selectedMetric = m),
          onRangeChanged: (r) => setState(() => _range = r),
          onOpenHistory: _openHistory,
          onAdd: () => _openForm(context),
        ),
        const SizedBox(height: 16),
        if (selected != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MarketingDarkColors.surfaceElevated,
              borderRadius:
                  BorderRadius.circular(MarketingDarkColors.radius2xl),
              border: Border.all(color: MarketingDarkColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.measurementHistoryCurrentValue,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: MarketingDarkColors.slate400,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  currentValue == null
                      ? '—'
                      : '${CustomerOverviewMetrics.formatMetricValue(currentValue, isPercent: selected == MeasurementMetric.bodyFatPercent)}${_unitSuffix(selected)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: MarketingDarkColors.text,
                  ),
                ),
                const SizedBox(height: 12),
                if (points.isEmpty)
                  Text(
                    measurementHistoryNoMetricDataMessage(l10n),
                    style: const TextStyle(
                      color: MarketingDarkColors.slate400,
                    ),
                  )
                else
                  MeasurementHistoryChart(
                    points: points,
                    metricLabel: selected.label(l10n),
                    dateAxisLabel: l10n.measurementDate,
                    valueAxisLabel: selected.label(l10n),
                    dark: true,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        Text(
          l10n.measurementHistoryRegistered,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: MarketingDarkColors.text,
          ),
        ),
        const SizedBox(height: 12),
        for (final m in sorted)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _MeasurementCard(
              measurement: m,
              onTap: () async {
                final updated = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (ctx) => CustomerMeasurementFormScreen(
                      customerId: widget.customerId,
                      measurement: m,
                      customerName: widget.customerName,
                      previousMeasurement: _previousFor(m),
                    ),
                  ),
                );
                if (updated == true) widget.onReload();
              },
              onLongPress: () => _confirmDelete(context, m),
            ),
          ),
      ],
    );
  }

  void _openHistory() {
    final name = widget.customerName?.trim();
    final uri = name == null || name.isEmpty
        ? '/customers/${widget.customerId}/measurements/history'
        : '/customers/${widget.customerId}/measurements/history?customerName=${Uri.encodeComponent(name)}';
    navigateTo(context, uri);
  }

  String _unitSuffix(MeasurementMetric metric) {
    return switch (metric) {
      MeasurementMetric.bodyFatPercent => '%',
      MeasurementMetric.waistCm || MeasurementMetric.chestCm => ' cm',
      _ => ' kg',
    };
  }

  Future<void> _openForm(BuildContext context) async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (ctx) => CustomerMeasurementFormScreen(
          customerId: widget.customerId,
          customerName: widget.customerName,
          previousMeasurement: _previousFor(null),
        ),
      ),
    );
    if (added == true) widget.onReload();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    CustomerMeasurement measurement,
  ) async {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final confirm = await showAppConfirmDialog(
      context: context,
      title: l10n.measurementDeleteConfirm,
      message: '',
      confirmLabel: l10n.customerDelete,
      cancelLabel: l10n.customerCancel,
      destructive: true,
    );
    if (!confirm || !context.mounted) return;
    try {
      await widget.measurementRepo.delete(widget.customerId, measurement.id);
      if (!context.mounted) return;
      showAppSnackBar(context, content: Text(l10n.measurementDeleted));
      widget.onReload();
    } catch (_) {
      if (!context.mounted) return;
      showAppSnackBar(
        context,
        content: Text(l10n.measurementDeleteError),
        backgroundColor: colorScheme.errorContainer,
      );
    }
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.l10n,
    required this.metrics,
    required this.selectedMetric,
    required this.range,
    required this.onMetricChanged,
    required this.onRangeChanged,
    required this.onOpenHistory,
    required this.onAdd,
  });

  final AppLocalizations l10n;
  final List<MeasurementMetric> metrics;
  final MeasurementMetric? selectedMetric;
  final MeasurementHistoryRange range;
  final ValueChanged<MeasurementMetric> onMetricChanged;
  final ValueChanged<MeasurementHistoryRange> onRangeChanged;
  final VoidCallback onOpenHistory;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (metrics.isNotEmpty)
          DropdownButtonFormField<MeasurementMetric>(
            initialValue: selectedMetric,
            dropdownColor: MarketingDarkColors.surface800,
            style: const TextStyle(color: MarketingDarkColors.text, fontSize: 14),
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
              onMetricChanged(metric);
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
                selected: range == r,
                onSelected: (_) => onRangeChanged(r),
                selectedColor: MarketingDarkColors.brand.withValues(alpha: 0.25),
                backgroundColor: MarketingDarkColors.surface800,
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: range == r
                      ? MarketingDarkColors.brandSoft
                      : MarketingDarkColors.slate400,
                ),
                side: BorderSide(
                  color: range == r
                      ? MarketingDarkColors.brandMid
                      : MarketingDarkColors.border,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onOpenHistory,
                icon: const Icon(Icons.show_chart, size: 18),
                label: Text(l10n.measurementHistoryOpenFull),
                style: OutlinedButton.styleFrom(
                  foregroundColor: MarketingDarkColors.slate300,
                  side: const BorderSide(color: MarketingDarkColors.borderMuted),
                  backgroundColor: MarketingDarkColors.surfaceElevated,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.measurementAdd),
                style: FilledButton.styleFrom(
                  backgroundColor: MarketingDarkColors.brand,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
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

class _MeasurementCard extends StatelessWidget {
  const _MeasurementCard({
    required this.measurement,
    required this.onTap,
    required this.onLongPress,
  });

  final CustomerMeasurement measurement;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final dateStr = CustomerMeasurement.toDateString(measurement.measurementDate);
    final summary = [
      if (measurement.squat1RM != null) 'S ${measurement.squat1RM}',
      if (measurement.benchPress1RM != null) 'B ${measurement.benchPress1RM}',
      if (measurement.deadlift1RM != null) 'D ${measurement.deadlift1RM}',
      if (measurement.bodyFatPercent != null)
        'BF ${measurement.bodyFatPercent}%',
    ].join(' · ');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: MarketingDarkColors.surfaceElevated,
            borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
            border: Border.all(color: MarketingDarkColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: MarketingDarkColors.text,
                      ),
                    ),
                    if (summary.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        summary,
                        style: const TextStyle(
                          fontSize: 12,
                          color: MarketingDarkColors.slate400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: MarketingDarkColors.slate500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
