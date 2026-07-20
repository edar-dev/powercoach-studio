import 'package:shared_preferences/shared_preferences.dart';

/// Tracks whether the coach has dismissed the first-run workout builder checklist.
class WorkoutBuilderOnboardingStore {
  WorkoutBuilderOnboardingStore._();

  static final WorkoutBuilderOnboardingStore instance =
      WorkoutBuilderOnboardingStore._();

  static String _keyFor(String userId) =>
      'workout_builder_onboarding_dismissed_$userId';

  Future<bool> isDismissed(String userId) async {
    if (userId.isEmpty) return true;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFor(userId)) ?? false;
  }

  Future<void> markDismissed(String userId) async {
    if (userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFor(userId), true);
  }
}
