import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import '../../data/workout_routine_model.dart';
import 'exercise_add_compact_sheet.dart';
import 'exercise_add_sheet_content.dart';

export 'exercise_add_compact_sheet.dart';
export 'exercise_add_sheet_content.dart';

/// Shows the "Add exercise" dialog: choose from custom exercise library or create new on the fly.
/// When [customerId] is set, records for the selected exercise are loaded and shown.
/// Pass [compact: true] for gym-mode one-tap add with default sets.
Future<void> showAddExerciseDialog(
  BuildContext context,
  ThemeData theme,
  ColorScheme cs,
  void Function(
    String name,
    String note,
    List<ExerciseSet> setDetails, [
    String? customExerciseId,
  ])
  onSaveWithSets, {
  String? customerId,
  bool compact = false,
}) async {
  final l10n = AppLocalizations.of(context);
  if (compact) {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final height = MediaQuery.sizeOf(sheetContext).height * 0.72;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              height: height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.workoutBuilderAddExerciseTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ExerciseAddCompactSheet(
                      theme: theme,
                      cs: cs,
                      customerId: customerId,
                      onSaveWithSets: onSaveWithSets,
                      onCancel: () => Navigator.of(sheetContext).pop(),
                      onOpenFullEditor: () {
                        Navigator.of(sheetContext).pop();
                        showAddExerciseDialog(
                          context,
                          theme,
                          cs,
                          onSaveWithSets,
                          customerId: customerId,
                          compact: false,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    return;
  }

  showAppBottomSheet<void>(
    context: context,
    title: l10n.workoutBuilderAddExerciseTitle,
    maxHeightFraction: 0.88,
    bodyBuilder: (sheetContext) => AddExerciseDialogContent(
      theme: theme,
      cs: cs,
      customerId: customerId,
      onSaveWithSets: onSaveWithSets,
      onCancel: () => Navigator.of(sheetContext).pop(),
    ),
  );
}
