import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'workout_plan_repository.dart';
import 'workout_routine_model.dart';

const String workoutRoutineDraftPrefsKey = 'workout_routine_draft';

abstract class WorkoutDraftStore {
  Future<WorkoutRoutine> load();
  Future<void> save(WorkoutRoutine routine);
}

class SharedPrefsWorkoutDraftStore implements WorkoutDraftStore {
  const SharedPrefsWorkoutDraftStore();

  @override
  Future<WorkoutRoutine> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(workoutRoutineDraftPrefsKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      return WorkoutRoutine.empty();
    }
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return WorkoutRoutine.fromJson(map);
    } catch (_) {
      return WorkoutRoutine.empty();
    }
  }

  @override
  Future<void> save(WorkoutRoutine routine) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      workoutRoutineDraftPrefsKey,
      jsonEncode(routine.toJson()),
    );
  }
}

class WorkoutPlanDraftStore implements WorkoutDraftStore {
  const WorkoutPlanDraftStore({
    required WorkoutPlanRepository repository,
    required this.planId,
  }) : _repository = repository;

  final WorkoutPlanRepository _repository;
  final String planId;

  @override
  Future<WorkoutRoutine> load() async {
    final plan = await _repository.getById(planId);
    if (plan == null) return WorkoutRoutine.empty();
    return planDataToRoutine(plan.planData);
  }

  @override
  Future<void> save(WorkoutRoutine routine) async {
    await _repository.update(
      planId: planId,
      name: routine.name,
      planDataJson: jsonEncode(routine.toJson()),
    );
  }
}
