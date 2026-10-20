import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/maximal_kg_parsing.dart';

/// Shared weight (kg) field used by Massimali create/edit sheets.
class MaximalKgFormField extends StatelessWidget {
  const MaximalKgFormField({
    super.key,
    required this.controller,
    required this.enabled,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextFormField(
      controller: controller,
      enabled: enabled,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      decoration: InputDecoration(
        labelText: l10n.maximalCustomWeightField,
        isDense: true,
      ),
      validator: (value) {
        final kg = parseMaximalKgInput(value);
        if (kg == null || kg <= 0) {
          return l10n.maximalCustomWeightRequired;
        }
        return null;
      },
    );
  }
}

/// Primary save button with inline spinner while [saving].
class MaximalFormSaveButton extends StatelessWidget {
  const MaximalFormSaveButton({
    super.key,
    required this.saving,
    required this.onPressed,
  });

  final bool saving;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FilledButton(
      onPressed: saving ? null : onPressed,
      child: saving
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(l10n.customerSave),
    );
  }
}
