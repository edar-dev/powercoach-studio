import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/remote/cloud_save_error_message.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/marketing_dark_colors.dart';
import 'package:powercoach_studio/core/ui/breakpoints.dart';
import 'package:powercoach_studio/features/customers/presentation/widgets/customer_creation_dark_field.dart';
import '../../data/customer_measurement_repository.dart';
import '../../data/models/customer_measurement.dart';
import '../../domain/customer_overview_metrics.dart';

/// Create/edit customer measurement — Stitch dialog-like dark form.
class CustomerMeasurementFormScreen extends StatefulWidget {
  const CustomerMeasurementFormScreen({
    super.key,
    required this.customerId,
    this.measurement,
    this.customerName,
    this.previousMeasurement,
  });

  final String customerId;
  final CustomerMeasurement? measurement;
  final String? customerName;
  final CustomerMeasurement? previousMeasurement;

  @override
  State<CustomerMeasurementFormScreen> createState() =>
      _CustomerMeasurementFormScreenState();
}

class _CustomerMeasurementFormScreenState
    extends State<CustomerMeasurementFormScreen> {
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
  CustomerMeasurement? _previous;

  @override
  void initState() {
    super.initState();
    final m = widget.measurement;
    _date = m?.measurementDate ?? DateTime.now();
    _previous = widget.previousMeasurement;
    if (m != null) {
      _squatController.text = m.squat1RM?.toString() ?? '';
      _benchController.text = m.benchPress1RM?.toString() ?? '';
      _deadliftController.text = m.deadlift1RM?.toString() ?? '';
      _bodyFatController.text = m.bodyFatPercent?.toString() ?? '';
      _muscleMassController.text = m.muscleMassKg?.toString() ?? '';
      _notesController.text = m.notes ?? '';
    }
    for (final c in [
      _squatController,
      _benchController,
      _deadliftController,
    ]) {
      c.addListener(() => setState(() {}));
    }
    if (_previous == null) {
      _loadPrevious();
    }
  }

  Future<void> _loadPrevious() async {
    try {
      final list = await _repo.getByCustomerId(widget.customerId);
      if (!mounted || list.isEmpty) return;
      final sorted = List<CustomerMeasurement>.from(list)
        ..sort((a, b) => b.measurementDate.compareTo(a.measurementDate));
      final currentId = widget.measurement?.id;
      CustomerMeasurement? previous;
      if (currentId == null) {
        previous = sorted.first;
      } else {
        final idx = sorted.indexWhere((m) => m.id == currentId);
        if (idx >= 0 && idx + 1 < sorted.length) {
          previous = sorted[idx + 1];
        }
      }
      if (previous != null && mounted) {
        setState(() => _previous = previous);
      }
    } catch (_) {}
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
    try {
      final body = {
        'measurementDate': CustomerMeasurement.toDateString(_date),
        'squat1RM': _parseDouble(_squatController.text),
        'benchPress1RM': _parseDouble(_benchController.text),
        'deadlift1RM': _parseDouble(_deadliftController.text),
        'bodyFatPercent': _parseDouble(_bodyFatController.text),
        'muscleMassKg': _parseDouble(_muscleMassController.text),
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
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
          backgroundColor: MarketingDarkColors.brand,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tryCloudSaveErrorMessage(e, l10n) ?? l10n.measurementSaveError,
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF7F1D1D),
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

  double? get _liveSbd {
    final s = _parseDouble(_squatController.text);
    final b = _parseDouble(_benchController.text);
    final d = _parseDouble(_deadliftController.text);
    if (s == null || b == null || d == null) return null;
    return s + b + d;
  }

  String? _deltaBadge(double? current, double? previous) {
    if (current == null || previous == null) return null;
    final delta = current - previous;
    if (delta.abs() < 0.05) {
      return AppLocalizations.of(context).measurementDeltaUnchanged;
    }
    return CustomerOverviewMetrics.formatAbsoluteDelta(delta, unit: 'kg');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEdit = widget.measurement != null;
    final wide = Breakpoints.isTabletOrWider(context);
    final formBody = _FormBody(
      formKey: _formKey,
      l10n: l10n,
      date: _date,
      onPickDate: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _date,
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) setState(() => _date = picked);
      },
      onToday: () => setState(() => _date = DateTime.now()),
      squatController: _squatController,
      benchController: _benchController,
      deadliftController: _deadliftController,
      bodyFatController: _bodyFatController,
      muscleMassController: _muscleMassController,
      notesController: _notesController,
      squatDelta: _deltaBadge(
        _parseDouble(_squatController.text),
        _previous?.squat1RM,
      ),
      benchDelta: _deltaBadge(
        _parseDouble(_benchController.text),
        _previous?.benchPress1RM,
      ),
      deadliftDelta: _deltaBadge(
        _parseDouble(_deadliftController.text),
        _previous?.deadlift1RM,
      ),
      sbdTotal: _liveSbd,
    );

    final shell = _FormShell(
      l10n: l10n,
      isEdit: isEdit,
      customerName: widget.customerName,
      saving: _saving,
      onClose: () {
        HapticFeedback.mediumImpact();
        Navigator.of(context).pop();
      },
      onSave: _saving ? null : _save,
      child: formBody,
    );

    if (wide) {
      return Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.55),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720, maxHeight: 860),
              child: Material(
                color: MarketingDarkColors.surface,
                borderRadius:
                    BorderRadius.circular(MarketingDarkColors.radius2xl),
                clipBehavior: Clip.antiAlias,
                child: shell,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: MarketingDarkColors.bgAlt,
      body: SafeArea(child: shell),
    );
  }
}

