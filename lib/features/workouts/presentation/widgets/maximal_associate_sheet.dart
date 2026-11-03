import 'package:flutter/material.dart';

import '../../../../core/ui/widgets/app_sheet.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../customers/data/customer_maximal_repository.dart';
import '../../../customers/data/customer_measurement_repository.dart';
import '../../../customers/data/models/customer_maximal.dart';
import '../../../customers/data/models/customer_measurement.dart';
import '../../domain/maximal_kg_resolver.dart';
import '../../domain/maximal_load_math.dart';
import '../../domain/maximal_ref.dart';
import 'maximal_custom_form_sheet.dart';
import 'maximal_measurement_1rm_sheet.dart';

/// Outcome of the associate / Imposta massimale sheet.
class MaximalAssociateResult {
  const MaximalAssociateResult.set(this.ref) : cleared = false;

  const MaximalAssociateResult.clear()
      : ref = null,
        cleared = true;

  final MaximalRef? ref;
  final bool cleared;
}

/// Opens the associate sheet: pick measurement lift, existing/new custom, or clear.
///
/// Returns null when dismissed without a choice.
Future<MaximalAssociateResult?> showMaximalAssociateSheet(
  BuildContext context, {
  required String customerId,
  MaximalRef? currentRef,
  CustomerMeasurementRepository? measurementRepository,
  CustomerMaximalRepository? maximalRepository,
}) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<MaximalAssociateResult>(
    context: context,
    title: l10n.maximalAssociateTitle,
    wrapContent: true,
    maxHeightFraction: 0.88,
    bodyBuilder: (sheetContext) => _MaximalAssociateBody(
      customerId: customerId,
      currentRef: currentRef,
      measurementRepository:
          measurementRepository ?? CustomerMeasurementRepository(),
      maximalRepository: maximalRepository ?? CustomerMaximalRepository(),
      onResult: (result) => Navigator.of(sheetContext).pop(result),
    ),
  );
}

class _MaximalAssociateBody extends StatefulWidget {
  const _MaximalAssociateBody({
    required this.customerId,
    required this.currentRef,
    required this.measurementRepository,
    required this.maximalRepository,
    required this.onResult,
  });

  final String customerId;
  final MaximalRef? currentRef;
  final CustomerMeasurementRepository measurementRepository;
  final CustomerMaximalRepository maximalRepository;
  final ValueChanged<MaximalAssociateResult> onResult;

  @override
  State<_MaximalAssociateBody> createState() => _MaximalAssociateBodyState();
}

