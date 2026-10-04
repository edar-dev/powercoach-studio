import 'dart:convert';

/// Builds OpenMetadata 1.5.15 [TableData] sample rows from fixtures + registry.
///
/// Pure / no network. Used by dry-run payload and live
/// `PUT /api/v1/tables/{id}/sampleData`.
///
/// OM 1.5.15 `tableData`: columns are local names; rows match column order.

/// OM TableData body for `PUT /api/v1/tables/{id}/sampleData`.
Map<String, dynamic> buildOmTableData({
  required List<String> columns,
  required List<List<Object?>> rows,
}) {
  return <String, dynamic>{
    'columns': List<String>.from(columns),
    'rows': rows
        .map((row) => row.map(_stringifyCell).toList(growable: false))
        .toList(growable: false),
  };
}

String _stringifyCell(Object? value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is num || value is bool) return value.toString();
  return value.toString();
}

/// Group sample offline-style entities and synthetic prefs into per-table
/// TableData maps keyed by catalog id (OM table name).
///
/// Every registry table gets at least one anonymized sample row so the OM UI
/// Sample Data tab is populated for the spike.
Map<String, Map<String, dynamic>> buildSampleDataByTable({
  required Map<String, dynamic> registry,
  required Map<String, dynamic> sampleEntities,
}) {
  final entries = (registry['entries'] as List<dynamic>? ?? const [])
      .cast<Map<String, dynamic>>();
  final entities = (sampleEntities['entities'] as List<dynamic>? ?? const [])
      .cast<Map<String, dynamic>>();
  final preferences =
      (sampleEntities['preferences'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{};
  final localProfile =
      (sampleEntities['localUserProfile'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{};
  final pdfBrand =
      (sampleEntities['pdfBrand'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{};

  final byType = <String, List<Map<String, dynamic>>>{};
  for (final entity in entities) {
    final type = entity['type']?.toString() ?? '';
    if (type.isEmpty) continue;
    byType.putIfAbsent(type, () => <Map<String, dynamic>>[]).add(entity);
  }

  final out = <String, Map<String, dynamic>>{};
  for (final entry in entries) {
    final catalogId = entry['catalogId']?.toString() ?? '';
    if (catalogId.isEmpty) continue;
    final fields = (entry['payloadFields'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList(growable: false);
    if (fields.isEmpty) continue;

    final rows = <List<Object?>>[];
    switch (catalogId) {
      case 'planData':
        rows.addAll(_planDataRows(byType['workoutPlan'] ?? const [], fields));
      case 'userProfile':
        rows.add(_prefsRow(fields, {
          ..._syntheticUserProfile(),
          ...localProfile,
        }));
      case 'pdfBrand':
        rows.add(_prefsRow(fields, {
          ..._syntheticPdfBrand(),
          ...pdfBrand,
        }));
      case 'userPreferences':
        rows.add(_prefsRow(fields, {
          ..._syntheticUserPreferences(),
          ...preferences,
        }));
      case 'workoutDraft':
        rows.add(_prefsRow(fields, _syntheticWorkoutDraft()));
      case 'cloudBackupMeta':
        rows.add(_prefsRow(fields, _syntheticCloudBackupMeta()));
      default:
        final typed = byType[catalogId] ?? const <Map<String, dynamic>>[];
        if (typed.isEmpty) {
          rows.add(_syntheticCoachEntityRow(catalogId, fields));
        } else {
          for (final entity in typed) {
            rows.add(_entityRow(fields, entity));
          }
        }
    }

    final capped = rows.length > 25 ? rows.sublist(0, 25) : rows;
    out[catalogId] = buildOmTableData(columns: fields, rows: capped);
  }
  return out;
}

List<Object?> _entityRow(
  List<String> fields,
  Map<String, dynamic> entity,
) {
  final payload =
      (entity['payload'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{};
  return fields.map((f) {
    if (payload.containsKey(f)) return payload[f];
    if (f == 'id') return entity['id'];
    return null;
  }).toList(growable: false);
}

List<Object?> _prefsRow(
  List<String> fields,
  Map<String, dynamic> values,
) {
  return fields.map((f) => values[f]).toList(growable: false);
}

List<List<Object?>> _planDataRows(
  List<Map<String, dynamic>> plans,
  List<String> fields,
) {
  final rows = <List<Object?>>[];
  for (final plan in plans) {
    final payload =
        (plan['payload'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};
    final raw = payload['planData']?.toString() ?? '';
    Map<String, dynamic> decoded = const <String, dynamic>{};
    if (raw.trim().isNotEmpty) {
      try {
        final parsed = jsonDecode(raw);
        if (parsed is Map) {
          decoded = parsed.cast<String, dynamic>();
        }
      } catch (_) {
        decoded = <String, dynamic>{'name': 'unparseable'};
      }
    }
    final values = <String, dynamic>{
      'name': decoded['name'] ?? payload['name'] ?? plan['id'],
      'mobilitySections': _jsonOrEmpty(decoded['mobilitySections']),
      'mobilityItems': _jsonOrEmpty(decoded['mobilityItems']),
      'phases': _jsonOrEmpty(decoded['phases']),
      'weeks': _jsonOrEmpty(decoded['weeks']),
      'includesMobilityTab':
          decoded['includesMobilityTab']?.toString() ?? 'false',
      'sessionCompletionByKey':
          _jsonOrEmpty(decoded['sessionCompletionByKey']),
      'sessionSkippedByKey': _jsonOrEmpty(decoded['sessionSkippedByKey']),
      'sessionOverrides': _jsonOrEmpty(decoded['sessionOverrides']),
      'sessionExecutions': _jsonOrEmpty(decoded['sessionExecutions']),
    };
    rows.add(fields.map((f) => values[f]).toList(growable: false));
  }
  if (rows.isEmpty) {
    rows.add(
      fields
          .map(
            (f) => f == 'name'
                ? 'Demo planData'
                : f == 'weeks'
                    ? '[{"name":"W1","days":[]}]'
                    : f == 'includesMobilityTab'
                        ? 'false'
                        : '',
          )
          .toList(growable: false),
    );
  }
  return rows;
}

String _jsonOrEmpty(Object? value) {
  if (value == null) return '';
  if (value is String) return value;
  return jsonEncode(value);
}

List<Object?> _syntheticCoachEntityRow(
  String catalogId,
  List<String> fields,
) {
  final base = <String, dynamic>{
    'id': '${catalogId}_sample_1',
    'userId': 'coach_demo_1',
    'name': 'Synthetic $catalogId',
  };
  return fields.map((f) => base[f]).toList(growable: false);
}

Map<String, dynamic> _syntheticUserProfile() => <String, dynamic>{
      'displayName': 'Demo Coach',
      'phone': '+39 000 0000000',
      'bio': 'Anonymized coach profile for OM sample data',
      'avatarUrl': '',
      'website': 'https://example.local',
      'subscriptionPlan': 'local_spike',
    };

Map<String, dynamic> _syntheticPdfBrand() => <String, dynamic>{
      'studioName': 'Demo Studio',
      'accentColorArgb': 'FF0D59F2',
      'disclaimer': 'Sample disclaimer',
      'hidePowerCoachBranding': 'false',
      'logoRelativePath': '',
    };

Map<String, dynamic> _syntheticUserPreferences() => <String, dynamic>{
      'settings_notifications_enabled': 'true',
      'app_locale_code': 'it',
      'settings_calendar_reminders_enabled': 'false',
      'settings_calendar_reminder_lead_hours': '2',
      'workout_builder_compact_add_v1': 'false',
      'workout_builder_include_mobility_default_v1': 'true',
      'pinned_exercise_ids_json_v1': <String>['ex_root'],
      'recent_exercise_ids_json_v1': <String>['ex_root'],
    };

Map<String, dynamic> _syntheticWorkoutDraft() => <String, dynamic>{
      'workout_routine_draft':
          '{"name":"Draft demo","weeks":[{"name":"W1","days":[]}]}',
    };

Map<String, dynamic> _syntheticCloudBackupMeta() => <String, dynamic>{
      'auto_cloud_snapshot_*': 'disabled_local_spike',
      'last_cloud_sync_at_v1_\$userId': '2026-01-15T10:00:00.000Z',
      'backup_last_successful_at_v1_\$userId': '2026-01-15T10:00:00.000Z',
    };
