import 'package:flutter/material.dart';

import '../../../../core/ui/widgets/app_sheet.dart';
import '../../../../core/ui/widgets/cloud_save_feedback.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../customers/data/customer_measurement_repository.dart';
import '../../domain/maximal_kg_parsing.dart';
import '../../domain/maximal_measurement_write.dart';
import '../../domain/maximal_ref.dart';
import 'maximal_kg_form_field.dart';

/// Edit a measurement lift 1RM (updates latest row or creates one).
///
/// Returns the saved kg on success, or null if dismissed / save failed.
Future<double?> showMaximalMeasurement1RmSheet(
  BuildContext context, {
  required String customerId,
  required MaximalLift lift,
  required String liftLabel,
  double? initialKg,
  CustomerMeasurementRepository? repository,
  bool useRootNavigator = false,
}) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<double>(
    context: context,
    useRootNavigator: useRootNavigator,
    title: l10n.maximalMeasurement1rmTitle(liftLabel),
    wrapContent: true,
    maxHeightFraction: 0.6,
    bodyBuilder: (sheetContext) => _MaximalMeasurement1RmBody(
      customerId: customerId,
      lift: lift,
      initialKg: initialKg,
      repository: repository ?? CustomerMeasurementRepository(),
      onSaved: (kg) => Navigator.of(sheetContext).pop(kg),
    ),
  );
}

class _MaximalMeasurement1RmBody extends StatefulWidget {
  const _MaximalMeasurement1RmBody({
    required this.customerId,
    required this.lift,
    required this.repository,
    required this.onSaved,
    this.initialKg,
  });

  final String customerId;
  final MaximalLift lift;
  final double? initialKg;
  final CustomerMeasurementRepository repository;
  final ValueChanged<double> onSaved;

  @override
  State<_MaximalMeasurement1RmBody> createState() =>
      _MaximalMeasurement1RmBodyState();
}

class _MaximalMeasurement1RmBodyState extends State<_MaximalMeasurement1RmBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _weightController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final kg = widget.initialKg;
    _weightController = TextEditingController(
      text: kg == null ? '' : formatMaximalKgInput(kg),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final l10n = AppLocalizations.of(context);
    final weightKg = parseMaximalKgInput(_weightController.text)!;
    setState(() => _saving = true);
    try {
      await upsertMeasurementLift1Rm(
        repository: widget.repository,
        customerId: widget.customerId,
        lift: widget.lift,
        weightKg: weightKg,
      );
      if (!mounted) return;
      showCloudSaveSuccessSnackBar(
        context,
        message: l10n.maximalMeasurement1rmSaved,
      );
      widget.onSaved(weightKg);
    } catch (e) {
      if (!mounted) return;
      showCloudSaveErrorSnackBar(
        context,
        e,
        fallbackMessage: l10n.maximalMeasurement1rmSaveError,
        onRetry: _save,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.maximalMeasurement1rmHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          MaximalKgFormField(
            controller: _weightController,
            enabled: !_saving,
            autofocus: true,
          ),
          const SizedBox(height: 16),
          MaximalFormSaveButton(
            saving: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
