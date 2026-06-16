import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../theme/stitch_m3_theme.dart';
import '../../../../widgets/app_sheet.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/exercise_prescription_scope.dart';
import 'exercise_set_edit_controllers.dart';

/// Returns list of superset group options for the day (id + label) for "Add to superset" menu.
List<({String id, String label})> getSupersetGroupOptions(Day day) {
  final byId = <String, List<Exercise>>{};
  for (final e in day.exercises) {
    final id = e.supersetGroupId;
    if (id != null && id.isNotEmpty) {
      byId.putIfAbsent(id, () => []).add(e);
    }
  }
  return byId.entries
      .map((e) => (id: e.key, label: e.value.map((x) => x.name).join(' + ')))
      .toList();
}

void showRenameDayDialog(
  BuildContext context,
  String initialName,
  void Function(String) onSave,
) {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController(text: initialName);
  showAppBottomSheet<void>(
    context: context,
    title: l10n.workoutBuilderRenameDayTitle,
    bodyBuilder: (sheetContext) => TextField(
      controller: controller,
      decoration: InputDecoration(labelText: l10n.workoutBuilderDayNameLabel),
      autofocus: false,
      onSubmitted: (_) {
        final name = controller.text.trim();
        if (name.isEmpty) return;
        onSave(name);
        Navigator.of(sheetContext).pop();
      },
    ),
    primaryActionLabel: l10n.customerSave,
    onPrimaryAction: () {
      final name = controller.text.trim();
      if (name.isEmpty) return;
      onSave(name);
      Navigator.of(context).pop();
    },
  );
}

Future<String?> showDuplicateWeekDialog(
  BuildContext context,
  String defaultName,
) async {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController(text: defaultName);
  try {
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.workoutBuilderDuplicateWeekTitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.workoutBuilderDuplicateWeekHint,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () {
              final trimmed = controller.text.trim();
              if (trimmed.isEmpty) return;
              Navigator.of(ctx).pop(trimmed);
            },
            child: Text(l10n.workoutBuilderDuplicateWeek),
          ),
        ],
      ),
    );
  } finally {
    controller.dispose();
  }
}

void showRenameWeekDialog(
  BuildContext context,
  String initialName,
  void Function(String) onSave,
) {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController(text: initialName);
  showAppBottomSheet<void>(
    context: context,
    title: l10n.workoutBuilderRenameWeekTitle,
    bodyBuilder: (sheetContext) => TextField(
      controller: controller,
      decoration: InputDecoration(labelText: l10n.workoutBuilderWeekNameLabel),
      autofocus: false,
      onSubmitted: (_) {
        final name = controller.text.trim();
        if (name.isEmpty) return;
        onSave(name);
        Navigator.of(sheetContext).pop();
      },
    ),
    primaryActionLabel: l10n.customerSave,
    onPrimaryAction: () {
      final name = controller.text.trim();
      if (name.isEmpty) return;
      onSave(name);
      Navigator.of(context).pop();
    },
  );
}

