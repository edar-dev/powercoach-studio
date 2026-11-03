import 'maximal_load_math.dart';
import 'workout_diary_metrics.dart';

/// Display-only split of the free-text [ExerciseSet.rpe] / load cell.
///
/// Does **not** add a percent field to the model — % is derived when both
/// parseable load kg and a resolved maximal kg are available.
class SetLoadDisplay {
  const SetLoadDisplay({
    required this.percentLabel,
    required this.loadLabel,
    required this.rpeLabel,
  });

  /// Target % cell, e.g. `"80%"` or `"—"`.
  final String percentLabel;

  /// KG cell without unit suffix, e.g. `"60"` / `"107.5"` or `"—"`.
  final String loadLabel;

  /// RPE cell, e.g. `"8"` / `"8.5"` or `"—"`.
  final String rpeLabel;
}

/// Parses [rawLoad] with [parseLoadKg] / [parseRpeFromLoad] for table cells.
///
/// [resolvedMaximalKg] is optional and must already be known by the caller —
/// do not resolve asynchronously per row. When missing or non-positive, % is `"—"`.
SetLoadDisplay formatSetLoadDisplay(
  String rawLoad, {
  double? resolvedMaximalKg,
  bool hasMaximalRef = false,
}) {
  final loadKg = parseLoadKg(rawLoad);
  final rpe = parseRpeFromLoad(rawLoad);

  final loadLabel =
      loadKg == null ? '—' : formatMaximalDisplayKg(loadKg);
  final rpeLabel = rpe == null ? '—' : _formatRpe(rpe);

  final canShowPercent = hasMaximalRef &&
      loadKg != null &&
      resolvedMaximalKg != null &&
      resolvedMaximalKg > 0;
  final percentLabel = canShowPercent
      ? '${(loadKg / resolvedMaximalKg * 100).round()}%'
      : '—';

  return SetLoadDisplay(
    percentLabel: percentLabel,
    loadLabel: loadLabel,
    rpeLabel: rpeLabel,
  );
}

String _formatRpe(double rpe) {
  final asInt = rpe.round();
  if ((rpe - asInt).abs() < 1e-6) return asInt.toString();
  return rpe.toStringAsFixed(1);
}
