import 'package:flutter/foundation.dart';
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
import 'maximal_set_panel.dart';

/// Opens the set editor sheet (sets / reps / load / note + Massimali panel).
///
/// [exercise] supplies [Exercise.maximalRef]. [customerId] loads measurements
/// and custom massimali for resolve; when null (sandbox), the panel stays
/// disabled with a stub CTA (full associate flow is PR5).
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
  });

  final Exercise? exercise;
  final String? customerId;
  final TextEditingController loadController;
  final CustomerMeasurementRepository? measurementRepository;
  final CustomerMaximalRepository? maximalRepository;
  final double? roundingIncrementKg;

  @override
  State<_EditSetMaximalHost> createState() => _EditSetMaximalHostState();
}

class _EditSetMaximalHostState extends State<_EditSetMaximalHost> {
  MaximalResolveMode _mode = MaximalKgResolver.defaultMode;
  int _percent = 80;
  bool _loading = false;
  List<CustomerMeasurement> _measurements = const [];
  List<MaximalCustomKg> _customs = const [];

  MaximalRef? get _ref => widget.exercise?.maximalRef;

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
    _loadData();
  }

  @override
  void didUpdateWidget(covariant _EditSetMaximalHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.customerId != widget.customerId ||
        oldWidget.exercise?.maximalRef != widget.exercise?.maximalRef) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final customerId = _customerId;
    if (customerId == null) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _measurements = const [];
        _customs = const [];
      });
      return;
    }

    setState(() => _loading = true);
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
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _measurements = const [];
        _customs = const [];
        _loading = false;
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

  void _onSetMaximalStub() {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).maximalSetCtaComingSoon)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasCustomer = _customerId != null;
    return MaximalSetPanel(
      maximalRef: _ref,
      maximalKg: _resolvedKg,
      resolveMode: _mode,
      onResolveModeChanged: (mode) => setState(() => _mode = mode),
      showResolveModeToggle: _showResolveToggle,
      percent: _percent.clamp(
        kMaximalPercentSliderMin,
        kMaximalPercentSliderMax,
      ),
      onPercentChanged: (p) => setState(() => _percent = p),
      incrementKg: _incrementKg,
      onApplyLoad: (load) => widget.loadController.text = load,
      onSetMaximal: _onSetMaximalStub,
      enabled: hasCustomer,
      loading: _loading,
    );
  }
}
