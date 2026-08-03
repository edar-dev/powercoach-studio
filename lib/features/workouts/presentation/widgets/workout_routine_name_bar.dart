import 'package:flutter/material.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

class WorkoutRoutineNameBar extends StatelessWidget {
  const WorkoutRoutineNameBar({
    super.key,
    required this.controller,
    required this.l10n,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final AppLocalizations l10n;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        enableInteractiveSelection: !readOnly,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: cs.onSurface,
        ),
        maxLines: 1,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: l10n.workoutBuilderRoutineNameHint,
          hintStyle: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: cs.onSurface.withValues(alpha: 0.72),
          ),
        ),
      ),
    );
  }
}
