import 'export_pdf_usecase.dart';

/// Fixed PDF export presets shown in the workout export sheet.
enum WorkoutExportPreset {
  /// Dense gym-floor layout; all weeks; mobility off by default.
  gym,

  /// Canonical full layout; all weeks; mobility on when items exist.
  full,

  /// Dense layout for week index 0 only; mobility off.
  week1Only,
}

/// Resolved layout / mobility / week scope for a [WorkoutExportPreset].
class WorkoutExportPresetOptions {
  const WorkoutExportPresetOptions({
    required this.preset,
    required this.layout,
    required this.includeMobility,
    this.weekIndices,
  });

  final WorkoutExportPreset preset;
  final WorkoutPdfLayout layout;
  final bool includeMobility;

  /// `null` or empty = all weeks.
  final List<int>? weekIndices;
}

/// Pure mapping from preset (+ mobility availability) → export options.
WorkoutExportPresetOptions resolveWorkoutExportPreset(
  WorkoutExportPreset preset, {
  required bool hasMobilityItems,
}) {
  switch (preset) {
    case WorkoutExportPreset.gym:
      return const WorkoutExportPresetOptions(
        preset: WorkoutExportPreset.gym,
        layout: WorkoutPdfLayout.dense,
        includeMobility: false,
        weekIndices: null,
      );
    case WorkoutExportPreset.full:
      return WorkoutExportPresetOptions(
        preset: WorkoutExportPreset.full,
        layout: WorkoutPdfLayout.canonical,
        includeMobility: hasMobilityItems,
        weekIndices: null,
      );
    case WorkoutExportPreset.week1Only:
      return const WorkoutExportPresetOptions(
        preset: WorkoutExportPreset.week1Only,
        layout: WorkoutPdfLayout.dense,
        includeMobility: false,
        weekIndices: [0],
      );
  }
}
