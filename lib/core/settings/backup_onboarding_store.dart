import 'package:shared_preferences/shared_preferences.dart';

/// Tracks whether the coach has seen the first-run backup guidance.
class BackupOnboardingStore {
  BackupOnboardingStore._();

  static final BackupOnboardingStore instance = BackupOnboardingStore._();

  static String _keyFor(String userId) => 'backup_onboarding_seen_$userId';

  Future<bool> hasSeen(String userId) async {
    if (userId.isEmpty) return true;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFor(userId)) ?? false;
  }

  Future<void> markSeen(String userId) async {
    if (userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFor(userId), true);
  }
}
