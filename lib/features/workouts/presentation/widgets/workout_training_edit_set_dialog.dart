import 'package:flutter/material.dart';

import '../../../../core/ui/widgets/app_sheet.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../customers/data/customer_maximal_repository.dart';
import '../../../customers/data/customer_measurement_repository.dart';
import '../../../customers/data/models/customer_measurement.dart';
import '../../../settings/data/maximal_weight_rounding_controller.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/maximal_kg_resolver.dart';
import '../../domain/maximal_load_math.dart';
import '../../domain/maximal_ref.dart';
import 'maximal_associate_sheet.dart';
import 'maximal_set_panel.dart';

/// Opens the set editor sheet (sets / reps / load / note + Massimali panel).
///
/// [exercise] supplies [Exercise.maximalRef]. [customerId] loads measurements
/// and custom massimali for resolve; when null (sandbox), the panel stays
/// disabled. [onMaximalRefChanged] persists association on the plan exercise
/// (`null` + [clear] means remove the link).
void showEditSetDialog(
  BuildContext context,
  ThemeData theme,
  ColorScheme cs,
  String initialSets,
  String initialReps,
  String initialLoad,
  String initialNote,
  void Function(String sets, String reps, String load, String note) onSave, {
  Exercise? exercise,
  String? customerId,
  CustomerMeasurementRepository? measurementRepository,
  CustomerMaximalRepository? maximalRepository,
  double? roundingIncrementKg,
  void Function(MaximalRef? ref, {required bool clear})? onMaximalRefChanged,
}) {
  final setsController = TextEditingController(text: initialSets);
  final repsController = TextEditingController(text: initialReps);
  final loadController = TextEditingController(text: initialLoad);
  final noteController = TextEditingController(text: initialNote);
  final l10n = AppLocalizations.of(context);
  const denseDecoration = InputDecoration(
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );
  showAppBottomSheet<void>(
    context: context,
    title: l10n.workoutBuilderEditSetTitle,
    wrapContent: true,
    maxHeightFraction: 0.88,
    bodyBuilder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _EditSetMaximalHost(
          exercise: exercise,
          customerId: customerId,
          loadController: loadController,
          measurementRepository: measurementRepository,
          maximalRepository: maximalRepository,
          roundingIncrementKg: roundingIncrementKg,
          onMaximalRefChanged: onMaximalRefChanged,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: setsController,
                decoration: denseDecoration.copyWith(
                  labelText: l10n.workoutBuilderSetLabel,
                  hintText: '1',
                ),
                keyboardType: TextInputType.number,
                autofocus: false,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: repsController,
                decoration: denseDecoration.copyWith(
                  labelText: l10n.workoutBuilderRepsLabel,
                  hintText: '3',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: loadController,
                decoration: denseDecoration.copyWith(
                  labelText: l10n.workoutBuilderLoadLabel,
                  hintText: '75kg',
                ),
                keyboardType: TextInputType.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: noteController,
          decoration: denseDecoration.copyWith(
            labelText: l10n.workoutBuilderNoteLabel,
          ),
          maxLines: 2,
        ),
      ],
    ),
    primaryActionLabel: l10n.customerSave,
    onPrimaryAction: () {
      onSave(
        setsController.text.trim(),
        repsController.text.trim(),
        loadController.text.trim(),
        noteController.text.trim(),
      );
      Navigator.of(context).pop();
    },
  );
}

/// Loads customer massimali data and hosts [MaximalSetPanel] inside the sheet.
class _EditSetMaximalHost extends StatefulWidget {
  const _EditSetMaximalHost({
    required this.exercise,
    required this.customerId,
    required this.loadController,
    this.measurementRepository,
    this.maximalRepository,
    this.roundingIncrementKg,
    this.onMaximalRefChanged,
  });

  final Exercise? exercise;
  final String? customerId;
  final TextEditingController loadController;
  final CustomerMeasurementRepository? measurementRepository;
  final CustomerMaximalRepository? maximalRepository;
  final double? roundingIncrementKg;
  final void Function(MaximalRef? ref, {required bool clear})?
      onMaximalRefChanged;

  @override
  State<_EditSetMaximalHost> createState() => _EditSetMaximalHostState();
}

class _EditSetMaximalHostState extends State<_EditSetMaximalHost> {
  MaximalResolveMode _mode = MaximalKgResolver.defaultMode;
  int _percent = 80;
  bool _loading = false;
  bool _loadFailed = false;
  List<CustomerMeasurement> _measurements = const [];
  List<MaximalCustomKg> _customs = const [];
  /// Labels for custom maximals (id → label) for the panel source subtitle.
  Map<String, String> _customLabels = const {};
  MaximalRef? _localRef;

  MaximalRef? get _ref => _localRef;

  String? get _customerId {
    final id = widget.customerId?.trim();
    if (id == null || id.isEmpty) return null;
    return id;
  }

