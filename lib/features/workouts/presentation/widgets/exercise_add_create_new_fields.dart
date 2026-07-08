import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class ExerciseAddCreateNewFields extends StatelessWidget {
  const ExerciseAddCreateNewFields({
    super.key,
    required this.l10n,
    required this.nameController,
    required this.autofocusName,
  });

  final AppLocalizations l10n;
  final TextEditingController nameController;
  final bool autofocusName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: l10n.workoutBuilderNameLabel,
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
