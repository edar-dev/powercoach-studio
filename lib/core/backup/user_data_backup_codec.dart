import 'dart:convert';

import '../settings/settings_prefs_keys.dart';
import '../sync/offline_models.dart';
import '../../features/workouts/domain/session_execution.dart';

/// Stable identifier for the JSON envelope (do not rename without a version bump).
const kUserBackupExportFormat = 'powercoach_user_backup_v1';

/// Schema version supported by this build's import path.
const kUserBackupSchemaVersion = 1;

class UserBackupImportException implements Exception {
  UserBackupImportException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Preference keys restored from the backup `preferences` object.
class BackupPreferences {
  const BackupPreferences({
    required this.notificationsEnabled,
    this.localeCode,
    this.calendarRemindersEnabled,
    this.calendarReminderLeadHours,
    this.workoutBuilderCompactAdd,
    this.hasWorkoutBuilderCompactAdd = false,
    this.workoutBuilderIncludeMobilityDefault,
    this.raw = const {},
  });

  final bool notificationsEnabled;
  final String? localeCode;
  final bool? calendarRemindersEnabled;
  final int? calendarReminderLeadHours;

  /// When [hasWorkoutBuilderCompactAdd] is true, [workoutBuilderCompactAdd]
  /// is applied (including `null` to clear the override).
  final bool? workoutBuilderCompactAdd;
  final bool hasWorkoutBuilderCompactAdd;
  final bool? workoutBuilderIncludeMobilityDefault;

  /// Full preferences map for repository apply helpers.
  final Map<String, dynamic> raw;
}

/// Normalized payload ready to apply to local stores.
class ParsedUserBackup {
  ParsedUserBackup({
    required this.entities,
    required this.pendingOperations,
    required this.syncMeta,
    required this.profileJson,
    required this.preferences,
    required this.reminders,
    this.exportedAt,
    this.appVersion,
    this.entityCounts,
  });

  final List<Map<String, dynamic>> entities;

  /// Legacy rows still parsed for older backups; restore ignores them.
  final List<Map<String, dynamic>> pendingOperations;
  final List<Map<String, dynamic>> syncMeta;
  final Map<String, dynamic>? profileJson;
  final BackupPreferences preferences;

  /// Optional reminder rows (Feature 02). Maps are validated on restore.
  final List<Map<String, dynamic>> reminders;

  /// Optional export metadata (ignored by older builds on import).
  final String? exportedAt;
  final String? appVersion;
  final Map<String, int>? entityCounts;

