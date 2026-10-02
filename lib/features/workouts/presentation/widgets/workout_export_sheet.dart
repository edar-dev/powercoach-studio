import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/export_pdf_usecase.dart';
import '../../domain/workout_export_preset.dart';

class WorkoutExportSheetPdfOptions {
  const WorkoutExportSheetPdfOptions({
    required this.layout,
    required this.includeMobility,
    this.weekIndices,
    this.preset,
  });

  final WorkoutPdfLayout layout;
  final bool includeMobility;

  /// `null` or empty = all weeks.
  final List<int>? weekIndices;

  /// Selected preset when exported from the sheet (optional, for tests).
  final WorkoutExportPreset? preset;
}

Future<void> showWorkoutExportSheet({
  required BuildContext context,
  required WorkoutRoutine routine,
  required ValueChanged<WorkoutExportSheetPdfOptions> onExportPdf,
}) {
  final l10n = AppLocalizations.of(context);
  final hasMobility = routine.mobilityItems.isNotEmpty;

  var selectedPreset = WorkoutExportPreset.gym;
  var resolved = resolveWorkoutExportPreset(
    selectedPreset,
    hasMobilityItems: hasMobility,
  );
  var layout = resolved.layout;
  var includeMobility = resolved.includeMobility;
  List<int>? weekIndices = resolved.weekIndices;
  var showLayoutOverride = false;

  return showAppBottomSheet<void>(
    context: context,
    title: l10n.workoutExportPdfSheetTitle,
    bodyBuilder: (sheetContext) => StatefulBuilder(
      builder: (ctx, setModalState) {
        void applyPreset(WorkoutExportPreset preset) {
          final next = resolveWorkoutExportPreset(
            preset,
            hasMobilityItems: hasMobility,
          );
          setModalState(() {
            selectedPreset = preset;
            layout = next.layout;
            includeMobility = next.includeMobility;
            weekIndices = next.weekIndices;
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.workoutPdfSheetSubtitle,
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            RadioGroup<WorkoutExportPreset>(
              groupValue: selectedPreset,
              onChanged: (value) {
                if (value != null) applyPreset(value);
              },
              child: Column(
                children: [
                  for (final preset in WorkoutExportPreset.values)
                    RadioListTile<WorkoutExportPreset>(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      value: preset,
                      title: Text(switch (preset) {
                        WorkoutExportPreset.gym => l10n.workoutPdfPresetGym,
                        WorkoutExportPreset.full => l10n.workoutPdfPresetFull,
                        WorkoutExportPreset.week1Only =>
                          l10n.workoutPdfPresetWeek1,
                      }),
                      subtitle: Text(switch (preset) {
                        WorkoutExportPreset.gym =>
                          l10n.workoutPdfPresetGymDescription,
                        WorkoutExportPreset.full =>
                          l10n.workoutPdfPresetFullDescription,
                        WorkoutExportPreset.week1Only =>
                          l10n.workoutPdfPresetWeek1Description,
                      }),
                    ),
                ],
              ),
            ),
            if (hasMobility) ...[
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.workoutPdfIncludeMobility),
                value: includeMobility,
                onChanged: (v) => setModalState(() => includeMobility = v),
              ),
            ],
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () =>
                    setModalState(() => showLayoutOverride = !showLayoutOverride),
                child: Text(
                  showLayoutOverride
                      ? l10n.workoutPdfPersonalizeLayoutHide
                      : l10n.workoutPdfPersonalizeLayout,
                ),
              ),
            ),
            if (showLayoutOverride) ...[
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
                selected: {layout},
                onSelectionChanged: (set) {
                  if (set.isNotEmpty) {
                    // Keep weekIndices from the selected preset.
                    setModalState(() => layout = set.first);
                  }
                },
              ),
              if (layout == WorkoutPdfLayout.dense)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    l10n.workoutPdfLayoutDenseDescription,
                    style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ],
        );
      },
    ),
    primaryActionLabel: l10n.workoutExportPdfGenerateAndDownload,
    onPrimaryAction: () {
      final options = WorkoutExportSheetPdfOptions(
        layout: layout,
        includeMobility: includeMobility,
        weekIndices: weekIndices,
        preset: selectedPreset,
      );
      Navigator.of(context).pop();
      onExportPdf(options);
    },
  );
}
