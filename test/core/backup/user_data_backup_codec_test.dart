import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/backup/user_data_backup_codec.dart';
import 'package:powercoach_studio/core/constants/workout_plan_template_scope.dart';
import 'package:powercoach_studio/core/sync/offline_models.dart';

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
      throwsA(
        isA<UserBackupImportException>().having(
          (e) => e.message,
          'message',
          'wrong_account',
        ),
      ),
    );
  });

  test('parse rejects unsupported schema', () {
    final jsonText = jsonEncode(minimalEnvelope(schemaVersion: 99));
    expect(
      () => parseUserBackupJson(jsonText, uid),
      throwsA(
        isA<UserBackupImportException>().having(
          (e) => e.message,
          'message',
          'unsupported_schema',
        ),
      ),
    );
  });

  test('parse rejects missing schemaVersion as unsupported_schema', () {
    final envelope = minimalEnvelope()..remove('schemaVersion');
    final jsonText = jsonEncode(envelope);
    expect(
      () => parseUserBackupJson(jsonText, uid),
      throwsA(
        isA<UserBackupImportException>().having(
          (e) => e.message,
          'message',
          'unsupported_schema',
        ),
      ),
    );
  });

  test('truncated or invalid JSON string throws FormatException (codec does not wrap)', () {
    // jsonDecode throws FormatException; parseUserBackupJson does not catch it.
    expect(
      () => parseUserBackupJson('{not-valid-json', uid),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => parseUserBackupJson('{"schemaVersion":', uid),
      throwsA(isA<FormatException>()),
    );
  });

  test('parse rejects JSON array root as invalid_root', () {
    expect(
      () => parseUserBackupJson('[]', uid),
      throwsA(
        isA<UserBackupImportException>().having(
          (e) => e.message,
          'message',
          'invalid_root',
        ),
      ),
    );
  });

  test('parse rejects entities that are not a list', () {
    for (final entities in <Object>['not-a-list', <String, dynamic>{'a': 1}]) {
      final jsonText = jsonEncode(<String, dynamic>{
        'schemaVersion': kUserBackupSchemaVersion,
        'exportFormat': kUserBackupExportFormat,
        'accountUserId': uid,
        'entities': entities,
      });
      expect(
        () => parseUserBackupJson(jsonText, uid),
        throwsA(
          isA<UserBackupImportException>().having(
            (e) => e.message,
            'message',
            'entities_not_list',
          ),
        ),
        reason: 'entities=$entities',
      );
    }
  });

  test('parse rejects entity missing id', () {
    final jsonText = jsonEncode(
      minimalEnvelope(
        entities: <Map<String, dynamic>>[
          <String, dynamic>{
            'type': OfflineEntityType.customer.name,
            'scopeId': 'c1',
            'payload': <String, dynamic>{'name': 'No id'},
            'updatedAt': DateTime.utc(2026, 1, 1).toIso8601String(),
            'deleted': false,
            'localOnly': false,
          },
        ],
      ),
    );
    expect(
      () => parseUserBackupJson(jsonText, uid),
      throwsA(
        isA<UserBackupImportException>().having(
          (e) => e.message,
          'message',
          'entity_missing_id',
        ),
      ),
    );
  });

  test('parse keeps unknown preference keys in preferences.raw (forward-compat)', () {
    final jsonText = jsonEncode({
      ...minimalEnvelope(),
      'preferences': <String, dynamic>{
        'settings_notifications_enabled': true,
        'future_pref_key_v9': 'keep-me',
        'another_unknown': 42,
      },
    });
    final parsed = parseUserBackupJson(jsonText, uid);
    expect(parsed.preferences.raw['future_pref_key_v9'], 'keep-me');
    expect(parsed.preferences.raw['another_unknown'], 42);
  });

  test('parse preserves reminder extra fields; non-list reminders yield empty list', () {
    final withExtras = jsonEncode({
      ...minimalEnvelope(),
      'reminders': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'r1',
          'title': 'T',
          'body': 'B',
          'scheduledAtUtc': DateTime.utc(2030, 1, 2, 12).toIso8601String(),
          'customerId': 'c1',
          'extraFutureField': true,
        },
      ],
    });
    final parsedExtras = parseUserBackupJson(withExtras, uid);
    expect(parsedExtras.reminders, hasLength(1));
    expect(parsedExtras.reminders.single['extraFutureField'], isTrue);

    // Codec tolerates wrong reminders shapes (returns []) rather than throwing.
    final nonList = jsonEncode({
      ...minimalEnvelope(),
      'reminders': <String, dynamic>{'not': 'a-list'},
    });
    expect(parseUserBackupJson(nonList, uid).reminders, isEmpty);
  });

  test('parse rejects wrong exportFormat', () {
    final jsonText = jsonEncode(
      minimalEnvelope(exportFormat: 'something_else'),
    );
    expect(
      () => parseUserBackupJson(jsonText, uid),
      throwsA(
        isA<UserBackupImportException>().having(
          (e) => e.message,
          'message',
          'wrong_format',
        ),
      ),
    );
  });

  test('parse drops workout plan with template sentinel customerId', () {
    final jsonText = jsonEncode(
      minimalEnvelope(
        entities: <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'plan-template-1',
            'customerId': kWorkoutPlanTemplateScopeId,
            'name': 'Upper/Lower',
            'planData': '{}',
          },
          <String, dynamic>{
            'id': 'plan-customer-1',
            'type': OfflineEntityType.workoutPlan.name,
            'scopeId': 'cust-1',
            'payload': <String, dynamic>{
              'id': 'plan-customer-1',
              'customerId': 'cust-1',
              'name': 'Client plan',
              'planData': '{}',
            },
            'updatedAt': DateTime.utc(2026, 1, 1).toIso8601String(),
            'deleted': false,
            'localOnly': false,
          },
        ],
      ),
    );
    final parsed = parseUserBackupJson(jsonText, uid);
    expect(parsed.entities, hasLength(1));
    expect(parsed.entities.single['id'], 'plan-customer-1');
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

  test('parse applies extended preference keys when present', () {
    final jsonText = jsonEncode({
      ...minimalEnvelope(),
      'preferences': <String, dynamic>{
        'settings_notifications_enabled': true,
        'app_locale_code': 'en',
        'settings_calendar_reminders_enabled': true,
        'settings_calendar_reminder_lead_hours': 12,
        'workout_builder_compact_add_v1': false,
        'workout_builder_include_mobility_default_v1': false,
      },
    });
    final parsed = parseUserBackupJson(jsonText, uid);
    expect(parsed.preferences.localeCode, 'en');
    expect(parsed.preferences.calendarRemindersEnabled, isTrue);
    expect(parsed.preferences.calendarReminderLeadHours, 12);
    expect(parsed.preferences.hasWorkoutBuilderCompactAdd, isTrue);
    expect(parsed.preferences.workoutBuilderCompactAdd, isFalse);
    expect(parsed.preferences.workoutBuilderIncludeMobilityDefault, isFalse);
  });

  test('parse tolerates legacy pendingOperations and syncMeta without requiring them', () {
    final withLegacy = jsonEncode(minimalEnvelope());
    final withoutLegacy = jsonEncode(<String, dynamic>{
      'schemaVersion': kUserBackupSchemaVersion,
      'exportFormat': kUserBackupExportFormat,
      'accountUserId': uid,
      'entities': <Map<String, dynamic>>[],
    });
    expect(parseUserBackupJson(withLegacy, uid).pendingOperations, isEmpty);
    expect(parseUserBackupJson(withoutLegacy, uid).syncMeta, isEmpty);
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

  test('parse keeps customerNote entities in envelope', () {
    final jsonText = jsonEncode(
      minimalEnvelope(
        entities: <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'note-1',
            'type': 'customerNote',
            'scopeId': 'c1',
            'payload': <String, dynamic>{
              'id': 'note-1',
              'customerId': 'c1',
              'authorUserId': uid,
              'body': 'Follow-up next week',
              'createdAt': DateTime.utc(2026, 5, 1, 10).toIso8601String(),
            },
            'updatedAt': DateTime.utc(2026, 5, 1, 10).toIso8601String(),
            'deleted': false,
            'localOnly': false,
          },
        ],
      ),
    );
    final parsed = parseUserBackupJson(jsonText, uid);
    expect(parsed.entities, hasLength(1));
    expect(parsed.entities.single['type'], 'customerNote');
    expect(parsed.entities.single['scopeId'], 'c1');
  });

  test('previewCountsFromBackup counts session executions in planData', () {
    final jsonText = jsonEncode(
      minimalEnvelope(
        entities: <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'c1',
            'type': 'customer',
            'scopeId': 'c1',
            'payload': <String, dynamic>{'id': 'c1', 'name': 'Marco'},
            'updatedAt': DateTime.utc(2026, 6, 1).toIso8601String(),
            'deleted': false,
            'localOnly': false,
          },
          <String, dynamic>{
            'id': 'p1',
            'type': 'workoutPlan',
            'scopeId': 'c1',
            'payload': <String, dynamic>{
              'id': 'p1',
              'customerId': 'c1',
              'planData': jsonEncode({
                'name': 'Plan',
                'mobilitySections': [],
                'mobilityItems': [],
                'weeks': [],
                'sessionExecutions': {
                  '0-0': {'sessionKey': '0-0', 'weekIndex': 0, 'dayIndex': 0},
                  '0-1': {'sessionKey': '0-1', 'weekIndex': 0, 'dayIndex': 1},
                },
              }),
            },
            'updatedAt': DateTime.utc(2026, 6, 1).toIso8601String(),
            'deleted': false,
            'localOnly': false,
          },
        ],
      ),
    );
    final parsed = parseUserBackupJson(jsonText, uid);
    final counts = previewCountsFromBackup(parsed);
    expect(counts.customers, 1);
    expect(counts.plans, 1);
    expect(counts.executions, 2);
    expect(counts.exerciseLibrary, 0);
  });

  test('parse keeps optional export metadata', () {
    final jsonText = jsonEncode({
      ...minimalEnvelope(),
      'exportedAt': DateTime.utc(2026, 7, 8, 12).toIso8601String(),
      'appVersion': '1.0.7',
      'entityCounts': <String, dynamic>{
        'customers': 2,
        'workoutPlans': 1,
      },
    });
    final parsed = parseUserBackupJson(jsonText, uid);
    expect(parsed.exportedAt, isNotNull);
    expect(parsed.appVersion, '1.0.7');
    expect(parsed.entityCounts?['customers'], 2);
  });

  test('isKnownOfflineEntityTypeName rejects legacy exerciseRecord', () {
    expect(isKnownOfflineEntityTypeName('customer'), isTrue);
    expect(isKnownOfflineEntityTypeName('customExercise'), isTrue);
    expect(isKnownOfflineEntityTypeName('exerciseRecord'), isFalse);
  });

  test('entityCountsFromBackupEntities counts library and customer records', () {
    final counts = entityCountsFromBackupEntities(
      <Map<String, dynamic>>[
        <String, dynamic>{'id': 'c1', 'type': 'customer'},
        <String, dynamic>{'id': 'n1', 'type': 'customerNote'},
        <String, dynamic>{'id': 'x1', 'type': 'customExercise'},
        <String, dynamic>{'id': 'legacy', 'type': 'exerciseRecord'},
      ],
      reminders: 2,
    );
    expect(counts.customers, 1);
    expect(counts.customerRecords, 1);
    expect(counts.customersGroupTotal, 2);
    expect(counts.exerciseLibrary, 1);
    expect(counts.reminders, 2);
  });
}
