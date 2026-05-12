import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../settings/settings_prefs_keys.dart';
import 'reminder.dart';

/// Persists [Reminder] list as JSON in SharedPreferences.
class ReminderStore {
  ReminderStore._();

  static final ReminderStore instance = ReminderStore._();

  Future<List<Reminder>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(SettingsPrefsKeys.remindersListJson);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      final out = <Reminder>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        final r = Reminder.tryFromJson(item.cast<String, dynamic>());
        if (r != null) out.add(r);
      }
      return out;
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAll(List<Reminder> list) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString(SettingsPrefsKeys.remindersListJson, encoded);
  }

  Future<void> add(Reminder reminder) async {
    final list = await loadAll();
    list.removeWhere((r) => r.id == reminder.id);
    list.add(reminder);
    await _saveAll(list);
  }

  Future<void> removeById(String id) async {
    final list = await loadAll();
    list.removeWhere((r) => r.id == id);
    await _saveAll(list);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SettingsPrefsKeys.remindersListJson);
  }

  /// Replace all reminders (e.g. backup restore). Invalid entries are skipped.
  Future<void> replaceFromMaps(List<Map<String, dynamic>> maps) async {
    final out = <Reminder>[];
    for (final m in maps) {
      final r = Reminder.tryFromJson(m);
      if (r != null) out.add(r);
    }
    await _saveAll(out);
  }

  Future<List<Map<String, dynamic>>> exportMaps() async {
    final list = await loadAll();
    return list.map((e) => e.toJson()).toList();
  }
}
