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

/// Resolves a library exercise when the user typed an unambiguous exact name
/// (or display name) but did not tap a chip/option.
CustomExerciseItem? resolveExactLibraryExerciseMatch({
  required String query,
  required Iterable<CustomExerciseItem> options,
  String Function(CustomExerciseItem exercise)? displayName,
}) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) return null;

  final matches = <CustomExerciseItem>[];
  for (final exercise in options) {
    final nameMatch = exercise.name.trim().toLowerCase() == normalized;
    final displayMatch = displayName != null &&
        displayName(exercise).trim().toLowerCase() == normalized;
    if (nameMatch || displayMatch) {
      matches.add(exercise);
    }
  }
  if (matches.length == 1) return matches.first;
  return null;
}

/// Prefer the chip selection only while search text still matches it;
/// otherwise fall back to an unambiguous exact typed name.
CustomExerciseItem? resolveLibrarySelectionForSave({
  required CustomExerciseItem? selectedExercise,
  required String librarySearchText,
  required Iterable<CustomExerciseItem> exerciseOptions,
  String Function(CustomExerciseItem exercise)? libraryDisplayName,
}) {
  final query = librarySearchText.trim().toLowerCase();
  final selectedStillMatches = selectedExercise != null &&
      (query.isEmpty ||
          selectedExercise.name.trim().toLowerCase() == query ||
          (libraryDisplayName != null &&
              libraryDisplayName(selectedExercise).trim().toLowerCase() ==
                  query));
  if (selectedStillMatches) return selectedExercise;
  return resolveExactLibraryExerciseMatch(
    query: librarySearchText,
    options: exerciseOptions,
    displayName: libraryDisplayName,
  );
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
  String librarySearchText = '',
  Iterable<CustomExerciseItem> exerciseOptions = const [],
  String Function(CustomExerciseItem exercise)? libraryDisplayName,
  ValueChanged<String>? onLibrarySelectionError,
  ValueChanged<String>? onNameValidationError,
}) {
  final note = noteController.text.trim();
  final details = buildExerciseSetDetailsFromControllers(setControllers);
  final normalizedDetails =
      details.isEmpty ? [const ExerciseSet()] : details;
  final l10n = AppLocalizations.of(context);

  var resolvedSelection = fromLibrary
      ? resolveLibrarySelectionForSave(
          selectedExercise: selectedExercise,
          librarySearchText: librarySearchText,
          exerciseOptions: exerciseOptions,
          libraryDisplayName: libraryDisplayName,
        )
      : selectedExercise;

  if (fromLibrary && resolvedSelection != null) {
    unawaited(recentStore.recordUse(resolvedSelection.id));
    onSaveWithSets(
      resolvedSelection.name,
      note,
      normalizedDetails,
      resolvedSelection.id,
    );
    onCancel();
    return;
  }

  if (fromLibrary) {
    final message = l10n.workoutBuilderSelectLibraryExercise;
    if (onLibrarySelectionError != null) {
      onLibrarySelectionError(message);
    } else {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: colorScheme.errorContainer,
        ),
      );
    }
    return;
  }

  final name = nameController.text.trim();
  if (name.isEmpty) {
    final message = l10n.workoutBuilderEnterNameOrSelect;
    if (onNameValidationError != null) {
      onNameValidationError(message);
    } else {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: colorScheme.errorContainer,
        ),
      );
    }
    return;
  }

  if (apiConfigured) {
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

  onSaveWithSets(name, note, normalizedDetails, null);
  onCancel();
}
