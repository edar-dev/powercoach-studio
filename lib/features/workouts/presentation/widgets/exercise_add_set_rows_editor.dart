import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'exercise_set_edit_controllers.dart';

class ExerciseAddSetRowsEditor extends StatelessWidget {
  const ExerciseAddSetRowsEditor({
    super.key,
    required this.setControllers,
    required this.onAddSet,
    required this.onRemoveSet,
  });

  final List<SetEditControllers> setControllers;
  final VoidCallback onAddSet;
  final ValueChanged<int> onRemoveSet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final canRemove = setControllers.length > 1;
    final denseDecoration = InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...List.generate(setControllers.length, (i) {
          final c = setControllers[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: c.sets,
                    decoration: denseDecoration.copyWith(
                      labelText: l10n.workoutBuilderSetLabel,
                      hintText: '1',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: c.reps,
                    decoration: denseDecoration.copyWith(
                      labelText: l10n.workoutBuilderRepsLabel,
                      hintText: '3',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: c.load,
                    decoration: denseDecoration.copyWith(
                      labelText: l10n.workoutBuilderLoadLabel,
                      hintText: '75kg',
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
                if (canRemove)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 22,
                      color: StitchM3Theme.danger,
                    ),
                    onPressed: () => onRemoveSet(i),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onAddSet,
            icon: Icon(Icons.add, size: 18, color: StitchM3Theme.accent),
            label: Text(
              l10n.workoutBuilderAddSet,
              style: theme.textTheme.labelMedium?.copyWith(
                color: StitchM3Theme.accent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
