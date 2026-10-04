import 'package:powercoach_studio/core/data_quality/data_quality.dart';

/// Pure builders that map [DataQualityReport] → OpenMetadata 1.5.15 DQ API
/// payloads (custom test definition / logical suite / cases / results) plus
/// table description badges.
///
/// In-app Salute dati remains the product DQ source of truth; OM is a
/// local viewer/bridge only.

const String kOmDartDqTestDefinitionName = 'powercoachDartScanner';
const String kOmDartDqTestSuiteName = 'powercoach_dart_dq';

/// Schema FQN used when building entity links / executable suite names.
String omCloudSotSchemaFqn({
  String service = 'powercoach_cloud',
  String database = 'powercoach_studio',
  String schema = 'cloud_sot',
}) =>
    '$service.$database.$schema';

/// Custom test definition body for POST `/api/v1/dataQuality/testDefinitions`.
Map<String, dynamic> buildOmDartDqTestDefinitionBody() => <String, dynamic>{
      'name': kOmDartDqTestDefinitionName,
      'displayName': 'PowerCoach Dart DataQualityScanner',
      'description':
          'Bridge from in-repo `DataQualityScanner` (Salute dati). '
          'Results are published by local tooling; OM does not execute SQL.',
      'entityType': 'TABLE',
      'testPlatforms': <String>['OpenMetadata'],
      'parameterDefinition': <Map<String, dynamic>>[
        <String, dynamic>{
          'name': 'ruleId',
          'dataType': 'STRING',
          'required': false,
          'description': 'Stable DataQualityRuleIds value, or summary',
        },
      ],
    };

/// Logical (non-executable) test suite for the Dart bridge.
Map<String, dynamic> buildOmDartDqTestSuiteBody() => <String, dynamic>{
      'name': kOmDartDqTestSuiteName,
      'displayName': 'PowerCoach Dart DQ (local bridge)',
      'description':
          'Aggregates `DataQualityScanner` findings for the local OM spike. '
          'Refresh via `ingest.sh --live --with-dq` or `scripts/dq_to_om.sh`.',
    };

/// Aggregate findings by catalog table name (entityType name or `unknown`).
Map<String, List<DataQualityFinding>> groupFindingsByCatalogTable(
  DataQualityReport report,
) {
  final out = <String, List<DataQualityFinding>>{};
  for (final f in report.findings) {
    final key = f.entityType?.name ??
        f.details?['type']?.toString() ??
        'unknown';
    out.putIfAbsent(key, () => <DataQualityFinding>[]).add(f);
  }
  return out;
}

/// One summary test case per table that has findings (or a clean pass case).
///
/// [tableNames] should be the full set of OM tables to ensure a green
/// summary case exists even when the scanner found nothing for that table.
List<Map<String, dynamic>> buildOmDartDqTestCaseBodies({
  required DataQualityReport report,
  required Iterable<String> tableNames,
  String schemaFqn = '',
}) {
  final fqn = schemaFqn.isEmpty ? omCloudSotSchemaFqn() : schemaFqn;
  final byTable = groupFindingsByCatalogTable(report);
  final cases = <Map<String, dynamic>>[];

  for (final table in tableNames) {
    final findings = byTable[table] ?? const <DataQualityFinding>[];
    final errorCount =
        findings.where((f) => f.severity == DataQualitySeverity.error).length;
    final warningCount =
        findings.where((f) => f.severity == DataQualitySeverity.warning).length;
    cases.add(<String, dynamic>{
      'name': 'dart_dq_$table',
      'displayName': 'Dart DQ · $table',
      'description': _caseDescription(
        table: table,
        findings: findings,
        errorCount: errorCount,
        warningCount: warningCount,
      ),
      'testDefinition': kOmDartDqTestDefinitionName,
      'entityLink': '<#E::table::$fqn.$table>',
      'testSuite': kOmDartDqTestSuiteName,
      'parameterValues': <Map<String, dynamic>>[
        <String, dynamic>{
          'name': 'ruleId',
          'value': findings.isEmpty ? 'summary_clean' : 'summary',
        },
      ],
      // Carried for live result push (not sent on create).
      '_result': buildOmDartDqTestCaseResultBody(
        findings: findings,
        scannedEntityCount: report.scannedEntityCount,
        generatedAt: report.generatedAt,
      ),
      '_table': table,
    });
  }

  // Orphan / unknown-type findings that do not map to a known table.
  for (final entry in byTable.entries) {
    if (tableNames.contains(entry.key)) continue;
    final findings = entry.value;
    cases.add(<String, dynamic>{
      'name': 'dart_dq_unmapped_${entry.key}',
      'displayName': 'Dart DQ · unmapped (${entry.key})',
      'description':
          'Findings without a matching OM catalog table (`${entry.key}`).',
      'testDefinition': kOmDartDqTestDefinitionName,
      // Attach to customer as a stable anchor table for visibility.
      'entityLink': '<#E::table::$fqn.customer>',
      'testSuite': kOmDartDqTestSuiteName,
      'parameterValues': <Map<String, dynamic>>[
        <String, dynamic>{'name': 'ruleId', 'value': 'unmapped_${entry.key}'},
      ],
      '_result': buildOmDartDqTestCaseResultBody(
        findings: findings,
        scannedEntityCount: report.scannedEntityCount,
        generatedAt: report.generatedAt,
      ),
      '_table': 'customer',
    });
  }

  return cases;
}

