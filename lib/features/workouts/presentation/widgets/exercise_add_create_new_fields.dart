import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class ExerciseAddCreateNewFields extends StatelessWidget {
  const ExerciseAddCreateNewFields({
    super.key,
    required this.l10n,
    required this.nameController,
    required this.autofocusName,
    this.nameErrorText,
    this.onNameChanged,
  });

  final AppLocalizations l10n;
  final TextEditingController nameController;
  final bool autofocusName;
  final String? nameErrorText;
  final ValueChanged<String>? onNameChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: nameController,
          onChanged: onNameChanged,
          decoration: InputDecoration(
            labelText: l10n.workoutBuilderNameLabel,
            errorText: nameErrorText,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: const OutlineInputBorder(),
          ),
          autofocus: autofocusName,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