  double get _incrementKg =>
      widget.roundingIncrementKg ??
      MaximalWeightRoundingController.instance.incrementKg;

  @override
  void initState() {
    super.initState();
    _localRef = widget.exercise?.maximalRef;
    _loadData();
  }

  @override
  void didUpdateWidget(covariant _EditSetMaximalHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.customerId != widget.customerId ||
        oldWidget.exercise?.maximalRef != widget.exercise?.maximalRef) {
      _localRef = widget.exercise?.maximalRef;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final customerId = _customerId;
    if (customerId == null) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadFailed = false;
        _measurements = const [];
        _customs = const [];
        _customLabels = const {};
      });
      return;
    }

    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      final measurementRepo =
          widget.measurementRepository ?? CustomerMeasurementRepository();
      final maximalRepo =
          widget.maximalRepository ?? CustomerMaximalRepository();
      final measurements = await measurementRepo.getByCustomerId(customerId);
      final maximals = await maximalRepo.getByCustomerId(customerId);
      if (!mounted) return;
      setState(() {
        _measurements = measurements;
        _customs = maximals
            .map(
              (m) => MaximalCustomKg(id: m.id, weightKg: m.weightKg),
            )
            .toList(growable: false);
        _customLabels = {
          for (final m in maximals) m.id: m.label,
        };
        _loading = false;
        _loadFailed = false;
      });
    } catch (e, stack) {
      debugPrint('MaximalSetPanel data load failed: $e\n$stack');
      if (!mounted) return;
      setState(() {
        _measurements = const [];
        _customs = const [];
        _customLabels = const {};
        _loading = false;
        _loadFailed = true;
      });
    }
  }

  double? get _resolvedKg => MaximalKgResolver.resolve(
        ref: _ref,
        measurements: _measurements,
        customs: _customs,
        mode: _mode,
      );

  bool get _showResolveToggle {
    final ref = _ref;
    if (ref == null || !ref.isMeasurement || ref.lift == null) return false;
    return MaximalKgResolver.countLiftValues(
          measurements: _measurements,
          lift: ref.lift!,
        ) >=
        2;
  }

  String? _sourceLabel(AppLocalizations l10n) {
    final ref = _ref;
    if (ref == null) return null;
    if (ref.isMeasurement && ref.lift != null) {
      switch (ref.lift!) {
        case MaximalLift.squat:
          return l10n.measurementSquat;
        case MaximalLift.bench:
          return l10n.measurementBench;
        case MaximalLift.deadlift:
          return l10n.measurementDeadlift;
      }
    }
    if (ref.isCustom && ref.maximalId != null) {
      return _customLabels[ref.maximalId!];
    }
    return null;
  }

  void _applyCurrentPercent({required double? maximalKg}) {
    if (maximalKg == null || maximalKg <= 0) return;
    final kg = applyPercentRounded(
      maximalKg: maximalKg,
      percent: _percent.clamp(
        kMaximalPercentSliderMin,
        kMaximalPercentSliderMax,
      ),
      incrementKg: _incrementKg,
    );
    widget.loadController.text = formatMaximalLoadKg(kg);
  }

  void _onResolveModeChanged(MaximalResolveMode mode) {
    final nextKg = MaximalKgResolver.resolve(
      ref: _ref,
      measurements: _measurements,
      customs: _customs,
      mode: mode,
    );
    setState(() => _mode = mode);
    _applyCurrentPercent(maximalKg: nextKg);
  }

  Future<void> _onSetMaximal() async {
    final customerId = _customerId;
    if (customerId == null) return;
    final result = await showMaximalAssociateSheet(
      context,
      customerId: customerId,
      currentRef: _ref,
      measurementRepository: widget.measurementRepository,
      maximalRepository: widget.maximalRepository,
    );
    if (!mounted || result == null) return;
    setState(() {
      _localRef = result.cleared ? null : result.ref;
    });
    widget.onMaximalRefChanged?.call(
      result.ref,
      clear: result.cleared,
    );
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasCustomer = _customerId != null;
    return MaximalSetPanel(
      maximalRef: _ref,
      maximalKg: _resolvedKg,
      sourceLabel: _sourceLabel(l10n),
      resolveMode: _mode,
      onResolveModeChanged: _onResolveModeChanged,
      showResolveModeToggle: _showResolveToggle,
      percent: _percent.clamp(
        kMaximalPercentSliderMin,
        kMaximalPercentSliderMax,
      ),
      onPercentChanged: (p) => setState(() => _percent = p),
      incrementKg: _incrementKg,
      onApplyLoad: (load) => widget.loadController.text = load,
      onSetMaximal: _onSetMaximal,
      onRetryLoad: _loadData,
      enabled: hasCustomer,
      isSandbox: !hasCustomer,
      loading: _loading,
      loadFailed: _loadFailed,
    );
  }
}