Map<String, dynamic> buildOmDartDqTestCaseResultBody({
  required List<DataQualityFinding> findings,
  required int scannedEntityCount,
  required DateTime generatedAt,
}) {
  final errors =
      findings.where((f) => f.severity == DataQualitySeverity.error).length;
  final warnings =
      findings.where((f) => f.severity == DataQualitySeverity.warning).length;
  final infos =
      findings.where((f) => f.severity == DataQualitySeverity.info).length;

  final status = errors > 0
      ? 'Failed'
      : warnings > 0
          ? 'Failed'
          : 'Success';

  final summary = findings.isEmpty
      ? 'No Dart DQ findings (scanned=$scannedEntityCount).'
      : 'Dart DQ: errors=$errors warnings=$warnings info=$infos '
          '(scanned=$scannedEntityCount). '
          'Top: ${findings.take(3).map((f) => f.ruleId).join(', ')}';

  return <String, dynamic>{
    'timestamp': generatedAt.toUtc().millisecondsSinceEpoch,
    'testCaseStatus': status,
    'result': summary,
    'testResultValue': <Map<String, dynamic>>[
      <String, dynamic>{'name': 'errorCount', 'value': '$errors'},
      <String, dynamic>{'name': 'warningCount', 'value': '$warnings'},
      <String, dynamic>{'name': 'infoCount', 'value': '$infos'},
      <String, dynamic>{
        'name': 'findingCount',
        'value': '${findings.length}',
      },
      <String, dynamic>{
        'name': 'scannedEntityCount',
        'value': '$scannedEntityCount',
      },
    ],
  };
}

/// Markdown badge appended / used when PATCHing table descriptions.
String buildOmDqDescriptionBadge({
  required String table,
  required List<DataQualityFinding> findings,
  required DateTime generatedAt,
}) {
  final errors =
      findings.where((f) => f.severity == DataQualitySeverity.error).length;
  final warnings =
      findings.where((f) => f.severity == DataQualitySeverity.warning).length;
  final status = errors > 0
      ? 'FAIL'
      : warnings > 0
          ? 'WARN'
          : 'PASS';
  final buf = StringBuffer()
    ..writeln()
    ..writeln('---')
    ..writeln(
      '**Dart DQ bridge** · `$status` · errors=$errors warnings=$warnings · '
      'scanned@`${generatedAt.toUtc().toIso8601String()}` · table=`$table`',
    );
  if (findings.isNotEmpty) {
    buf.writeln();
    for (final f in findings.take(5)) {
      buf.writeln(
        '- `${f.severity.name}` `${f.ruleId}`'
        '${f.entityId == null ? '' : ' `${f.entityId}`'}: '
        '${f.message}',
      );
    }
    if (findings.length > 5) {
      buf.writeln('- _…${findings.length - 5} more (see Test Cases)_');
    }
  }
  buf.writeln();
  buf.writeln(
    '_Source: in-repo `DataQualityScanner` / Salute dati. OM is viewer only._',
  );
  return buf.toString();
}

/// Dry-run friendly payload summarizing the bridge (no network).
Map<String, dynamic> buildOmDqBridgePayload({
  required DataQualityReport report,
  required Iterable<String> tableNames,
  String schemaFqn = '',
}) {
  final byTable = groupFindingsByCatalogTable(report);
  final cases = buildOmDartDqTestCaseBodies(
    report: report,
    tableNames: tableNames,
    schemaFqn: schemaFqn,
  );
  return <String, dynamic>{
    'schemaVersion': 1,
    'exportFormat': 'powercoach_om_dq_bridge_v1',
    'testDefinition': buildOmDartDqTestDefinitionBody(),
    'testSuite': buildOmDartDqTestSuiteBody(),
    'testCases': cases
        .map((c) {
          final copy = Map<String, dynamic>.from(c);
          // Keep _result for inspection in dry-run JSON.
          return copy;
        })
        .toList(growable: false),
    'descriptionBadges': <String, String>{
      for (final table in tableNames)
        table: buildOmDqDescriptionBadge(
          table: table,
          findings: byTable[table] ?? const <DataQualityFinding>[],
          generatedAt: report.generatedAt,
        ),
    },
    'reportSummary': report.toJson(),
  };
}

String _caseDescription({
  required String table,
  required List<DataQualityFinding> findings,
  required int errorCount,
  required int warningCount,
}) {
  if (findings.isEmpty) {
    return 'Dart DataQualityScanner summary for `$table` — no findings.';
  }
  return 'Dart DataQualityScanner summary for `$table` '
      '(errors=$errorCount, warnings=$warningCount, '
      'findings=${findings.length}).';
}
