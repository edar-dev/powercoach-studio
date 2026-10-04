import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/data_quality/data_quality.dart';

import '../../tool/openmetadata/ingestion/om_dq_bridge.dart';

void main() {
  test('DQ bridge payload builds definition, suite, cases, badges', () {
    final sample = jsonDecode(
      File('tool/openmetadata/fixtures/sample_entities.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    const scanner = DataQualityScanner();
    final report = scanner.scanBackupJson(<String, dynamic>{
      'entities': sample['entities'],
      'preferences': sample['preferences'],
    });

    final payload = buildOmDqBridgePayload(
      report: report,
      tableNames: const <String>[
        'customer',
        'workoutPlan',
        'measurement',
        'customExercise',
        'customerNote',
        'userPreferences',
      ],
    );

    expect(payload['exportFormat'], 'powercoach_om_dq_bridge_v1');
    expect(
      (payload['testDefinition'] as Map)['name'],
      kOmDartDqTestDefinitionName,
    );
    expect((payload['testSuite'] as Map)['name'], kOmDartDqTestSuiteName);

    final execSuites =
        (payload['executableTestSuites'] as List).cast<Map<String, dynamic>>();
    expect(execSuites.length, 6);
    expect(
      execSuites.every((s) => s['executableEntityReference'] != null),
      isTrue,
    );
    expect(
      execSuites.firstWhere((s) => s['name'] == 'customer.testSuite')
          ['executableEntityReference'],
      'powercoach_cloud.powercoach_studio.cloud_sot.customer',
    );

    final cases = (payload['testCases'] as List).cast<Map<String, dynamic>>();
    expect(cases.length, greaterThanOrEqualTo(6));
    expect(
      cases.every((c) => c['testDefinition'] == kOmDartDqTestDefinitionName),
      isTrue,
    );
    expect(
      cases.every((c) => (c['entityLink'] as String).startsWith('<#E::table::')),
      isTrue,
    );
    expect(
      cases.every(
        (c) => (c['testSuite'] as String).endsWith('.testSuite'),
      ),
      isTrue,
    );
    expect(
      cases.every((c) => (c['_tableFqn'] as String).contains('.')),
      isTrue,
    );

    final result = cases.first['_result'] as Map<String, dynamic>;
    expect(result['testCaseStatus'], isIn(<String>['Success', 'Failed']));
    expect(result['timestamp'], isA<int>());

    final badges = payload['descriptionBadges'] as Map<String, dynamic>;
    expect(badges['customer'], contains('Dart DQ bridge'));
  });

  test('executable suite body matches OM 1.5.15 create shape', () {
    final body = buildOmDartDqExecutableTestSuiteBody(
      tableName: 'customer',
      tableFqn: 'powercoach_cloud.powercoach_studio.cloud_sot.customer',
    );
    expect(body['name'], 'customer.testSuite');
    expect(body['executableEntityReference'],
        'powercoach_cloud.powercoach_studio.cloud_sot.customer');
    expect(omDartDqExecutableSuiteName('workoutPlan'), 'workoutPlan.testSuite');
  });

  test('failed findings map to Failed testCaseStatus', () {
    final report = DataQualityReport(
      findings: const <DataQualityFinding>[
        DataQualityFinding(
          ruleId: DataQualityRuleIds.orphanReference,
          severity: DataQualitySeverity.error,
          entityType: null,
          entityId: 'plan_x',
          message: 'orphan',
          details: <String, dynamic>{'type': 'workoutPlan'},
        ),
      ],
      scannedEntityCount: 1,
      generatedAt: DateTime.utc(2026, 1, 1),
    );

    final cases = buildOmDartDqTestCaseBodies(
      report: report,
      tableNames: const <String>['workoutPlan', 'customer'],
    );
    final planCase = cases.firstWhere((c) => c['_table'] == 'workoutPlan');
    final result = planCase['_result'] as Map<String, dynamic>;
    expect(result['testCaseStatus'], 'Failed');
    expect(result['testResultValue'], isA<List>());
  });

  test('description badge strips cleanly on re-run marker', () {
    final badge = buildOmDqDescriptionBadge(
      table: 'customer',
      findings: const <DataQualityFinding>[],
      generatedAt: DateTime.utc(2026, 1, 1),
    );
    expect(badge, contains('**Dart DQ bridge**'));
    expect(badge, contains('PASS'));
  });
}
