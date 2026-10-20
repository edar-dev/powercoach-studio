import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/ui/widgets/app_sheet.dart';
import '../../../../core/ui/widgets/cloud_save_feedback.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../customers/data/customer_measurement_repository.dart';
import '../../domain/maximal_measurement_write.dart';
import '../../domain/maximal_ref.dart';

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
      text: kg == null ? '' : _formatKgInput(kg),
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
    final weightKg = _parseKg(_weightController.text)!;
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
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _weightController,
            enabled: !_saving,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: InputDecoration(
              labelText: l10n.maximalCustomWeightField,
              isDense: true,
            ),
            validator: (value) {
              final kg = _parseKg(value);
              if (kg == null || kg <= 0) {
                return l10n.maximalCustomWeightRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.customerSave),
          ),
        ],
      ),
    );
  }
}

double? _parseKg(String? raw) {
  if (raw == null) return null;
  final normalized = raw.trim().replaceAll(',', '.');
  if (normalized.isEmpty) return null;
  return double.tryParse(normalized);
}

String _formatKgInput(double kg) {
  final asInt = kg.round();
  if ((kg - asInt).abs() < 1e-6) return asInt.toString();
  return kg.toString();
}
