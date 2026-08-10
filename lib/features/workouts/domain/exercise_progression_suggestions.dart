// Pure, suggest-only progression rules. Never mutates the plan directly —
// callers decide whether/how to apply a suggestion (see PR3 in the identity
// roadmap: "suggest-only", no silent auto-mutation of the plan).

import '../data/workout_routine_model.dart';
import 'session_execution.dart';

/// Kind of progression suggested for the next occurrence of an exercise.
enum ProgressionSuggestionType {
  /// Last full session was completed within the top of the rep range:
  /// suggest adding reps before adding load.
  increaseReps,

  /// Last full session was completed: suggest a small load bump.
  increaseLoad,

  /// Last session was only partially completed: keep prescription as-is.
  maintain,

  /// No matching logged session found for this exercise.
  insufficientData,
}

/// A single suggestion for one planned [Exercise], derived from local
/// session logs. Suggests a *replacement* value for load/reps; never
/// includes a delta the UI must interpret to stay unambiguous.
class ExerciseProgressionSuggestion {
  const ExerciseProgressionSuggestion({
    required this.type,
    this.suggestedLoad,
    this.suggestedReps,
  });

  final ProgressionSuggestionType type;

  /// New load/RPE text to apply (e.g. "82.5kg"). Null when the previous
  /// load wasn't numeric-parseable — the suggestion is still shown as a
  /// generic "increase load" hint with no concrete value to apply.
  final String? suggestedLoad;

  /// New reps text to apply (e.g. "9"). Only set for [increaseReps].
  final String? suggestedReps;

  bool get isActionable => suggestedLoad != null || suggestedReps != null;
}

const double _minLoadStep = 1.0;
const double _loadBumpFraction = 0.025;

/// Suggests a progression for [plannedExercise] based on the most recent
/// matching completed [executions] (whole-plan history, matched like
/// follow-up load carry-over: by exerciseId, falling back to name).
ExerciseProgressionSuggestion suggestExerciseProgression({
  required Exercise plannedExercise,
  required List<SessionExecution> executions,
}) {
  final latest = _latestMatchingExecutedExercise(plannedExercise, executions);
  if (latest == null || latest.sets.isEmpty) {
    return const ExerciseProgressionSuggestion(
      type: ProgressionSuggestionType.insufficientData,
    );
  }

  final isFullyCompleted =
      latest.completed && latest.sets.every((s) => s.completed);
  if (!isFullyCompleted) {
    return const ExerciseProgressionSuggestion(
      type: ProgressionSuggestionType.maintain,
    );
  }

  final repRange = _parseRepRange(plannedExercise.reps);
  final isRealRange = repRange != null && repRange.min != repRange.max;
  if (isRealRange && _hitTopOfRepRange(latest, repRange)) {
    final nextReps = repRange.max + 1;
    return ExerciseProgressionSuggestion(
      type: ProgressionSuggestionType.increaseReps,
      suggestedReps: '$nextReps',
    );
  }

  final lastLoad = _latestNonEmptyLoad(latest);
  final parsedLoad = lastLoad == null ? null : _parseLoad(lastLoad);
  if (parsedLoad == null) {
    return const ExerciseProgressionSuggestion(
      type: ProgressionSuggestionType.increaseLoad,
    );
  }
  final delta = (parsedLoad.value * _loadBumpFraction).clamp(
    _minLoadStep,
    double.infinity,
  );
  final nextValue = parsedLoad.value + delta;
  return ExerciseProgressionSuggestion(
    type: ProgressionSuggestionType.increaseLoad,
    suggestedLoad: '${_formatLoadNumber(nextValue)}${parsedLoad.unit}',
  );
}

ExecutedExercise? _latestMatchingExecutedExercise(
  Exercise plannedExercise,
  List<SessionExecution> executions,
) {
  final sorted = [...executions]
    ..sort((a, b) {
      final aDate = a.completedAt ?? a.sessionDate;
      final bDate = b.completedAt ?? b.sessionDate;
      return bDate.compareTo(aDate);
    });

  final keys = <String>[
    if (plannedExercise.id.isNotEmpty) plannedExercise.id,
    if (plannedExercise.name.trim().isNotEmpty)
      plannedExercise.name.trim().toLowerCase(),
  ];
  if (keys.isEmpty) return null;

  for (final execution in sorted) {
    for (final exercise in execution.exercises) {
      final matchKey = exercise.exerciseId.isNotEmpty
          ? exercise.exerciseId
          : exercise.name.trim().toLowerCase();
      if (matchKey.isEmpty) continue;
      if (keys.contains(matchKey)) return exercise;
    }
  }
  return null;
}

String? _latestNonEmptyLoad(ExecutedExercise exercise) {
  for (final set in exercise.sets.reversed) {
    if (set.load.trim().isNotEmpty) return set.load.trim();
  }
  return null;
}

({int min, int max})? _parseRepRange(String raw) {
  final normalized = raw.trim().replaceAll('–', '-').replaceAll('—', '-');
  if (normalized.isEmpty) return null;
  final parts = normalized.split('-');
  if (parts.length == 2) {
    final min = int.tryParse(parts[0].trim());
    final max = int.tryParse(parts[1].trim());
    if (min == null || max == null) return null;
    return (min: min, max: max);
  }
  final single = int.tryParse(normalized);
  if (single == null) return null;
  return (min: single, max: single);
}

bool _hitTopOfRepRange(
  ExecutedExercise exercise,
  ({int min, int max}) range,
) {
  final completedSets = exercise.sets.where((s) => s.completed).toList();
  if (completedSets.isEmpty) return false;
  var sawParseable = false;
  for (final set in completedSets) {
    final reps = int.tryParse(set.reps.trim());
    if (reps == null) continue;
    sawParseable = true;
    if (reps < range.max) return false;
  }
  return sawParseable;
}

({double value, String unit})? _parseLoad(String raw) {
  final match = RegExp(
    r'^(\d+(?:[.,]\d+)?)(\s*)(.*)$',
  ).firstMatch(raw.trim());
  if (match == null) return null;
  final numeric = double.tryParse(match.group(1)!.replaceAll(',', '.'));
  if (numeric == null) return null;
  final suffix = match.group(3) ?? '';
  final spacing = suffix.isEmpty ? '' : (match.group(2) ?? '');
  return (value: numeric, unit: '$spacing$suffix');
}

String _formatLoadNumber(double value) {
  final rounded = (value * 2).round() / 2; // nearest 0.5
  return rounded == rounded.roundToDouble()
      ? rounded.toInt().toString()
      : rounded.toStringAsFixed(1);
}
