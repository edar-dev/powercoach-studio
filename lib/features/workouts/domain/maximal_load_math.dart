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