  bool get notificationsEnabled => preferences.notificationsEnabled;
}

/// Validates and parses user backup JSON. Unknown top-level keys are ignored.
///
/// Workout plan lifecycle markers (`archivedAt`, `completedAt`) live inside each
/// plan entity's `planData` JSON blob; they are preserved automatically on export
/// because entity payloads are copied verbatim.
ParsedUserBackup parseUserBackupJson(String jsonText, String expectedAccountUserId) {
  if (expectedAccountUserId.isEmpty) {
    throw UserBackupImportException('missing_account');
  }
  final decoded = jsonDecode(jsonText);
  if (decoded is! Map) {
    throw UserBackupImportException('invalid_root');
  }
  final root = decoded.cast<String, dynamic>();

  final schemaRaw = root['schemaVersion'];
  final schemaVersion = schemaRaw is int
      ? schemaRaw
      : schemaRaw is num
          ? schemaRaw.toInt()
          : null;
  if (schemaVersion != kUserBackupSchemaVersion) {
    throw UserBackupImportException('unsupported_schema');
  }

  final format = root['exportFormat']?.toString();
  if (format != kUserBackupExportFormat) {
    throw UserBackupImportException('wrong_format');
  }

  final accountUserId = root['accountUserId']?.toString() ?? '';
  if (accountUserId != expectedAccountUserId) {
    throw UserBackupImportException('wrong_account');
  }

  final entities = _parseEntityList(root['entities']);
  final pending = _parsePendingList(root['pendingOperations']);
  final syncMeta = _parseSyncMetaList(root['syncMeta']);
  final reminders = _parseRemindersList(root['reminders']);
  final preferences = _parsePreferences(root['preferences']);

  Map<String, dynamic>? profileJson;
  final profileRaw = root['localUserProfile'];
  if (profileRaw is Map<String, dynamic>) {
    profileJson = profileRaw;
  } else if (profileRaw is Map) {
    profileJson = profileRaw.cast<String, dynamic>();
  }

  return ParsedUserBackup(
    entities: entities,
    pendingOperations: pending,
    syncMeta: syncMeta,
    profileJson: profileJson,
    preferences: preferences,
    reminders: reminders,
    exportedAt: root['exportedAt']?.toString(),
    appVersion: root['appVersion']?.toString(),
    entityCounts: _parseEntityCounts(root['entityCounts']),
  );
}

BackupPreferences _parsePreferences(dynamic raw) {
  if (raw is! Map) {
    return const BackupPreferences(notificationsEnabled: true);
  }
  final prefs = raw.cast<String, dynamic>();
  var notificationsEnabled = true;
  final n = prefs[SettingsPrefsKeys.notificationsEnabled];
  if (n is bool) notificationsEnabled = n;

  final localeRaw = prefs[SettingsPrefsKeys.appLocaleCode]?.toString();
  final localeCode =
      (localeRaw != null && localeRaw.isNotEmpty) ? localeRaw : null;

  bool? calendarRemindersEnabled;
  final cal = prefs[SettingsPrefsKeys.calendarRemindersEnabled];
  if (cal is bool) calendarRemindersEnabled = cal;

  int? calendarReminderLeadHours;
  final lead = prefs[SettingsPrefsKeys.calendarReminderLeadHours];
  if (lead is int) {
    calendarReminderLeadHours = lead;
  } else if (lead is num) {
    calendarReminderLeadHours = lead.toInt();
  }

  final hasCompact =
      prefs.containsKey(SettingsPrefsKeys.workoutBuilderCompactAdd);
  bool? compactAdd;
  if (hasCompact) {
    final c = prefs[SettingsPrefsKeys.workoutBuilderCompactAdd];
    if (c is bool) compactAdd = c;
  }

  bool? mobilityDefault;
  final mob = prefs[SettingsPrefsKeys.workoutBuilderIncludeMobilityDefault];
  if (mob is bool) mobilityDefault = mob;

  return BackupPreferences(
    notificationsEnabled: notificationsEnabled,
    localeCode: localeCode,
    calendarRemindersEnabled: calendarRemindersEnabled,
    calendarReminderLeadHours: calendarReminderLeadHours,
    workoutBuilderCompactAdd: compactAdd,
    hasWorkoutBuilderCompactAdd: hasCompact,
    workoutBuilderIncludeMobilityDefault: mobilityDefault,
    raw: prefs,
  );
}

Map<String, int>? _parseEntityCounts(dynamic raw) {
  if (raw is! Map) return null;
  final out = <String, int>{};
  for (final entry in raw.entries) {
    final key = entry.key.toString();
    final value = entry.value;
    if (value is int) {
      out[key] = value;
    } else if (value is num) {
      out[key] = value.toInt();
    }
  }
  return out.isEmpty ? null : out;
}

List<Map<String, dynamic>> _parseEntityList(dynamic raw) {
  if (raw == null) return [];
  if (raw is! List) throw UserBackupImportException('entities_not_list');
  final out = <Map<String, dynamic>>[];
  for (final item in raw) {
    if (item is! Map) throw UserBackupImportException('entity_invalid');
    final m = item.cast<String, dynamic>();
    final id = m['id']?.toString() ?? '';
    if (id.isEmpty) throw UserBackupImportException('entity_missing_id');
    out.add(m);
  }
  return out;
}

List<Map<String, dynamic>> _parsePendingList(dynamic raw) {
  if (raw == null) return [];
  if (raw is! List) throw UserBackupImportException('pending_not_list');
  final out = <Map<String, dynamic>>[];
  for (final item in raw) {
    if (item is! Map) throw UserBackupImportException('pending_invalid');
    final m = item.cast<String, dynamic>();
    final id = m['id']?.toString() ?? '';
    if (id.isEmpty) throw UserBackupImportException('pending_missing_id');
    out.add(m);
  }
  return out;
}

List<Map<String, dynamic>> _parseSyncMetaList(dynamic raw) {
  if (raw == null) return [];
  if (raw is! List) throw UserBackupImportException('sync_meta_not_list');
  final out = <Map<String, dynamic>>[];
  for (final item in raw) {
    if (item is! Map) throw UserBackupImportException('sync_meta_invalid');
    final m = item.cast<String, dynamic>();
    final key = m['metaKey']?.toString() ?? '';
    if (key.isEmpty) continue;
    out.add(m);
  }
  return out;
}

/// Reminder backup rows: tolerate wrong shapes (ignored on restore).
List<Map<String, dynamic>> _parseRemindersList(dynamic raw) {
  if (raw == null) return [];
  if (raw is! List) return [];
  final out = <Map<String, dynamic>>[];
  for (final item in raw) {
    if (item is! Map) continue;
    out.add(item.cast<String, dynamic>());
  }
  return out;
}

/// Entity counts shown in the backup import preview dialog.
class BackupPreviewCounts {
  const BackupPreviewCounts({
    required this.customers,
    required this.customerRecords,
    required this.plans,
    required this.executions,
    required this.exerciseLibrary,
    required this.reminders,
  });

