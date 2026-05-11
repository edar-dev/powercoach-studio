import 'dart:convert';

import '../settings/settings_prefs_keys.dart';

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

/// Normalized payload ready to apply to local stores.
class ParsedUserBackup {
  ParsedUserBackup({
    required this.entities,
    required this.pendingOperations,
    required this.syncMeta,
    required this.profileJson,
    required this.notificationsEnabled,
  });

  final List<Map<String, dynamic>> entities;
  final List<Map<String, dynamic>> pendingOperations;
  final List<Map<String, dynamic>> syncMeta;
  final Map<String, dynamic>? profileJson;
  final bool notificationsEnabled;
}

/// Validates and parses user backup JSON. Unknown top-level keys are ignored.
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

  var notificationsEnabled = true;
  final prefsRaw = root['preferences'];
  if (prefsRaw is Map) {
    final prefs = prefsRaw.cast<String, dynamic>();
    final n = prefs[SettingsPrefsKeys.notificationsEnabled];
    if (n is bool) notificationsEnabled = n;
  }

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
    notificationsEnabled: notificationsEnabled,
  );
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