void showEditExerciseDialog(
  BuildContext context,
  ThemeData theme,
  ColorScheme cs,
  String initialName,
  String initialSets,
  String initialReps,
  String initialRpe,
  String initialNote,
  void Function(String name, String sets, String reps, String rpe, String note)
  onSave, {
  String initialShortName = '',
  ExercisePrescriptionScope initialScope = ExercisePrescriptionScope.perWeek,
  List<ExerciseSet>? initialSetDetails,
  void Function(
    String name,
    String note,
    List<ExerciseSet> setDetails, {
    String shortName,
    ExercisePrescriptionScope prescriptionScope,
  })?
  onSaveWithSets,
}) {
  final nameController = TextEditingController(text: initialName);
  final noteController = TextEditingController(text: initialNote);
  final shortNameController = TextEditingController(text: initialShortName);
  var allWeeksScope = initialScope == ExercisePrescriptionScope.allWeeks;
  final setsController = TextEditingController(text: initialSets);
  final repsController = TextEditingController(text: initialReps);
  final rpeController = TextEditingController(text: initialRpe);
  final useMultiSet =
      onSaveWithSets != null &&
      initialSetDetails != null &&
      initialSetDetails.isNotEmpty;
  final setControllers = useMultiSet
      ? initialSetDetails.map((s) {
          String sets = s.sets.trim();
          String reps = s.reps.trim();
          String load = s.rpe.trim();
          if (sets.isEmpty && reps.isEmpty && s.line.trim().isNotEmpty) {
            final m = RegExp(r'^(\d+)x(\d+)\s*(.*)$').firstMatch(s.line.trim());
            if (m != null) {
              sets = m.group(1)!;
              reps = m.group(2)!;
              load = (m.group(3) ?? '').trim();
            } else {
              sets = s.line.trim();
            }
          }
          return SetEditControllers(
            TextEditingController(text: sets),
            TextEditingController(text: reps),
            TextEditingController(text: load),
            TextEditingController(text: s.note),
          );
        }).toList()
      : <SetEditControllers>[];

  final modalSaving = ValueNotifier<bool>(false);
  final l10n = AppLocalizations.of(context);
  showAppBottomSheet<void>(
    context: context,
    title: initialName.trim().isEmpty
        ? l10n.workoutBuilderAddExerciseTitle
        : l10n.workoutBuilderEditExerciseTitle,
    fullScreen: useMultiSet,
    bodyBuilder: (sheetContext) => StatefulBuilder(
      builder: (context, setState) {
        void addSetRow() {
          setState(() {
            setControllers.add(
              SetEditControllers(
                TextEditingController(),
                TextEditingController(),
                TextEditingController(),
                TextEditingController(),
              ),
            );
          });
        }

        void removeSetRow(int i) {
          if (setControllers.length <= 1) return;
          setState(() {
            setControllers.removeAt(i);
          });
        }

        final denseDecoration = InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        );
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
              ),
              autofocus: false,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: l10n.workoutBuilderNoteOptionalLabel,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: shortNameController,
              decoration: InputDecoration(
                labelText: l10n.workoutExerciseShortNameLabel,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n.workoutExerciseScopeAllWeeks,
                style: theme.textTheme.bodyMedium,
              ),
              value: allWeeksScope,
              onChanged: (value) => setState(() => allWeeksScope = value),
            ),
            if (useMultiSet) ...[
              const SizedBox(height: 12),
              Text(
                l10n.workoutBuilderMultiSetBlockHeader,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              ...setControllers.asMap().entries.map((entry) {
                final i = entry.key;
                final c = entry.value;
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
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: 22,
                          color: setControllers.length > 1
                              ? StitchM3Theme.danger
                              : cs.onSurfaceVariant,
                        ),
                        onPressed: setControllers.length > 1
                            ? () => removeSetRow(i)
                            : null,
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(8),
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
                  onPressed: addSetRow,
                  icon: Icon(Icons.add, size: 18, color: StitchM3Theme.accent),
                  label: Text(
                    l10n.workoutBuilderAddSet,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: StitchM3Theme.accent,
                    ),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 10),
              TextField(
                controller: setsController,
                decoration: denseDecoration.copyWith(
                  labelText: l10n.workoutBuilderSetsLabel,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: repsController,
                decoration: denseDecoration.copyWith(
                  labelText: l10n.workoutBuilderRepsLabel,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: rpeController,
                decoration: denseDecoration.copyWith(
                  labelText: l10n.workoutBuilderRpeOrLoadLabel,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: Text(l10n.customerCancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: modalSaving,
                    builder: (_, saving, __) => FilledButton(
                      onPressed: saving
                          ? null
                          : () {
                              modalSaving.value = true;
                              final name = nameController.text.trim();
                              final note = noteController.text.trim();
                              if (useMultiSet) {
                                final details = setControllers.map((c) {
                                  final sets = c.sets.text.trim();
                                  final reps = c.reps.text.trim();
                                  final load = c.load.text.trim();
                                  final noteSet = c.note.text.trim();
                                  if (sets.isNotEmpty ||
                                      reps.isNotEmpty ||
                                      load.isNotEmpty) {
                                    return ExerciseSet(
                                      sets: sets.isEmpty ? '1' : sets,
                                      reps: reps,
                                      rpe: load,
                                      note: noteSet,
                                    );
                                  }
                                  return ExerciseSet(note: noteSet);
                                }).toList();
                                onSaveWithSets(
                                  name,
                                  note,
                                  details,
                                  shortName: shortNameController.text.trim(),
                                  prescriptionScope: allWeeksScope
                                      ? ExercisePrescriptionScope.allWeeks
                                      : ExercisePrescriptionScope.perWeek,
                                );
                              } else {
                                onSave(
                                  name,
                                  setsController.text.trim(),
                                  repsController.text.trim(),
                                  rpeController.text.trim(),
                                  note,
                                );
                              }
                              Navigator.of(sheetContext).pop();
                            },
                      child: saving
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  cs.onPrimary,
                                ),
                              ),
                            )
                          : Text(l10n.customerSave),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        );
      },
    ),
  );
}

void showEditSetDialog(
  BuildContext context,
  ThemeData theme,
  ColorScheme cs,
  String initialSets,
  String initialReps,
  String initialLoad,
  String initialNote,
  void Function(String sets, String reps, String load, String note) onSave,
) {
  final setsController = TextEditingController(text: initialSets);
  final repsController = TextEditingController(text: initialReps);
  final loadController = TextEditingController(text: initialLoad);
  final noteController = TextEditingController(text: initialNote);
  final l10n = AppLocalizations.of(context);
  showAppBottomSheet<void>(
    context: context,
    title: l10n.workoutBuilderEditSetTitle,
    bodyBuilder: (sheetContext) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: setsController,
                decoration: InputDecoration(
                  labelText: l10n.workoutBuilderSetLabel,
                  hintText: '1',
                ),
                keyboardType: TextInputType.number,
                autofocus: false,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: repsController,
                decoration: InputDecoration(
                  labelText: l10n.workoutBuilderRepsLabel,
                  hintText: '3',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: loadController,
                decoration: InputDecoration(
                  labelText: l10n.workoutBuilderLoadLabel,
                  hintText: '75kg',
                ),
                keyboardType: TextInputType.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: noteController,
          decoration: InputDecoration(labelText: l10n.workoutBuilderNoteLabel),
          maxLines: 2,
        ),
      ],
    ),
    primaryActionLabel: l10n.customerSave,
    onPrimaryAction: () {
      onSave(
        setsController.text.trim(),
        repsController.text.trim(),
        loadController.text.trim(),
        noteController.text.trim(),
      );
      Navigator.of(context).pop();
    },
  );
}