  final int customers;
  final int customerRecords;
  final int plans;
  final int executions;
  final int exerciseLibrary;
  final int reminders;

  int get customersGroupTotal => customers + customerRecords;
}

/// Summarizes backup contents for import preview.
BackupPreviewCounts previewCountsFromBackup(ParsedUserBackup parsed) {
  return entityCountsFromBackupEntities(
    parsed.entities,
    reminders: parsed.reminders.length,
  );
}

/// Counts for import preview and export envelope metadata.
BackupPreviewCounts entityCountsFromBackupEntities(
  List<Map<String, dynamic>> entities, {
  required int reminders,
}) {
  var customers = 0;
  var customerRecords = 0;
  var plans = 0;
  var executions = 0;
  var exerciseLibrary = 0;

  for (final entity in entities) {
    final type = entity['type']?.toString();
    if (type == OfflineEntityType.customer.name) {
      customers++;
    } else if (type == OfflineEntityType.measurement.name ||
        type == OfflineEntityType.exerciseRecord.name ||
        type == OfflineEntityType.customerNote.name) {
      customerRecords++;
    }
    if (type == OfflineEntityType.customExercise.name) {
      exerciseLibrary++;
    }
    if (type == OfflineEntityType.workoutPlan.name ||
        entity.containsKey('planData')) {
      plans++;
    }
    executions += _countSessionExecutionsInEntity(entity);
  }

  return BackupPreviewCounts(
    customers: customers,
    customerRecords: customerRecords,
    plans: plans,
    executions: executions,
    exerciseLibrary: exerciseLibrary,
    reminders: reminders,
  );
}

Map<String, int> entityCountsMapFromPreview(BackupPreviewCounts counts) {
  return <String, int>{
    'customers': counts.customers,
    'customerRecords': counts.customerRecords,
    'workoutPlans': counts.plans,
    'exerciseLibrary': counts.exerciseLibrary,
    'reminders': counts.reminders,
  };
}

int _countSessionExecutionsInEntity(Map<String, dynamic> entity) {
  final payload = entity['payload'];
  if (payload is Map) {
    final planData = payload['planData'];
    return _countExecutionsInPlanData(planData);
  }
  if (entity.containsKey('planData')) {
    return _countExecutionsInPlanData(entity['planData']);
  }
  return 0;
}

int _countExecutionsInPlanData(dynamic planData) {
  if (planData is String) {
    try {
      final decoded = jsonDecode(planData);
      if (decoded is Map) {
        return parseSessionExecutions(decoded['sessionExecutions']).length;
      }
    } catch (_) {
      return 0;
    }
    return 0;
  }
  if (planData is Map) {
    return parseSessionExecutions(planData['sessionExecutions']).length;
  }
  return 0;
}