class _MaximalAssociateBodyState extends State<_MaximalAssociateBody> {
  bool _loading = true;
  bool _loadFailed = false;
  List<CustomerMeasurement> _measurements = const [];
  List<CustomerMaximal> _customs = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      final measurements =
          await widget.measurementRepository.getByCustomerId(widget.customerId);
      final customs =
          await widget.maximalRepository.getByCustomerId(widget.customerId);
      if (!mounted) return;
      setState(() {
        _measurements = measurements;
        _customs = customs;
        _loading = false;
        _loadFailed = false;
      });
    } catch (e, stack) {
      debugPrint('MaximalAssociateSheet load failed: $e\n$stack');
      if (!mounted) return;
      setState(() {
        _measurements = const [];
        _customs = const [];
        _loading = false;
        _loadFailed = true;
      });
    }
  }

  String _liftLabel(AppLocalizations l10n, MaximalLift lift) {
    switch (lift) {
      case MaximalLift.squat:
        return l10n.measurementSquat;
      case MaximalLift.bench:
        return l10n.measurementBench;
      case MaximalLift.deadlift:
        return l10n.measurementDeadlift;
    }
  }

  double? _liftKg(MaximalLift lift) {
    return MaximalKgResolver.resolve(
      ref: MaximalRef.measurement(lift: lift),
      measurements: _measurements,
      mode: MaximalKgResolver.defaultMode,
    );
  }

  Future<void> _editMeasurement(MaximalLift lift) async {
    final l10n = AppLocalizations.of(context);
    final kg = await showMaximalMeasurement1RmSheet(
      context,
      customerId: widget.customerId,
      lift: lift,
      liftLabel: _liftLabel(l10n, lift),
      initialKg: _liftKg(lift),
      repository: widget.measurementRepository,
      useRootNavigator: true,
    );
    if (!mounted || kg == null) return;
    await _load();
    if (!mounted) return;
    widget.onResult(
      MaximalAssociateResult.set(MaximalRef.measurement(lift: lift)),
    );
  }

  Future<void> _createOrEditCustom({CustomerMaximal? existing}) async {
    final saved = await showMaximalCustomFormSheet(
      context,
      customerId: widget.customerId,
      existing: existing,
      repository: widget.maximalRepository,
      useRootNavigator: true,
    );
    if (!mounted || saved == null) return;
    await _load();
    if (!mounted) return;
    widget.onResult(
      MaximalAssociateResult.set(MaximalRef.custom(maximalId: saved.id)),
    );
  }

  void _selectMeasurement(MaximalLift lift) {
    final kg = _liftKg(lift);
    if (kg == null || kg <= 0) {
      // Fewer taps: empty lift opens the 1RM editor instead of linking — kg.
      _editMeasurement(lift);
      return;
    }
    widget.onResult(
      MaximalAssociateResult.set(MaximalRef.measurement(lift: lift)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final current = widget.currentRef;

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_loadFailed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.maximalAssociateLoadError,
              style: theme.textTheme.bodyMedium?.copyWith(color: cs.error),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _load,
                child: Text(l10n.cloudSaveRetryAction),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.maximalAssociateMeasurementSection,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        for (final lift in MaximalLift.values)
          _AssociateRow(
            selected: current?.isMeasurement == true && current?.lift == lift,
            title: () {
              final kg = _liftKg(lift);
              final label = _liftLabel(l10n, lift);
              if (kg == null || kg <= 0) {
                return l10n.maximalAssociateLiftEmpty(label);
              }
              return l10n.maximalAssociateLiftWithKg(
                label,
                formatMaximalDisplayKg(kg),
              );
            }(),
            trailing: IconButton(
              tooltip: l10n.maximalAssociateEditMeasurement,
              icon: const Icon(Icons.edit_outlined, size: 18),
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              padding: EdgeInsets.zero,
              onPressed: () => _editMeasurement(lift),
            ),
            onTap: () => _selectMeasurement(lift),
          ),
        const SizedBox(height: 4),
        Text(
          l10n.maximalAssociateCustomSection,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        if (_customs.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              l10n.maximalAssociateCustomEmpty,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          )
        else
          for (final custom in _customs)
            _AssociateRow(
              selected: current?.isCustom == true &&
                  current?.maximalId == custom.id,
              title: l10n.maximalAssociateLiftWithKg(
                custom.label,
                formatMaximalDisplayKg(custom.weightKg),
              ),
              trailing: IconButton(
                tooltip: l10n.maximalAssociateEditCustom,
                icon: const Icon(Icons.edit_outlined, size: 18),
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
                onPressed: () => _createOrEditCustom(existing: custom),
              ),
              onTap: () => widget.onResult(
                MaximalAssociateResult.set(
                  MaximalRef.custom(maximalId: custom.id),
                ),
              ),
            ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => _createOrEditCustom(),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.maximalAssociateCreateCustom),
          ),
        ),
        if (current != null) ...[
          const Divider(height: 12),
          TextButton(
            onPressed: () =>
                widget.onResult(const MaximalAssociateResult.clear()),
            style: TextButton.styleFrom(
              foregroundColor: cs.error,
              visualDensity: VisualDensity.compact,
            ),
            child: Text(l10n.maximalAssociateClear),
          ),
        ],
      ],
    );
  }
}

/// Compact selectable row (replaces bulky [ListTile] for Stitch density).
class _AssociateRow extends StatelessWidget {
  const _AssociateRow({
    required this.title,
    required this.onTap,
    required this.selected,
    this.trailing,
  });

  final String title;
  final VoidCallback onTap;
  final bool selected;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Material(
      color: selected
          ? cs.primaryContainer.withValues(alpha: 0.35)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 2, 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
