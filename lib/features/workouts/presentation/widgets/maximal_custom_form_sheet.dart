import 'package:flutter/material.dart';

import '../../../../core/ui/widgets/app_sheet.dart';
import '../../../../core/ui/widgets/cloud_save_feedback.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../customers/data/customer_maximal_repository.dart';
import '../../../customers/data/models/customer_maximal.dart';
import '../../domain/maximal_kg_parsing.dart';
import 'maximal_kg_form_field.dart';

/// Create or edit a custom [CustomerMaximal] via bottom sheet.
///
/// Returns the saved maximal on success, or null if dismissed / save failed.
Future<CustomerMaximal?> showMaximalCustomFormSheet(
  BuildContext context, {
  required String customerId,
  CustomerMaximal? existing,
  CustomerMaximalRepository? repository,
  bool useRootNavigator = false,
}) {
  final l10n = AppLocalizations.of(context);
  final isEdit = existing != null;
  return showAppBottomSheet<CustomerMaximal>(
    context: context,
    useRootNavigator: useRootNavigator,
    title: isEdit
        ? l10n.maximalCustomFormEditTitle
        : l10n.maximalCustomFormCreateTitle,
    wrapContent: true,
    maxHeightFraction: 0.72,
    bodyBuilder: (sheetContext) => _MaximalCustomFormBody(
      customerId: customerId,
      existing: existing,
      repository: repository ?? CustomerMaximalRepository(),
      onSaved: (saved) => Navigator.of(sheetContext).pop(saved),
    ),
  );
}

class _MaximalCustomFormBody extends StatefulWidget {
  const _MaximalCustomFormBody({
    required this.customerId,
    required this.repository,
    required this.onSaved,
    this.existing,
  });

  final String customerId;
  final CustomerMaximal? existing;
  final CustomerMaximalRepository repository;
  final ValueChanged<CustomerMaximal> onSaved;

  @override
  State<_MaximalCustomFormBody> createState() => _MaximalCustomFormBodyState();
}

class _MaximalCustomFormBodyState extends State<_MaximalCustomFormBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _weightController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _labelController = TextEditingController(text: existing?.label ?? '');
    _weightController = TextEditingController(
      text: existing == null ? '' : formatMaximalKgInput(existing.weightKg),
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final l10n = AppLocalizations.of(context);
    final label = _labelController.text.trim();
    final weightKg = parseMaximalKgInput(_weightController.text)!;
    setState(() => _saving = true);
    try {
      final CustomerMaximal saved;
      final existing = widget.existing;
      if (existing != null) {
        saved = await widget.repository.update(widget.customerId, existing.id, {
          'label': label,
          'weightKg': weightKg,
        });
      } else {
        saved = await widget.repository.create(widget.customerId, {
          'label': label,
          'weightKg': weightKg,
        });
      }
      if (!mounted) return;
      showCloudSaveSuccessSnackBar(
        context,
        message: l10n.maximalCustomSaved,
      );
      widget.onSaved(saved);
    } catch (e) {
      if (!mounted) return;
      showCloudSaveErrorSnackBar(
        context,
        e,
        fallbackMessage: l10n.maximalCustomSaveError,
        onRetry: _save,
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
            controller: _labelController,
            enabled: !_saving,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.maximalCustomLabelField,
              isDense: true,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.maximalCustomLabelRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          MaximalKgFormField(
            controller: _weightController,
            enabled: !_saving,
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
