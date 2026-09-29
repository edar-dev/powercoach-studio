import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../settings/settings_prefs_keys.dart';

/// Persists auto cloud-snapshot preferences and last status for Settings UX.
class AutoCloudSnapshotStore extends ChangeNotifier {
  AutoCloudSnapshotStore({bool? defaultEnabledOnWeb})
    : _defaultEnabledOnWeb = defaultEnabledOnWeb ?? kIsWeb;

  static final AutoCloudSnapshotStore instance = AutoCloudSnapshotStore();

  final bool _defaultEnabledOnWeb;

  String _enabledKey() => SettingsPrefsKeys.autoCloudSnapshotEnabled;

  String _lastErrorKey(String userId) =>
      '${SettingsPrefsKeys.autoCloudSnapshotLastError}_$userId';

  String _lastAtKey(String userId) =>
      '${SettingsPrefsKeys.autoCloudSnapshotLastAt}_$userId';

  String _hintDismissedKey(String userId) =>
      '${SettingsPrefsKeys.storagePersistedHintDismissed}_$userId';

  String _lastCloudSyncKey(String userId) =>
      '${SettingsPrefsKeys.lastCloudSyncAt}_$userId';

  /// Default **true on web** when the preference has never been set; false
  /// on non-web unless the user explicitly enables it.
  Future<bool> isAutoEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_enabledKey())) {
      return _defaultEnabledOnWeb;
    }
    return prefs.getBool(_enabledKey()) ?? false;
  }

  Future<void> setAutoEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey(), enabled);
    notifyListeners();
  }

  Future<DateTime?> lastSuccessAt(String userId) async {
    if (userId.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastAtKey(userId));
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  Future<String?> lastError(String userId) async {
    if (userId.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastErrorKey(userId));
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  Future<DateTime?> lastCloudSyncAt(String userId) async {
    if (userId.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastCloudSyncKey(userId));
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> markSuccess(String userId, {DateTime? at}) async {
    if (userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final timestamp = (at ?? DateTime.now()).toUtc();
    await prefs.setString(_lastAtKey(userId), timestamp.toIso8601String());
    await prefs.remove(_lastErrorKey(userId));
    notifyListeners();
  }

  Future<void> markError(String userId, String message) async {
    if (userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastErrorKey(userId), message);
    notifyListeners();
  }

  Future<void> markCloudSyncSuccess(String userId, {DateTime? at}) async {
    if (userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final timestamp = (at ?? DateTime.now()).toUtc();
    await prefs.setString(
      _lastCloudSyncKey(userId),
      timestamp.toIso8601String(),
    );
    await prefs.remove(_lastErrorKey(userId));
    notifyListeners();
  }

  Future<bool> isStoragePersistHintDismissed(String userId) async {
    if (userId.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hintDismissedKey(userId)) ?? false;
  }

  Future<void> dismissStoragePersistHint(String userId) async {
    if (userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hintDismissedKey(userId), true);
    notifyListeners();
  }

  Future<void> clearForUser(String userId) async {
    if (userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastAtKey(userId));
    await prefs.remove(_lastErrorKey(userId));
    await prefs.remove(_lastCloudSyncKey(userId));
    await prefs.remove(_hintDismissedKey(userId));
    notifyListeners();
  }
}
