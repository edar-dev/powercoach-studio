/// Standard % ladder for powerlifting-style reference loads.
const List<int> kExerciseLoadPercentLadder = [
  100,
  95,
  90,
  85,
  80,
  75,
  70,
  65,
  60,
  55,
  50,
];

bool isMassBasedExerciseRecordUnit(String unit) {
  final u = unit.trim().toLowerCase();
  return u == 'kg' || u == 'lb' || u == 'lbs';
}

String formatExerciseLoadForDisplay(double v) {
  final rounded = (v * 10).round() / 10;
  if ((rounded - rounded.round()).abs() < 1e-9) {
    return rounded.round().toString();
  }
  return rounded.toStringAsFixed(1);
}
