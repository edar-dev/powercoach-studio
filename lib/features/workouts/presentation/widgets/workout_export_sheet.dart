import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/export_pdf_usecase.dart';

class WorkoutExportSheetPdfOptions {
  const WorkoutExportSheetPdfOptions({
    required this.layout,
    required this.includeMobility,
  });

  final WorkoutPdfLayout layout;
  final bool includeMobility;
}

Future<void> showWorkoutExportSheet({
  required BuildContext context,
  required WorkoutRoutine routine,
  required ValueChanged<WorkoutExportSheetPdfOptions> onExportPdf,
}) {
  final l10n = AppLocalizations.of(context);
  var selected = WorkoutPdfLayout.dense;
  var includeMobility = routine.mobilityItems.isNotEmpty;

  return showAppBottomSheet<void>(
    context: context,
    title: l10n.workoutExportPdfSheetTitle,
    bodyBuilder: (sheetContext) => StatefulBuilder(
      builder: (ctx, setModalState) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.workoutPdfSheetSubtitle,
            style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
              color: Theme.of(ctx).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<WorkoutPdfLayout>(
            segments: [
              ButtonSegment<WorkoutPdfLayout>(
                value: WorkoutPdfLayout.canonical,
                label: Text(l10n.workoutPdfLayoutCanonical),
              ),
              ButtonSegment<WorkoutPdfLayout>(
                value: WorkoutPdfLayout.dense,
                label: Text(l10n.workoutPdfLayoutDense),
              ),
            ],
            selected: {selected},
            onSelectionChanged: (set) {
              if (set.isNotEmpty) {
                setModalState(() => selected = set.first);
              }
            },
          ),
          if (selected == WorkoutPdfLayout.dense)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                l10n.workoutPdfLayoutDenseDescription,
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          if (routine.mobilityItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.workoutPdfIncludeMobility),
              value: includeMobility,
              onChanged: (v) => setModalState(() => includeMobility = v),
            ),
          ],
        ],
      ),
    ),
    primaryActionLabel: l10n.workoutExportPdfGenerateAndDownload,
    onPrimaryAction: () {
      final options = WorkoutExportSheetPdfOptions(
        layout: selected,
        includeMobility: includeMobility,
      );
      Navigator.of(context).pop();
      onExportPdf(options);
    },
  );
}
