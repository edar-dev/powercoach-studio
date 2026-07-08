import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../exercise_library/data/custom_exercise_item.dart';
import '../../../exercise_library/data/custom_exercise_repository.dart';
import '../../../exercise_library/data/recent_exercises_store.dart';
import '../../data/workout_routine_model.dart';
import 'exercise_set_edit_controllers.dart';

List<ExerciseSet> buildExerciseSetDetailsFromControllers(
  List<SetEditControllers> setControllers,
) {
  return setControllers.map((c) {
    final sets = c.sets.text.trim();
    final reps = c.reps.text.trim();
    final load = c.load.text.trim();
    final noteSet = c.note.text.trim();
    if (sets.isNotEmpty || reps.isNotEmpty || load.isNotEmpty) {
      return ExerciseSet(
        sets: sets.isEmpty ? '1' : sets,
        reps: reps,
        rpe: load,
        note: noteSet,
      );
    }
    return ExerciseSet(note: noteSet);
  }).toList();
}

Future<void> createCustomExerciseAndSave({
  required BuildContext context,
  required ColorScheme colorScheme,
  required CustomExerciseRepository customExerciseRepo,
  required bool apiConfigured,
  required String name,
  required String note,
  required List<ExerciseSet> details,
  required void Function(bool saving) setSaving,
  required void Function(
    String name,
    String note,
    List<ExerciseSet> setDetails, [
    String? customExerciseId,
  ])
  onSaveWithSets,
  required VoidCallback onCancel,
}) async {
  if (!apiConfigured) {
    onSaveWithSets(name, note, details, null);
    onCancel();
    return;
  }
  setSaving(true);
  try {
    final body = <String, dynamic>{
      'name': name.trim(),
      if (note.trim().isNotEmpty) 'description': note.trim(),
    };
    final res = await customExerciseRepo.create(body);
    if (!context.mounted) return;
    final id = res['id']?.toString();
    final createdName = res['name'] as String? ?? name.trim();
    onSaveWithSets(createdName, note, details, id);
    onCancel();
  } catch (_) {
    if (!context.mounted) return;
    setSaving(false);
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).workoutBuilderCouldNotCreateExercise,
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.errorContainer,
      ),
    );
  }
}

void handleExerciseAddSheetSave({
  required BuildContext context,
  required ColorScheme colorScheme,
  required bool apiConfigured,
  required bool fromLibrary,
  required CustomExerciseItem? selectedExercise,
  required TextEditingController nameController,
  required TextEditingController noteController,
  required List<SetEditControllers> setControllers,
  required RecentExercisesStore recentStore,
  required CustomExerciseRepository customExerciseRepo,
  required void Function(bool saving) setSaving,
  required void Function(
    String name,
    String note,
    List<ExerciseSet> setDetails, [
    String? customExerciseId,
  ])
  onSaveWithSets,
  required VoidCallback onCancel,
}) {
  final note = noteController.text.trim();
  final details = buildExerciseSetDetailsFromControllers(setControllers);
  final normalizedDetails =
      details.isEmpty ? [const ExerciseSet()] : details;

  if (fromLibrary && selectedExercise != null) {
    unawaited(recentStore.recordUse(selectedExercise.id));
    onSaveWithSets(
      selectedExercise.name,
      note,
      normalizedDetails,
      selectedExercise.id,
    );
    onCancel();
    return;
  }

  final name = (!apiConfigured || !fromLibrary)
      ? nameController.text.trim()
      : (selectedExercise?.name ?? '').trim();
  if (name.isEmpty) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).workoutBuilderEnterNameOrSelect,
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.errorContainer,
      ),
    );
    return;
  }

  if (!fromLibrary && apiConfigured) {
    unawaited(
      createCustomExerciseAndSave(
        context: context,
        colorScheme: colorScheme,
        customExerciseRepo: customExerciseRepo,
        apiConfigured: apiConfigured,
        name: name,
        note: note,
        details: normalizedDetails,
        setSaving: setSaving,
        onSaveWithSets: onSaveWithSets,
        onCancel: onCancel,
      ),
    );
    return;
  }

  if (!fromLibrary) {
    onSaveWithSets(name, note, normalizedDetails, null);
    onCancel();
  }
}
