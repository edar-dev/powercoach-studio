import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../theme/stitch_m3_theme.dart';
import '../../data/customer_measurement_repository.dart';
import '../../data/models/customer_measurement.dart';

/// Full-screen form to create or edit a customer measurement.
class CustomerMeasurementFormScreen extends StatefulWidget {
  const CustomerMeasurementFormScreen({
    super.key,
    required this.customerId,
    this.measurement,
  });

  final String customerId;
  final CustomerMeasurement? measurement;

  @override
  State<CustomerMeasurementFormScreen> createState() => _CustomerMeasurementFormScreenState();
}

class _CustomerMeasurementFormScreenState extends State<CustomerMeasurementFormScreen> {
  final _repo = CustomerMeasurementRepository();
  final _formKey = GlobalKey<FormState>();
  late DateTime _date;
  final _squatController = TextEditingController();
  final _benchController = TextEditingController();
  final _deadliftController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _muscleMassController = TextEditingController();
  final _notesController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final m = widget.measurement;
    _date = m?.measurementDate ?? DateTime.now();
    if (m != null) {
      _squatController.text = m.squat1RM?.toString() ?? '';
      _benchController.text = m.benchPress1RM?.toString() ?? '';
      _deadliftController.text = m.deadlift1RM?.toString() ?? '';
      _bodyFatController.text = m.bodyFatPercent?.toString() ?? '';
      _muscleMassController.text = m.muscleMassKg?.toString() ?? '';
      _notesController.text = m.notes ?? '';
    }
  }

  @override
  void dispose() {
    _squatController.dispose();
    _benchController.dispose();
    _deadliftController.dispose();
    _bodyFatController.dispose();
    _muscleMassController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    try {
      final body = {
        'measurementDate': CustomerMeasurement.toDateString(_date),
        'squat1RM': _parseDouble(_squatController.text),
        'benchPress1RM': _parseDouble(_benchController.text),
        'deadlift1RM': _parseDouble(_deadliftController.text),
        'bodyFatPercent': _parseDouble(_bodyFatController.text),
        'muscleMassKg': _parseDouble(_muscleMassController.text),
        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      };
      if (widget.measurement != null) {
        await _repo.update(widget.customerId, widget.measurement!.id, {
          ...body,
          'expectedRowVersion': widget.measurement!.rowVersion,
        });
      } else {
        await _repo.create(widget.customerId, body);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.measurementSaved),
          behavior: SnackBarBehavior.floating,
          backgroundColor: StitchM3Theme.accent,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.measurementSaveError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: cs.errorContainer,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  double? _parseDouble(String s) {
    final t = s.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isEdit = widget.measurement != null;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          isEdit ? l10n.measurementEdit : l10n.measurementAdd,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(l10n.customerSave),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.measurementDate, style: theme.textTheme.labelLarge),
              subtitle: Text(
                '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                style: theme.textTheme.titleMedium,
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const SizedBox(height: 16),
            Text(l10n.measurement1RM, style: theme.textTheme.titleSmall?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _squatController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                    decoration: InputDecoration(
                      labelText: l10n.measurementSquat,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _benchController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                    decoration: InputDecoration(
                      labelText: l10n.measurementBench,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _deadliftController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                    decoration: InputDecoration(
                      labelText: l10n.measurementDeadlift,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.measurementBodyFat, style: theme.textTheme.titleSmall?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _bodyFatController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(l10n.measurementMuscleMass, style: theme.textTheme.titleSmall?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _muscleMassController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.measurementNotes, style: theme.textTheme.titleSmall?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
