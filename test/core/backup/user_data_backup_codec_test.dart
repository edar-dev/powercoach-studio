import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/backup/user_data_backup_codec.dart';
import 'package:powercoach_studio/core/constants/workout_plan_template_scope.dart';

void main() {
  const uid = 'user-111';

  Map<String, dynamic> minimalEnvelope({
    String? accountUserId,
    int schemaVersion = kUserBackupSchemaVersion,
    String? exportFormat,
    List<Map<String, dynamic>>? entities,
    Object? extraTopLevel,
  }) {
    return <String, dynamic>{
      'schemaVersion': schemaVersion,
      'exportFormat': exportFormat ?? kUserBackupExportFormat,
      'accountUserId': accountUserId ?? uid,
      'entities': entities ?? <Map<String, dynamic>>[],
      'pendingOperations': <Map<String, dynamic>>[],
      'syncMeta': <Map<String, dynamic>>[],
      if (extraTopLevel != null) 'futureProof': extraTopLevel,
    };
  }

  test('parse accepts minimal envelope and ignores unknown top-level keys', () {
    final jsonText = jsonEncode(
      minimalEnvelope(extraTopLevel: <String, dynamic>{'x': 1}),
    );
    final parsed = parseUserBackupJson(jsonText, uid);
    expect(parsed.entities, isEmpty);
    expect(parsed.pendingOperations, isEmpty);
    expect(parsed.syncMeta, isEmpty);
    expect(parsed.notificationsEnabled, isTrue);
    expect(parsed.reminders, isEmpty);
  });

  test('parse rejects wrong account', () {
    final jsonText = jsonEncode(minimalEnvelope(accountUserId: 'other'));
    expect(
      () => parseUserBackupJson(jsonText, uid),
      throwsA(isA<UserBackupImportException>()),
    );
  });

  test('parse rejects unsupported schema', () {
    final jsonText = jsonEncode(minimalEnvelope(schemaVersion: 99));
    expect(
      () => parseUserBackupJson(jsonText, uid),
      throwsA(isA<UserBackupImportException>()),
    );
  });

  test('parse rejects wrong exportFormat', () {
    final jsonText = jsonEncode(
      minimalEnvelope(exportFormat: 'something_else'),
    );
    expect(
      () => parseUserBackupJson(jsonText, uid),
      throwsA(isA<UserBackupImportException>()),
    );
  });

  test('parse keeps workout plan payload with template sentinel customerId', () {
    final jsonText = jsonEncode(
      minimalEnvelope(
        entities: <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'plan-template-1',
            'customerId': kWorkoutPlanTemplateScopeId,
            'name': 'Upper/Lower',
            'planData': '{}',
          },
        ],
      ),
    );
    final parsed = parseUserBackupJson(jsonText, uid);
    expect(parsed.entities, hasLength(1));
    expect(parsed.entities.single['customerId'], kWorkoutPlanTemplateScopeId);
  });

  test('parse applies notifications preference when present', () {
    final jsonText = jsonEncode({
      ...minimalEnvelope(),
      'preferences': <String, dynamic>{
        'settings_notifications_enabled': false,
      },
    });
    final parsed = parseUserBackupJson(jsonText, uid);
    expect(parsed.notificationsEnabled, isFalse);
  });

  test('parse keeps optional reminders list', () {
    final jsonText = jsonEncode({
      ...minimalEnvelope(),
      'reminders': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'r1',
          'title': 'T',
          'body': 'B',
          'scheduledAtUtc': DateTime.utc(2030, 1, 2, 12).toIso8601String(),
          'customerId': 'c1',
        },
      ],
    });
    final parsed = parseUserBackupJson(jsonText, uid);
    expect(parsed.reminders.length, 1);
    expect(parsed.reminders.single['id'], 'r1');
  });

  test('parse keeps sync meta rows with metaKey', () {
    final jsonText = jsonEncode({
      ...minimalEnvelope(),
      'syncMeta': <Map<String, dynamic>>[
        <String, dynamic>{'metaKey': 'k1', 'metaValue': 'v1'},
        <String, dynamic>{'metaKey': '', 'metaValue': 'skip'},
      ],
    });
    final parsed = parseUserBackupJson(jsonText, uid);
    expect(parsed.syncMeta.length, 1);
    expect(parsed.syncMeta.single['metaKey'], 'k1');
  });
}
