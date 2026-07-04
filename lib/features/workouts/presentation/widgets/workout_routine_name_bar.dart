import 'package:flutter/material.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

class WorkoutRoutineNameBar extends StatelessWidget {
  const WorkoutRoutineNameBar({
    super.key,
    required this.controller,
    required this.l10n,
  });

  final TextEditingController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: controller,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        ),
        maxLines: 1,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: l10n.workoutBuilderRoutineNameHint,
          hintStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: cs.onSurfaceVariant,
          ),
          prefixIcon: Icon(Icons.fitness_center, color: StitchM3Theme.accent),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
        ),
      ),
    );
  }
}
