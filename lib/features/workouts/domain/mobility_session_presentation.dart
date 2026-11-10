import '../../../l10n/app_localizations.dart';
import '../data/workout_routine_model.dart';
import 'collapsed_prescription_summary.dart';
import 'exercise_summary_sync.dart';

/// True when [name] is empty or a legacy auto-numbered default
/// (`Section 1`, `Sezione 2`, …).
bool isUnsetMobilitySectionName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return true;
  return RegExp(
    r'^(section|sezione)\s+\d+$',
    caseSensitive: false,
  ).hasMatch(trimmed);
}

/// Localized chip/label for a mobility section; keeps persisted name unchanged.
String mobilitySectionDisplayName({
  required String name,
  required int index,
  required AppLocalizations l10n,
}) {
  if (isUnsetMobilitySectionName(name)) {
    return l10n.workoutBuilderSectionNumbered(index + 1);
  }
  return name.trim();
}

/// Presentation bridge: one [MobilitySection] + its items as a synthetic [Day].
///
/// Synthetic [Exercise]s are never persisted — they exist only to drive shared
/// day/session widgets ([WorkoutDayExerciseList], [SessionExerciseEditorCard]).
class MobilitySectionSessionView {
  const MobilitySectionSessionView({
    required this.section,
    required this.sectionIndex,
    required this.items,
  });

  final MobilitySection section;
  final int sectionIndex;
  final List<MobilityItem> items;

  /// Synthetic day for shared session list/editor chrome.
  Day toPresentationDay(AppLocalizations l10n) {
    return Day(
      id: section.id,
      name: mobilitySectionDisplayName(
        name: section.name,
        index: sectionIndex,
        l10n: l10n,
      ),
      exercises: [
        for (final item in items) mobilityItemToPresentationExercise(item),
      ],
    );
  }
}

/// Maps a mobility item to a synthetic [Exercise] for shared session widgets.
///
/// - [Exercise.name] ← [MobilityItem.title]
/// - [Exercise.note] ← [MobilityItem.subtitle]
/// - [Exercise.shortName] ← [MobilityItem.shortTitle]
/// - sets / reps / rpe / setDetails / prescriptionScope / maximalRef mapped 1:1
Exercise mobilityItemToPresentationExercise(MobilityItem item) {
  // Prefer explicit setDetails / top-level sets·reps; otherwise seed one empty
  // row so the shared set table works without copying [subtitle] into set.note.
  final List<ExerciseSet> details = item.setDetails != null &&
          item.setDetails!.isNotEmpty
      ? item.setDetails!
      : (item.sets.trim().isNotEmpty || item.reps.trim().isNotEmpty)
          ? [
              ExerciseSet(
                sets: item.sets.trim().isEmpty ? '1' : item.sets,
                reps: item.reps,
                rpe: item.rpe,
              ),
            ]
          : const [ExerciseSet()];
  return Exercise(
    id: item.id,
    name: item.title,
    sets: item.sets,
    reps: item.reps,
    rpe: item.rpe,
    note: item.subtitle,
    shortName: item.shortTitle,
    setDetails: details,
    prescriptionScope: item.prescriptionScope,
    customExerciseId: item.customExerciseId,
    maximalRef: item.maximalRef,
  );
}

bool _isEmptyPrescriptionSet(ExerciseSet set) {
  return set.line.trim().isEmpty &&
      set.reps.trim().isEmpty &&
      set.rpe.trim().isEmpty &&
      set.note.trim().isEmpty &&
      (set.sets.trim().isEmpty || set.sets.trim() == '1');
}

bool mobilitySetDetailsAreMeaningful(List<ExerciseSet>? details) {
  if (details == null || details.isEmpty) return false;
  return details.any((set) => !_isEmptyPrescriptionSet(set));
}

/// Applies edits from a synthetic presentation [Exercise] back onto [original].
///
/// Preserves [MobilityItem.sectionId] / [MobilityItem.categoryIndex] from
/// [original]. Pass [clearMaximalRef] to drop an existing massimale link.
///
/// Empty seeded [Exercise.setDetails] (used so the shared set table has a row)
/// are not written onto legacy subtitle-only items.
MobilityItem applyPresentationExerciseToItem(
  Exercise ex,
  MobilityItem original, {
  bool clearMaximalRef = false,
}) {
  final incomingMeaningful = mobilitySetDetailsAreMeaningful(ex.setDetails);
  return original.copyWith(
    title: ex.name,
    subtitle: ex.note,
    shortTitle: ex.shortName,
    sets: incomingMeaningful ? ex.sets : original.sets,
    reps: incomingMeaningful ? ex.reps : original.reps,
    rpe: incomingMeaningful ? ex.rpe : original.rpe,
    setDetails: incomingMeaningful ? ex.setDetails : original.setDetails,
    prescriptionScope: ex.prescriptionScope,
    maximalRef: clearMaximalRef ? null : (ex.maximalRef ?? original.maximalRef),
    clearMaximalRef: clearMaximalRef,
    customExerciseId: ex.customExerciseId ?? original.customExerciseId,
  );
}

/// Syncs legacy summary fields from [MobilityItem.setDetails] via Exercise bridge.
MobilityItem syncMobilityItemPrescription(MobilityItem item) {
  final synced = ExerciseSummarySync.apply(
    mobilityItemToPresentationExercise(item),
  );
  return applyPresentationExerciseToItem(synced, item);
}

/// Collapsed preview / row detail for a mobility item.
String mobilityItemPreviewDetail(MobilityItem item) {
  final rx = collapsedPrescriptionSummary(item.effectiveSetDetails);
  if (rx.isNotEmpty) return rx;
  final subtitle = item.subtitle.trim();
  if (subtitle.isNotEmpty) return subtitle;
  return item.shortTitle.trim();
}
