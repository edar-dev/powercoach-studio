import '../../../l10n/app_localizations.dart';
import '../data/workout_routine_model.dart';

/// Suggested phase names for the "Aggiungi Fase" sheet.
enum WorkoutPhasePreset {
  accumulation,
  intensification,
  peak,
  deload,
  mass,
  definition,
  volume,
  acclimation,
  general,
  custom,
}

extension WorkoutPhasePresetX on WorkoutPhasePreset {
  /// Stable English name persisted in [Phase.name] for non-custom presets.
  String get storageName => switch (this) {
        WorkoutPhasePreset.accumulation => 'Accumulo',
        WorkoutPhasePreset.intensification => 'Intensificazione',
        WorkoutPhasePreset.peak => 'Picco',
        WorkoutPhasePreset.deload => 'Deload',
        WorkoutPhasePreset.mass => 'Massa',
        WorkoutPhasePreset.definition => 'Definizione',
        WorkoutPhasePreset.volume => 'Volume',
        WorkoutPhasePreset.acclimation => 'Acclimatazione',
        WorkoutPhasePreset.general => kDefaultPhaseName,
        WorkoutPhasePreset.custom => '',
      };

  String localizedLabel(AppLocalizations l10n) => switch (this) {
        WorkoutPhasePreset.accumulation => l10n.workoutPhasePresetAccumulo,
        WorkoutPhasePreset.intensification =>
          l10n.workoutPhasePresetIntensificazione,
        WorkoutPhasePreset.peak => l10n.workoutPhasePresetPicco,
        WorkoutPhasePreset.deload => l10n.workoutPhasePresetDeload,
        WorkoutPhasePreset.mass => l10n.workoutPhasePresetMassa,
        WorkoutPhasePreset.definition => l10n.workoutPhasePresetDefinizione,
        WorkoutPhasePreset.volume => l10n.workoutPhasePresetVolume,
        WorkoutPhasePreset.acclimation => l10n.workoutPhasePresetAcclimatazione,
        WorkoutPhasePreset.general => l10n.workoutPhasePresetGeneral,
        WorkoutPhasePreset.custom => l10n.workoutPhasePresetCustom,
      };
}

/// Presets shown as chips (excludes [WorkoutPhasePreset.custom]).
const List<WorkoutPhasePreset> kWorkoutPhasePresetChips = [
  WorkoutPhasePreset.accumulation,
  WorkoutPhasePreset.intensification,
  WorkoutPhasePreset.peak,
  WorkoutPhasePreset.deload,
  WorkoutPhasePreset.mass,
  WorkoutPhasePreset.definition,
  WorkoutPhasePreset.volume,
  WorkoutPhasePreset.acclimation,
  WorkoutPhasePreset.general,
];

/// Localized display name for a stored phase name (handles default General).
String localizedPhaseName(AppLocalizations l10n, String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty || trimmed == kDefaultPhaseName) {
    return l10n.workoutPhasePresetGeneral;
  }
  for (final preset in kWorkoutPhasePresetChips) {
    if (preset.storageName == trimmed) {
      return preset.localizedLabel(l10n);
    }
  }
  return trimmed;
}

/// Average sessions/week for a phase (mean day count across weeks; 0 if empty).
double phaseAverageSessionsPerWeek(Phase phase) {
  if (phase.weeks.isEmpty) return 0;
  final totalDays = phase.weeks.fold<int>(0, (sum, w) => sum + w.days.length);
  return totalDays / phase.weeks.length;
}

/// Progress 0–100 from [sessionCompletionByKey] for weeks in [phase] starting
/// at global week index [globalWeekOffset].
int phaseProgressPercent({
  required Phase phase,
  required int globalWeekOffset,
  required Map<String, bool> sessionCompletionByKey,
}) {
  var total = 0;
  var completed = 0;
  for (var wi = 0; wi < phase.weeks.length; wi++) {
    final week = phase.weeks[wi];
    final globalWeek = globalWeekOffset + wi;
    for (var di = 0; di < week.days.length; di++) {
      total++;
      if (sessionCompletionByKey[WorkoutRoutine.sessionKey(globalWeek, di)] ==
          true) {
        completed++;
      }
    }
  }
  if (total == 0) return 0;
  return ((completed / total) * 100).round().clamp(0, 100);
}
