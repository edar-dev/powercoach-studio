import '../../../l10n/app_localizations.dart';
import '../data/workout_routine_model.dart';

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
/// - sets / reps / rpe / setDetails stay empty (no prescription on mobility)
Exercise mobilityItemToPresentationExercise(MobilityItem item) {
  return Exercise(
    id: item.id,
    name: item.title,
    sets: '',
    reps: '',
    rpe: '',
    note: item.subtitle,
    shortName: item.shortTitle,
    setDetails: const [],
    customExerciseId: item.customExerciseId,
  );
}

/// Applies edits from a synthetic presentation [Exercise] back onto [original].
MobilityItem applyPresentationExerciseToItem(
  Exercise ex,
  MobilityItem original,
) {
  return original.copyWith(
    title: ex.name,
    subtitle: ex.note,
    shortTitle: ex.shortName,
  );
}
