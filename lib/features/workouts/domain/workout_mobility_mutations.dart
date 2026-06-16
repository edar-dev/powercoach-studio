import '../data/workout_routine_model.dart';

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
  final trimmed = name.trim();
  if (trimmed.isEmpty) return routine;
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

WorkoutRoutine updateMobilityItemInRoutine({
  required WorkoutRoutine routine,
  required String itemId,
  required String title,
  required String subtitle,
  String shortTitle = '',
}) {
  return routine.copyWith(
    mobilityItems: routine.mobilityItems
        .map(
          (e) => e.id == itemId
              ? e.copyWith(
                  title: title,
                  subtitle: subtitle,
                  shortTitle: shortTitle,
                )
              : e,
        )
        .toList(),
  );
}
