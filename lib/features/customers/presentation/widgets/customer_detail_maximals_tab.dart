import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/customer_maximal_repository.dart';
import '../../data/models/customer_maximal.dart';
import '../../data/models/customer_measurement.dart';

/// Read-only Massimali tab: custom maximals + latest measurement 1RMs.
class CustomerDetailMaximalsTab extends StatefulWidget {
  const CustomerDetailMaximalsTab({
    super.key,
    required this.customerId,
    required this.measurements,
    this.repository,
  });

  final String customerId;
  final List<CustomerMeasurement> measurements;
  final CustomerMaximalRepository? repository;

  @override
  State<CustomerDetailMaximalsTab> createState() =>
      _CustomerDetailMaximalsTabState();
}

class _CustomerDetailMaximalsTabState extends State<CustomerDetailMaximalsTab> {
  late final CustomerMaximalRepository _repo =
      widget.repository ?? CustomerMaximalRepository();
  List<CustomerMaximal> _maximals = const [];
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
      final list = await _repo.getByCustomerId(widget.customerId);
      if (!mounted) return;
      final sorted = List<CustomerMaximal>.from(list)
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      setState(() {
        _maximals = sorted;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'load';
      });
    }
  }

  CustomerMeasurement? get _latestMeasurement {
    if (widget.measurements.isEmpty) return null;
    final sorted = List<CustomerMeasurement>.from(widget.measurements)
      ..sort((a, b) => b.measurementDate.compareTo(a.measurementDate));
    return sorted.first;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = l10n.localeName;

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
              Text(
                l10n.maximalLoadError,
                textAlign: TextAlign.center,
                style: const TextStyle(color: MarketingDarkColors.slate300),
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

    final latest = _latestMeasurement;
    final measurementRows = <_MaximalRow>[
      if (latest?.squat1RM != null)
        _MaximalRow(
          label: l10n.measurementSquat,
          kg: latest!.squat1RM!,
          subtitle: DateFormat.yMMMd(locale).format(latest.measurementDate),
        ),
      if (latest?.benchPress1RM != null)
        _MaximalRow(
          label: l10n.measurementBench,
          kg: latest!.benchPress1RM!,
          subtitle: DateFormat.yMMMd(locale).format(latest.measurementDate),
        ),
      if (latest?.deadlift1RM != null)
        _MaximalRow(
          label: l10n.measurementDeadlift,
          kg: latest!.deadlift1RM!,
          subtitle: DateFormat.yMMMd(locale).format(latest.measurementDate),
        ),
    ];
    final customRows = [
      for (final m in _maximals)
        _MaximalRow(
          label: m.label,
          kg: m.weightKg,
          subtitle: DateFormat.yMMMd(locale).format(m.updatedAt),
        ),
    ];

    if (measurementRows.isEmpty && customRows.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.customerMaximalsEmpty,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: MarketingDarkColors.slate400,
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text(
          l10n.maximalAssociateMeasurementSection,
          style: theme.textTheme.titleSmall?.copyWith(
            color: MarketingDarkColors.text,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        if (measurementRows.isEmpty)
          Text(
            l10n.customerMaximalsMeasurementEmpty,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: MarketingDarkColors.slate500,
            ),
          )
        else
          for (final row in measurementRows) _MaximalTile(row: row),
        const SizedBox(height: 20),
        Text(
          l10n.maximalAssociateCustomSection,
          style: theme.textTheme.titleSmall?.copyWith(
            color: MarketingDarkColors.text,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        if (customRows.isEmpty)
          Text(
            l10n.maximalAssociateCustomEmpty,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: MarketingDarkColors.slate500,
            ),
          )
        else
          for (final row in customRows) _MaximalTile(row: row),
      ],
    );
  }
}

class _MaximalRow {
  const _MaximalRow({
    required this.label,
    required this.kg,
    required this.subtitle,
  });

  final String label;
  final double kg;
  final String subtitle;
}

class _MaximalTile extends StatelessWidget {
  const _MaximalTile({required this.row});

  final _MaximalRow row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: MarketingDarkColors.stitchCardElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MarketingDarkColors.stitchBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: MarketingDarkColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  row.subtitle,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: MarketingDarkColors.slate500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${row.kg.toStringAsFixed(row.kg == row.kg.roundToDouble() ? 0 : 1)} kg',
            style: theme.textTheme.titleMedium?.copyWith(
              color: MarketingDarkColors.cyanBright,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
