/// Whether an exercise prescription is repeated across mesocycle weeks.
enum ExercisePrescriptionScope {
  /// Prescription may differ per week column (default).
  perWeek,

  /// Same prescription for every week — PDF merges week cells.
  allWeeks;

  static ExercisePrescriptionScope fromJson(String? value) {
    if (value == allWeeks.name) return allWeeks;
    return perWeek;
  }

  String toJson() => name;
}
