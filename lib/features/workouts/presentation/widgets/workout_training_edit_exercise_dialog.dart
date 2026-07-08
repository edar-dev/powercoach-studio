import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/exercise_prescription_scope.dart';
import 'exercise_add_set_rows_editor.dart';
import 'exercise_set_edit_controllers.dart';
import 'exercise_prescription_scope_selector.dart';

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
            final removed = setControllers.removeAt(i);
            removed.sets.dispose();
            removed.reps.dispose();
            removed.load.dispose();
            removed.note.dispose();
          });
        }

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
            ExercisePrescriptionScopeSelector(
              value: allWeeksScope
                  ? ExercisePrescriptionScope.allWeeks
                  : ExercisePrescriptionScope.perWeek,
              onChanged: (scope) => setState(
                () =>
                    allWeeksScope = scope == ExercisePrescriptionScope.allWeeks,
              ),
            ),
            if (useMultiSet) ...[
              const SizedBox(height: 12),
              ExerciseAddSetRowsEditor(
                setControllers: setControllers,
                onAddSet: addSetRow,
                onRemoveSet: removeSetRow,
              ),
            ] else ...[
              const SizedBox(height: 10),
              TextField(
                controller: setsController,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  labelText: l10n.workoutBuilderSetsLabel,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: repsController,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  labelText: l10n.workoutBuilderRepsLabel,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: rpeController,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
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
