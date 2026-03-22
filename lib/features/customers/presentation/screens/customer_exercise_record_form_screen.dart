import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/network/gymblog_api_client.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/stitch_m3_theme.dart';
import '../../../../widgets/app_sheet.dart';
import '../../../exercise_library/data/custom_exercise_item.dart';
import '../../data/customer_exercise_record_repository.dart';
import '../../data/models/customer_exercise_record.dart';

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
  /// When adding an "update" for an existing exercise, preselect this exercise.
  final String? initialCustomExerciseId;

  @override
  State<CustomerExerciseRecordFormScreen> createState() =>
      _CustomerExerciseRecordFormScreenState();
}

class _CustomerExerciseRecordFormScreenState
    extends State<CustomerExerciseRecordFormScreen> {
  final _api = GymBlogApiClient();
  final _repo = CustomerExerciseRecordRepository();
  final _formKey = GlobalKey<FormState>();
  List<CustomExerciseItem> _exerciseOptions = [];
  /// Depth in tree (0 = root, 1 = child).
  final Map<String, int> _exerciseDepth = {};
  /// Parent exercise name for display (e.g. "Parent › Child").
  final Map<String, String> _exerciseParentName = {};
  bool _loadingExercises = true;
  String? _selectedExerciseId;
  final _valueController = TextEditingController();
  String _unit = 'kg';
  late DateTime _recordedAt;
  final _noteController = TextEditingController();
  bool _saving = false;

  static const List<({String value, String labelKey})> _units = [
    (value: 'kg', labelKey: 'recordUnitKg'),
    (value: 'reps', labelKey: 'recordUnitReps'),
    (value: 'sec', labelKey: 'recordUnitSec'),
    (value: 'min', labelKey: 'recordUnitMin'),
    (value: 'other', labelKey: 'recordUnitOther'),
  ];

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
    _valueController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    if (!GymBlogApiClient.isConfigured) {
      setState(() => _loadingExercises = false);
      return;
    }
    try {
      final list = await _api.getList(
        '/api/custom-exercises',
        queryParameters: {'tree': 'true'},
      );
      final items = list
          .whereType<Map<String, dynamic>>()
          .map((e) => CustomExerciseItem.fromJson(e))
          .toList();
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

    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    try {
      final body = {
        'customExerciseId': exId,
        'value': value,
        'unit': _unit,
        'recordedAt': CustomerExerciseRecord.toDateString(_recordedAt),
        if (_noteController.text.trim().isNotEmpty) 'note': _noteController.text.trim(),
      };
      if (widget.record != null) {
        await _repo.update(widget.customerId, widget.record!.id, {
          'value': value,
          'unit': _unit,
          'recordedAt': CustomerExerciseRecord.toDateString(_recordedAt),
          if (_noteController.text.trim().isNotEmpty) 'note': _noteController.text.trim(),
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

  String _unitLabel(AppLocalizations l10n, String labelKey) {
    switch (labelKey) {
      case 'recordUnitKg':
        return l10n.recordUnitKg;
      case 'recordUnitReps':
        return l10n.recordUnitReps;
      case 'recordUnitSec':
        return l10n.recordUnitSec;
      case 'recordUnitMin':
        return l10n.recordUnitMin;
      case 'recordUnitOther':
        return l10n.recordUnitOther;
      default:
        return labelKey;
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
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (isEdit && widget.record != null) ...[
                    Text(
                      l10n.recordSelectExercise,
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        widget.record!.displayName,
                        style: theme.textTheme.bodyLarge,
                      ),
                      enabled: false,
                    ),
                    const SizedBox(height: 20),
                  ] else if (_exerciseOptions.isNotEmpty) ...[
                    Text(
                      l10n.recordSelectExercise,
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Autocomplete<CustomExerciseItem>(
                      initialValue: _selectedExercise != null
                          ? TextEditingValue(text: _exerciseDisplayName(_selectedExercise!))
                          : const TextEditingValue(),
                      optionsBuilder: (TextEditingValue value) {
                        final query = value.text.trim().toLowerCase();
                        if (query.isEmpty) return _exerciseOptions;
                        return _exerciseOptions.where((e) =>
                            _exerciseDisplayName(e).toLowerCase().contains(query));
                      },
                      displayStringForOption: _exerciseDisplayName,
                      onSelected: (e) => setState(() => _selectedExerciseId = e.id),
                      fieldViewBuilder: (
                        context,
                        controller,
                        focusNode,
                        onFieldSubmitted,
                      ) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: l10n.recordSearchExerciseHint,
                            border: const OutlineInputBorder(),
                          ),
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 280),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final e = options.elementAt(index);
                                  final depth = _exerciseDepth[e.id] ?? 0;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: 16.0 + (depth * 16.0)),
                                    child: ListTile(
                                      dense: depth > 0,
                                      title: Text(
                                        depth > 0 ? e.name : _exerciseDisplayName(e),
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: depth == 0
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      onTap: () => onSelected(e),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                  TextFormField(
                    controller: _valueController,
                    decoration: InputDecoration(
                      labelText: l10n.recordValue,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      if (double.tryParse(v.trim()) == null) return null;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _units.any((u) => u.value == _unit) ? _unit : 'kg',
                    decoration: InputDecoration(
                      labelText: l10n.recordUnit,
                      border: const OutlineInputBorder(),
                    ),
                    items: _units
                        .map(
                          (u) => DropdownMenuItem(
                            value: u.value,
                            child: Text(_unitLabel(l10n, u.labelKey)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _unit = v ?? 'kg'),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.recordDate, style: theme.textTheme.labelLarge),
                    subtitle: Text(
                      '${_recordedAt.year}-${_recordedAt.month.toString().padLeft(2, '0')}-${_recordedAt.day.toString().padLeft(2, '0')}',
                      style: theme.textTheme.bodyLarge,
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _recordedAt,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null && mounted) {
                        setState(() => _recordedAt = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: l10n.recordNote,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  if (isEdit && widget.record != null) ...[
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _saving ? null : _deleteRecord,
                        icon: Icon(Icons.delete_outline, size: 20, color: cs.error),
                        label: Text(
                          l10n.recordDeleteButton,
                          style: TextStyle(color: cs.error),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Future<void> _deleteRecord() async {
    final r = widget.record;
    if (r == null) return;
    final l10n = AppLocalizations.of(context);
    final confirm = await showAppConfirmDialog(
      context: context,
      title: l10n.recordDeleteConfirm,
      message: '',
      confirmLabel: l10n.customerDelete,
      cancelLabel: l10n.customerCancel,
      destructive: true,
    );
    if (!confirm || !mounted) return;
    setState(() => _saving = true);
    final cs = Theme.of(context).colorScheme;
    try {
      await _repo.delete(widget.customerId, r.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.recordDeleted),
          behavior: SnackBarBehavior.floating,
          backgroundColor: StitchM3Theme.accent,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.recordDeleteError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: cs.errorContainer,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
