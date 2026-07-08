import 'package:flutter/material.dart';

import '../data/workout_routine_model.dart';

/// Picks a routine start date; returns normalized date-only value or null.
Future<DateTime?> pickWorkoutRoutineStartDate(
  BuildContext context, {
  DateTime? currentStart,
}) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final initial = currentStart ?? today;
  final picked = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: DateTime(2000),
    lastDate: DateTime(now.year + 10, 12, 31),
  );
  if (picked == null) return null;
  return DateTime(picked.year, picked.month, picked.day);
}

/// Picks a routine end date constrained by [startDate]; returns date-only or null.
Future<DateTime?> pickWorkoutRoutineEndDate(
  BuildContext context, {
  DateTime? startDate,
  DateTime? currentEnd,
}) async {
  final now = DateTime.now();
  final fallback = DateTime(now.year, now.month, now.day);
  final initial = currentEnd ?? startDate ?? fallback;
  final firstDate = startDate ?? DateTime(2000);
  final picked = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: DateTime(firstDate.year, firstDate.month, firstDate.day),
    lastDate: DateTime(now.year + 10, 12, 31),
  );
  if (picked == null) return null;
  return DateTime(picked.year, picked.month, picked.day);
}

WorkoutRoutine applyRoutineStartDate(WorkoutRoutine routine, DateTime date) {
  return routine.copyWith(startDate: date);
}

WorkoutRoutine applyRoutineEndDate(WorkoutRoutine routine, DateTime date) {
  return routine.copyWith(endDate: date);
}
