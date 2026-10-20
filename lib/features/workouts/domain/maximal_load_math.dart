/// Applies a percentage of a massimale (kg).
///
/// `raw = maximalKg * (percent / 100)`
double applyPercentOfMaximal({
  required double maximalKg,
  required num percent,
}) {
  return maximalKg * (percent / 100);
}

/// Rounds [rawKg] to the nearest [incrementKg] (coach preference: 0.5 / 1 / 2.5).
///
/// Returns [rawKg] unchanged when [incrementKg] is not positive.
double roundToIncrement(double rawKg, double incrementKg) {
  if (incrementKg <= 0) return rawKg;
  return (rawKg / incrementKg).round() * incrementKg;
}

/// Shared apply used by % chips and the slider.
///
/// `displayKg = roundToIncrement(maximalKg * percent / 100, incrementKg)`
double applyPercentRounded({
  required double maximalKg,
  required num percent,
  required double incrementKg,
}) {
  return roundToIncrement(
    applyPercentOfMaximal(maximalKg: maximalKg, percent: percent),
    incrementKg,
  );
}

/// Formats a rounded kg value for the set load field (e.g. `"80kg"`, `"107.5kg"`).
///
/// Matches existing load hints (`75kg`) and volume parsers that accept a `kg`
/// suffix. Whole kilograms omit the decimal; half kilograms use one decimal.
String formatMaximalLoadKg(double kg) {
  final asInt = kg.round();
  if ((kg - asInt).abs() < 1e-6) {
    return '${asInt}kg';
  }
  final oneDecimal = (kg * 10).round() / 10.0;
  if ((oneDecimal - oneDecimal.roundToDouble()).abs() < 1e-9) {
    return '${oneDecimal.round()}kg';
  }
  final trimmed = oneDecimal.toStringAsFixed(1);
  return '${trimmed}kg';
}

/// Coach-oriented % presets for the set-editor chip row.
const List<int> kMaximalPercentPresets = [
  50,
  60,
  65,
  70,
  75,
  80,
  85,
  90,
  95,
];

/// Slider range for % of massimale (inclusive).
const int kMaximalPercentSliderMin = 40;
const int kMaximalPercentSliderMax = 100;
