import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/exercise_prescription_scope.dart';

class ExercisePrescriptionScopeSelector extends StatelessWidget {
  const ExercisePrescriptionScopeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ExercisePrescriptionScope value;
  final ValueChanged<ExercisePrescriptionScope> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        l10n.workoutExerciseScopeAllWeeks,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      value: value == ExercisePrescriptionScope.allWeeks,
      onChanged: (enabled) => onChanged(
        enabled
            ? ExercisePrescriptionScope.allWeeks
            : ExercisePrescriptionScope.perWeek,
      ),
    );
  }
}