class _FormShell extends StatelessWidget {
  const _FormShell({
    required this.l10n,
    required this.isEdit,
    required this.customerName,
    required this.saving,
    required this.onClose,
    required this.onSave,
    required this.child,
  });

  final AppLocalizations l10n;
  final bool isEdit;
  final String? customerName;
  final bool saving;
  final VoidCallback onClose;
  final VoidCallback? onSave;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final name = customerName?.trim();
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: MarketingDarkColors.border),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                MarketingDarkColors.surfaceElevated,
                MarketingDarkColors.surface,
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: MarketingDarkColors.brand.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: MarketingDarkColors.brand.withValues(alpha: 0.25),
                  ),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  size: 16,
                  color: MarketingDarkColors.brandLight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          isEdit ? l10n.measurementEdit : l10n.measurementAdd,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: MarketingDarkColors.text,
                          ),
                        ),
                        if (name != null && name.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: MarketingDarkColors.surface800,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: MarketingDarkColors.borderMuted,
                              ),
                            ),
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 11,
                                color: MarketingDarkColors.slate300,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.measurementFormSubtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: MarketingDarkColors.slate400,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onSave,
                child: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: MarketingDarkColors.brandLight,
                        ),
                      )
                    : Text(
                        l10n.customerSave,
                        style: const TextStyle(
                          color: MarketingDarkColors.brandLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close),
                color: MarketingDarkColors.slate400,
              ),
            ],
          ),
        ),
        Expanded(child: child),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: MarketingDarkColors.border),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onClose,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MarketingDarkColors.slate300,
                    side: const BorderSide(
                      color: MarketingDarkColors.borderMuted,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(l10n.customerCancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: onSave,
                  style: FilledButton.styleFrom(
                    backgroundColor: MarketingDarkColors.brand,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(l10n.customerSave),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FormBody extends StatelessWidget {
  const _FormBody({
    required this.formKey,
    required this.l10n,
    required this.date,
    required this.onPickDate,
    required this.onToday,
    required this.squatController,
    required this.benchController,
    required this.deadliftController,
    required this.bodyFatController,
    required this.muscleMassController,
    required this.notesController,
    required this.squatDelta,
    required this.benchDelta,
    required this.deadliftDelta,
    required this.sbdTotal,
  });

  final GlobalKey<FormState> formKey;
  final AppLocalizations l10n;
  final DateTime date;
  final VoidCallback onPickDate;
  final VoidCallback onToday;
  final TextEditingController squatController;
  final TextEditingController benchController;
  final TextEditingController deadliftController;
  final TextEditingController bodyFatController;
  final TextEditingController muscleMassController;
  final TextEditingController notesController;
  final String? squatDelta;
  final String? benchDelta;
  final String? deadliftDelta;
  final double? sbdTotal;

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: MarketingDarkColors.surfaceElevated.withValues(alpha: 0.5),
              borderRadius:
                  BorderRadius.circular(MarketingDarkColors.radiusXl),
              border: Border.all(color: MarketingDarkColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.measurementDateDetected.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          color: MarketingDarkColors.slate300,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.measurementDate,
                        style: const TextStyle(
                          fontSize: 11,
                          color: MarketingDarkColors.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onPickDate,
                    borderRadius:
                        BorderRadius.circular(MarketingDarkColors.radiusXl),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: MarketingDarkColors.surfaceInput,
                        borderRadius: BorderRadius.circular(
                          MarketingDarkColors.radiusXl,
                        ),
                        border: Border.all(
                          color: MarketingDarkColors.borderSubtle,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: MarketingDarkColors.slate400,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600,
                              color: MarketingDarkColors.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onToday,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MarketingDarkColors.slate300,
                    side: const BorderSide(color: MarketingDarkColors.borderMuted),
                    backgroundColor: MarketingDarkColors.surface800,
                  ),
                  child: Text(l10n.measurementToday),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          CustomerCreationSectionTitle(title: l10n.measurement1RMSection),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final sideBySide = constraints.maxWidth >= 520;
              final cards = [
                _RmFieldCard(
                  label: l10n.measurementSquat,
                  controller: squatController,
                  delta: squatDelta,
                ),
                _RmFieldCard(
                  label: l10n.measurementBench,
                  controller: benchController,
                  delta: benchDelta,
                ),
                _RmFieldCard(
                  label: l10n.measurementDeadlift,
                  controller: deadliftController,
                  delta: deadliftDelta,
                ),
              ];
              if (sideBySide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(child: cards[i]),
                    ],
                  ],
                );
              }
              return Column(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    cards[i],
                  ],
                ],
              );
            },
          ),
          if (sbdTotal != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MarketingDarkColors.brand.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(MarketingDarkColors.radiusXl),
                border: Border.all(
                  color: MarketingDarkColors.brand.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: MarketingDarkColors.brandLight,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${l10n.measurementSbdEstimated}: ',
                    style: const TextStyle(
                      fontSize: 12,
                      color: MarketingDarkColors.slate300,
                    ),
                  ),
                  Text(
                    '${CustomerOverviewMetrics.formatMetricValue(sbdTotal!, isPercent: false)} kg',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: MarketingDarkColors.brandSoft,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          CustomerCreationSectionTitle(title: l10n.measurementBodyComp),
          const SizedBox(height: 12),
          CustomerCreationDarkField(
            label: l10n.measurementBodyFat,
            controller: bodyFatController,
            suffixText: '%',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          CustomerCreationDarkField(
            label: l10n.measurementMuscleMass,
            controller: muscleMassController,
            suffixText: 'kg',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          CustomerCreationDarkField(
            label: l10n.measurementNotes,
            controller: notesController,
          ),
        ],
      ),
    );
  }
}

class _RmFieldCard extends StatelessWidget {
  const _RmFieldCard({
    required this.label,
    required this.controller,
    this.delta,
  });

  final String label;
  final TextEditingController controller;
  final String? delta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MarketingDarkColors.surfaceElevated,
        borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
        border: Border.all(color: MarketingDarkColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: MarketingDarkColors.slate300,
                  ),
                ),
              ),
              if (delta != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: delta ==
                            AppLocalizations.of(context).measurementDeltaUnchanged
                        ? MarketingDarkColors.surface800
                        : MarketingDarkColors.emerald.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: delta ==
                              AppLocalizations.of(context)
                                  .measurementDeltaUnchanged
                          ? MarketingDarkColors.borderMuted
                          : MarketingDarkColors.emeraldBorder,
                    ),
                  ),
                  child: Text(
                    delta!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: delta ==
                              AppLocalizations.of(context)
                                  .measurementDeltaUnchanged
                          ? MarketingDarkColors.slate400
                          : MarketingDarkColors.emerald,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: MarketingDarkColors.text,
            ),
            cursorColor: MarketingDarkColors.brandLight,
            decoration: customerCreationInputDecoration(suffixText: 'kg'),
          ),
        ],
      ),
    );
  }
}
