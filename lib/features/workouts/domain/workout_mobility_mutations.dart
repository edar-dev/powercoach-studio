import '../data/workout_routine_model.dart';
import 'mobility_session_presentation.dart';

WorkoutRoutine addMobilityItemToRoutine({
  required WorkoutRoutine routine,
  required MobilityItem item,
}) {
  return routine.copyWith(mobilityItems: [...routine.mobilityItems, item]);
}

WorkoutRoutine removeMobilityItemFromRoutine({
  required WorkoutRoutine routine,
  required String itemId,
}) {
  return routine.copyWith(
    mobilityItems: routine.mobilityItems.where((e) => e.id != itemId).toList(),
  );
}

WorkoutRoutine insertMobilityItemAtIndexInRoutine({
  required WorkoutRoutine routine,
  required MobilityItem item,
  required int indexInSection,
}) {
  final sectionItems =
      routine.mobilityItems.where((e) => e.sectionId == item.sectionId).toList();
  final others =
      routine.mobilityItems.where((e) => e.sectionId != item.sectionId).toList();
  final clampedIndex = indexInSection.clamp(0, sectionItems.length);
  sectionItems.insert(clampedIndex, item);
  return routine.copyWith(mobilityItems: [...others, ...sectionItems]);
}

WorkoutRoutine reorderMobilityItemsInSection({
  required WorkoutRoutine routine,
  required String sectionId,
  required int oldIndex,
  required int newIndex,
}) {
  final sectionItems =
      routine.mobilityItems.where((e) => e.sectionId == sectionId).toList();
  if (oldIndex < 0 ||
      oldIndex >= sectionItems.length ||
      newIndex < 0 ||
      newIndex >= sectionItems.length) {
    return routine;
  }
  final reordered = List<MobilityItem>.from(sectionItems);
  final item = reordered.removeAt(oldIndex);
  reordered.insert(newIndex, item);
  final others =
      routine.mobilityItems.where((e) => e.sectionId != sectionId).toList();
  return routine.copyWith(mobilityItems: [...others, ...reordered]);
}

WorkoutRoutine addMobilitySectionToRoutine({
  required WorkoutRoutine routine,
  required MobilitySection section,
}) {
  return routine.copyWith(
    mobilitySections: [...routine.mobilitySections, section],
  );
}

WorkoutRoutine updateMobilitySectionInRoutine({
  required WorkoutRoutine routine,
  required String sectionId,
  required String name,
  required String scheduleHint,
}) {
  // Empty name is intentional ("unset"); UI shows localized "Sezione N".
  final trimmed = name.trim();
  return routine.copyWith(
    mobilitySections: routine.mobilitySections
        .map(
          (s) => s.id == sectionId
              ? s.copyWith(name: trimmed, scheduleHint: scheduleHint.trim())
              : s,
        )
        .toList(),
  );
}

/// Returns null when the last section would be removed.
WorkoutRoutine? deleteMobilitySectionFromRoutine({
  required WorkoutRoutine routine,
  required int sectionIndex,
}) {
  if (sectionIndex < 0 || sectionIndex >= routine.mobilitySections.length) {
    return null;
  }
  if (routine.mobilitySections.length <= 1) return null;
  final section = routine.mobilitySections[sectionIndex];
  final firstOtherId = routine.mobilitySections
      .firstWhere((s) => s.id != section.id)
      .id;
  return routine.copyWith(
    mobilitySections:
        routine.mobilitySections.where((s) => s.id != section.id).toList(),
    mobilityItems: routine.mobilityItems
        .map(
          (m) => m.sectionId == section.id
              ? m.copyWith(sectionId: firstOtherId)
              : m,
        )
        .toList(),
  );
}

/// Replaces the mobility item with matching [item.id] (full replacement).
WorkoutRoutine updateMobilityItemInRoutine({
  required WorkoutRoutine routine,
  required MobilityItem item,
}) {
  return routine.copyWith(
    mobilityItems: routine.mobilityItems
        .map((e) => e.id == item.id ? item : e)
        .toList(),
  );
}

WorkoutRoutine? addSetToMobilityItemInRoutine({
  required WorkoutRoutine routine,
  required String itemId,
}) {
  MobilityItem? found;
  for (final e in routine.mobilityItems) {
    if (e.id == itemId) {
      found = e;
      break;
    }
  }
  if (found == null) return null;
  final details = [...found.effectiveSetDetails, const ExerciseSet()];
  final updated = syncMobilityItemPrescription(
    found.copyWith(setDetails: details),
  );
  return updateMobilityItemInRoutine(routine: routine, item: updated);
}

WorkoutRoutine? updateMobilityItemSetInRoutine({
  required WorkoutRoutine routine,
  required String itemId,
  required int setIndex,
  String? line,
  String? sets,
  String? reps,
  String? rpe,
  String? note,
}) {
  MobilityItem? found;
  for (final e in routine.mobilityItems) {
    if (e.id == itemId) {
      found = e;
      break;
    }
  }
  if (found == null) return null;
  final details = found.effectiveSetDetails;
  if (setIndex < 0 || setIndex >= details.length) return routine;
  final newDetails = List<ExerciseSet>.from(details);
  final cur = details[setIndex];
  if (line != null) {
    final trimmed = line.trim();
    if (trimmed.isNotEmpty) {
      newDetails[setIndex] = ExerciseSet(
        line: trimmed,
        sets: '1',
        reps: '',
        rpe: '',
        note: note ?? cur.note,
      );
    } else {
      newDetails[setIndex] = cur.copyWith(note: note ?? cur.note);
    }
  } else if (sets != null || reps != null || rpe != null) {
    newDetails[setIndex] = ExerciseSet(
      line: '',
      sets: sets ?? cur.sets,
      reps: reps ?? cur.reps,
      rpe: rpe ?? cur.rpe,
      note: note ?? cur.note,
    );
  } else {
    newDetails[setIndex] = cur.copyWith(note: note ?? cur.note);
  }
  final updated = syncMobilityItemPrescription(
    found.copyWith(setDetails: newDetails),
  );
  return updateMobilityItemInRoutine(routine: routine, item: updated);
}

WorkoutRoutine? removeSetFromMobilityItemInRoutine({
  required WorkoutRoutine routine,
  required String itemId,
  required int setIndex,
}) {
  MobilityItem? found;
  for (final e in routine.mobilityItems) {
    if (e.id == itemId) {
      found = e;
      break;
    }
  }
  if (found == null) return null;
  final details = found.effectiveSetDetails;
  if (details.length <= 1) return routine;
  if (setIndex < 0 || setIndex >= details.length) return routine;
  final newDetails = List<ExerciseSet>.from(details)..removeAt(setIndex);
  final updated = syncMobilityItemPrescription(
    found.copyWith(setDetails: newDetails),
  );
  return updateMobilityItemInRoutine(routine: routine, item: updated);
}
