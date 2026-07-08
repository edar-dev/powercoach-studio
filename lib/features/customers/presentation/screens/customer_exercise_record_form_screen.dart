import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../exercise_library/data/custom_exercise_repository.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import '../../../exercise_library/data/custom_exercise_item.dart';
import '../../../exercise_library/domain/exercise_autocomplete_filter.dart';
import '../../data/customer_exercise_record_repository.dart';
import '../../data/models/customer_exercise_record.dart';
import '../customer_exercise_record_delete_handler.dart';
import '../widgets/customer_exercise_record_form_fields.dart';

/// Full-screen form to create or edit a customer exercise record.
class CustomerExerciseRecordFormScreen extends StatefulWidget {
  const CustomerExerciseRecordFormScreen({
    super.key,
    required this.customerId,
    this.record,
    this.initialCustomExerciseId,
  });

  final String customerId;
  final CustomerExerciseRecord? record;
  final String? initialCustomExerciseId;

  @override
  State<CustomerExerciseRecordFormScreen> createState() =>
      _CustomerExerciseRecordFormScreenState();
}

class _CustomerExerciseRecordFormScreenState
    extends State<CustomerExerciseRecordFormScreen> {
  final _customExerciseRepo = CustomExerciseRepository();
  final _repo = CustomerExerciseRecordRepository();
  final _formKey = GlobalKey<FormState>();
  List<CustomExerciseItem> _exerciseOptions = [];
  final Map<String, int> _exerciseDepth = {};
  final Map<String, String> _exerciseParentName = {};
  bool _loadingExercises = true;
  String? _selectedExerciseId;
  final _valueController = TextEditingController();
  String _unit = 'kg';
  late DateTime _recordedAt;
  final _noteController = TextEditingController();
  bool _saving = false;
  final _exerciseFilter = DebouncedExerciseAutocompleteFilter();

  CustomExerciseItem? get _selectedExercise {
    if (_selectedExerciseId == null) return null;
    try {
      return _exerciseOptions.firstWhere((e) => e.id == _selectedExerciseId);
    } catch (_) {
      return null;
    }
  }

  String _exerciseDisplayName(CustomExerciseItem e) {
    final parentName = _exerciseParentName[e.id];
    return parentName != null ? '$parentName › ${e.name}' : e.name;
  }

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _recordedAt = r != null ? r.recordedAt : DateTime.now();
    if (r != null) {
      _selectedExerciseId = r.customExerciseId;
      _valueController.text = r.value.toString();
      _unit = r.unit.isEmpty ? 'kg' : r.unit;
      _noteController.text = r.note ?? '';
    } else if (widget.initialCustomExerciseId != null) {
      _selectedExerciseId = widget.initialCustomExerciseId;
    }
    _loadExercises();
  }

  @override
  void dispose() {
    _exerciseFilter.cancel();
    _valueController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    try {
      final items = await _customExerciseRepo.getTree();
      final flat = <CustomExerciseItem>[];
      void visit(CustomExerciseItem node, int depth, String? parentName) {
        flat.add(node);
        _exerciseDepth[node.id] = depth;
        if (parentName != null) _exerciseParentName[node.id] = parentName;
        for (final c in node.children) {
          visit(c, depth + 1, node.name);
        }
      }
      for (final root in items) {
        visit(root, 0, null);
      }
      if (mounted) {
        setState(() {
          _exerciseOptions = flat;
          _loadingExercises = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingExercises = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final exId = _selectedExerciseId;
    if (exId == null || exId.isEmpty) return;
    final valueText = _valueController.text.trim();
    if (valueText.isEmpty) return;
    final value = double.tryParse(valueText);
    if (value == null) return;
    final selectedExercise = _selectedExercise;
    final selectedExerciseDisplayName = selectedExercise != null
        ? _exerciseDisplayName(selectedExercise)
        : null;

    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    try {
      final body = {
        'customExerciseId': exId,
        if (selectedExerciseDisplayName != null &&
            selectedExerciseDisplayName.isNotEmpty)
          'exerciseName': selectedExerciseDisplayName,
        'value': value,
        'unit': _unit,
        'recordedAt': CustomerExerciseRecord.toDateString(_recordedAt),
        if (_noteController.text.trim().isNotEmpty)
          'note': _noteController.text.trim(),
      };
      if (widget.record != null) {
        await _repo.update(widget.customerId, widget.record!.id, {
          if (selectedExerciseDisplayName != null &&
              selectedExerciseDisplayName.isNotEmpty)
            'exerciseName': selectedExerciseDisplayName,
          'value': value,
          'unit': _unit,
          'recordedAt': CustomerExerciseRecord.toDateString(_recordedAt),
          if (_noteController.text.trim().isNotEmpty)
            'note': _noteController.text.trim(),
          'expectedRowVersion': widget.record!.rowVersion,
        });
      } else {
        await _repo.create(widget.customerId, body);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.recordSaved),
          behavior: SnackBarBehavior.floating,
          backgroundColor: StitchM3Theme.accent,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.recordSaveError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: cs.errorContainer,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _recordedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() => _recordedAt = picked);
    }
  }

  Future<void> _deleteRecord() async {
    final record = widget.record;
    if (record == null) return;
    setState(() => _saving = true);
    try {
      await deleteCustomerExerciseRecord(
        context: context,
        customerId: widget.customerId,
        record: record,
        repo: _repo,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isEdit = widget.record != null;

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
          isEdit ? l10n.recordAddUpdate : l10n.recordAdd,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.customerSave),
          ),
        ],
      ),
      body: _loadingExercises
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: CustomerExerciseRecordFormFields(
                l10n: l10n,
                theme: theme,
                colorScheme: cs,
                isEdit: isEdit,
                record: widget.record,
                exerciseOptions: _exerciseOptions,
                exerciseDepth: _exerciseDepth,
                exerciseFilter: _exerciseFilter,
                exerciseDisplayName: _exerciseDisplayName,
                selectedExerciseId: _selectedExerciseId,
                onExerciseSelected: (id) =>
                    setState(() => _selectedExerciseId = id),
                valueController: _valueController,
                unit: _unit,
                onUnitChanged: (v) => setState(() => _unit = v),
                recordedAt: _recordedAt,
                onPickDate: _pickDate,
                noteController: _noteController,
                onDelete: _deleteRecord,
                saving: _saving,
                isMounted: () => mounted,
              ),
            ),
    );
  }
}
