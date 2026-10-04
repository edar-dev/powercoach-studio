import 'dart:convert';
import 'dart:io';

import 'package:powercoach_studio/core/data_quality/data_quality.dart';

import 'om_catalog_payload.dart';
import 'om_dq_bridge.dart';
import 'om_live_defaults.dart';
import 'om_sample_data.dart';

/// Custom OpenMetadata ingestion for the PowerCoach data catalog spike.
///
/// Reads [tool/openmetadata/fixtures/registry.json] (+ optional sample entities)
/// and either:
/// - dry-run (default): writes an OM-oriented payload JSON for inspection
/// - `--live`: POSTs service / schema / tables / lineage / sample data to OM
/// - `--with-dq`: runs [DataQualityScanner] and publishes bridge results
///   (with `--live`; dry-run writes `fixtures/om_dq_bridge_payload.json`)
///
/// No secrets are required for dry-run. Live mode uses the local OM 1.5.15
/// quickstart defaults (`admin@open-metadata.org` / `admin`) against
/// http://localhost:8585 — never for prod.
///
/// Usage (from repo root):
///   dart run tool/openmetadata/ingestion/ingest_from_registry.dart
///   dart run tool/openmetadata/ingestion/ingest_from_registry.dart --live
///   dart run tool/openmetadata/ingestion/ingest_from_registry.dart --live --with-dq
///   dart run tool/openmetadata/ingestion/ingest_from_registry.dart --with-dq --backup path.json
void main(List<String> args) async {
  final live = args.contains('--live');
  final withDq = args.contains('--with-dq');
  final skipSample = args.contains('--skip-sample-data');
  final backupPath = _argValue(args, '--backup');

  final root = _findRepoRoot();
  final fixturesDir = Directory('${root.path}/tool/openmetadata/fixtures');
  final registryFile = File('${fixturesDir.path}/registry.json');
  final sampleFile = File('${fixturesDir.path}/sample_entities.json');
  final outFile = File('${fixturesDir.path}/om_catalog_payload.json');
  final dqOutFile = File('${fixturesDir.path}/om_dq_bridge_payload.json');

  if (!registryFile.existsSync()) {
    stderr.writeln('Missing ${registryFile.path}. Run:');
    stderr.writeln(
      '  dart run tool/dump_data_catalog.dart --out tool/openmetadata/fixtures/registry.json',
    );
    exitCode = 1;
    return;
  }

  final registry =
      jsonDecode(registryFile.readAsStringSync()) as Map<String, dynamic>;
  final sample = sampleFile.existsSync()
      ? jsonDecode(sampleFile.readAsStringSync()) as Map<String, dynamic>
      : <String, dynamic>{};

  final payload = buildOpenMetadataPayload(
    registry: registry,
    sampleEntities: sample,
  );

  outFile.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(payload)}\n',
  );
  final sampleByTable =
      (payload['sampleDataByTable'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{};
  stdout.writeln('Wrote ${outFile.path}');
  stdout.writeln(
    'tables=${(payload['tables'] as List).length} '
    'lineageEdges=${(payload['lineageEdges'] as List).length} '
    'sampleTables=${sampleByTable.length}',
  );

  DataQualityReport? dqReport;
  Map<String, dynamic>? dqPayload;
  if (withDq) {
    dqReport = _scanForDq(
      sampleEntities: sample,
      backupPath: backupPath,
    );
    final tableNames = (payload['tables'] as List)
        .cast<Map<String, dynamic>>()
        .map((t) => t['name']?.toString() ?? '')
        .where((n) => n.isNotEmpty);
    dqPayload = buildOmDqBridgePayload(
      report: dqReport,
      tableNames: tableNames,
    );
    dqOutFile.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(dqPayload)}\n',
    );
    stdout.writeln(
      'Wrote ${dqOutFile.path} '
      '(findings=${dqReport.findings.length}, '
      'errors=${dqReport.countBySeverity(DataQualitySeverity.error)})',
    );
  }

  if (!live) {
    stdout.writeln(
      'Dry-run only. Pass --live after `docker compose up` to push '
      '(sample data included unless --skip-sample-data).',
    );
    if (withDq) {
      stdout.writeln(
        'DQ bridge dry-run complete. Pass --live --with-dq to publish to OM.',
      );
    }
    return;
  }

  final baseUrl = Platform.environment['OM_BASE_URL'] ?? kOmDefaultBaseUrl;
  final token = await _login(
    baseUrl: baseUrl,
    email: Platform.environment['OM_EMAIL'] ?? kOmDefaultEmail,
    password: Platform.environment['OM_PASSWORD'] ?? kOmDefaultPassword,
  );
  final tableIds = await _ingestLive(
    baseUrl: baseUrl,
    token: token,
    payload: payload,
    pushSampleData: !skipSample,
  );

  if (withDq && dqPayload != null && dqReport != null) {
    await _pushDqBridge(
      baseUrl: baseUrl,
      token: token,
      payload: payload,
      dqPayload: dqPayload,
      tableIdsByName: tableIds,
    );
  }

  stdout.writeln('Live ingestion finished against $baseUrl');
}

String? _argValue(List<String> args, String flag) {
  final i = args.indexOf(flag);
  if (i < 0 || i + 1 >= args.length) return null;
  final next = args[i + 1];
  if (next.startsWith('-')) return null;
  return next;
}

DataQualityReport _scanForDq({
  required Map<String, dynamic> sampleEntities,
  String? backupPath,
}) {
  const scanner = DataQualityScanner();
  if (backupPath != null) {
    final file = File(backupPath);
    if (!file.existsSync()) {
      throw StateError('Backup file not found: $backupPath');
    }
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is! Map) {
      throw StateError('Backup root must be a JSON object');
    }
    return scanner.scanBackupJson(decoded.cast<String, dynamic>());
  }

  // Fixture is already backup-shaped (entities + preferences).
  return scanner.scanBackupJson(<String, dynamic>{
    'entities': sampleEntities['entities'] ?? const <dynamic>[],
    'preferences': sampleEntities['preferences'] ?? const <String, dynamic>{},
    if (sampleEntities['localUserProfile'] != null)
      'localUserProfile': sampleEntities['localUserProfile'],
  });
}

Directory _findRepoRoot() {
  var dir = Directory.current;
  while (true) {
    if (File('${dir.path}/pubspec.yaml').existsSync() &&
        Directory('${dir.path}/tool/openmetadata').existsSync()) {
      return dir;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError('Run from powercoach-studio repo root');
    }
    dir = parent;
  }
}

void _writeOmUtf8Body(HttpClientRequest req, Object body) {
  final bytes = encodeOmUtf8JsonBody(body);
  req.contentLength = bytes.length;
  req.add(bytes);
}

ContentType _omJsonContentType([String? contentType]) {
  if (contentType == null || contentType == 'application/json') {
    return ContentType('application', 'json', charset: 'utf-8');
  }
  if (contentType == 'application/json-patch+json') {
    return ContentType('application', 'json-patch+json', charset: 'utf-8');
  }
  return ContentType.parse(contentType);
}

Future<String> _login({
  required String baseUrl,
  required String email,
  required String password,
}) async {
  final client = HttpClient();
  try {
    final req = await client.postUrl(Uri.parse('$baseUrl/api/v1/users/login'));
    req.headers.contentType = _omJsonContentType();
    _writeOmUtf8Body(
      req,
      <String, dynamic>{
        'email': email,
        'password': encodeOmLoginPassword(password),
      },
    );
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    if (res.statusCode >= 300) {
      throw StateError('OM login failed (${res.statusCode}): $body');
    }
    final decoded = jsonDecode(body);
    if (decoded is Map && decoded['accessToken'] != null) {
      return decoded['accessToken'].toString();
    }
    if (decoded is String) return decoded;
    throw StateError('Unexpected OM login response: $body');
  } finally {
    client.close(force: true);
  }
}

typedef _OmApi = Future<Map<String, dynamic>?> Function(
  String method,
  String path, {
  Object? body,
  String? contentType,
});

Future<Map<String, String>> _ingestLive({
  required String baseUrl,
  required String token,
  required Map<String, dynamic> payload,
  required bool pushSampleData,
}) async {
  final client = HttpClient();
  Future<Map<String, dynamic>?> api(
    String method,
    String path, {
    Object? body,
    String? contentType,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final HttpClientRequest req;
    switch (method) {
      case 'PUT':
        req = await client.putUrl(uri);
      case 'PATCH':
        req = await client.patchUrl(uri);
      case 'GET':
        req = await client.getUrl(uri);
      default:
        req = await client.postUrl(uri);
    }
    req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    req.headers.contentType = _omJsonContentType(contentType);
    if (body != null) {
      _writeOmUtf8Body(req, body);
    }
    final res = await req.close();
    final text = await res.transform(utf8.decoder).join();
    if (res.statusCode >= 300) {
      stderr.writeln('OM $method $path → ${res.statusCode}: $text');
      return null;
    }
    if (text.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(text);
    return decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{'value': decoded};
  }

  try {
    final service = payload['service'] as Map<String, dynamic>;
    final database = payload['database'] as Map<String, dynamic>;
    final schema = payload['schema'] as Map<String, dynamic>;

    await api(
      'POST',
      '/api/v1/services/databaseServices',
      body: <String, dynamic>{
        'name': service['name'],
        'displayName': service['displayName'],
        'serviceType': 'CustomDatabase',
        'description': service['description'],
        'connection': <String, dynamic>{
          'config': <String, dynamic>{
            'type': 'CustomDatabase',
            'sourcePythonClass': 'powercoach_catalog_spike',
          },
        },
      },
    );

    await api(
      'POST',
      '/api/v1/databases',
      body: <String, dynamic>{
        'name': database['name'],
        'displayName': database['name'],
        'description': database['description'],
        'service': service['name'],
      },
    );

    final schemaFqn =
        '${service['name']}.${database['name']}.${schema['name']}';
    await api(
      'POST',
      '/api/v1/databaseSchemas',
      body: <String, dynamic>{
        'name': schema['name'],
        'displayName': schema['name'],
        'description': schema['description'],
        'database': '${service['name']}.${database['name']}',
      },
    );

    final tables = (payload['tables'] as List).cast<Map<String, dynamic>>();
    final tableIdsByName = <String, String>{};
    final tableDescriptions = <String, String>{};
    for (final table in tables) {
      final name = table['name']?.toString() ?? '';
      final fqn = '$schemaFqn.$name';
      final description = table['description']?.toString() ?? '';
      tableDescriptions[name] = description;
      final created = await api(
        'POST',
        '/api/v1/tables',
        body: <String, dynamic>{
          'name': name,
          'displayName': table['displayName'],
          'description': description,
          'tableType': 'Regular',
          'columns': table['columns'],
          'databaseSchema': schemaFqn,
        },
      );
      var id = created?['id']?.toString();
      if (id == null || id.isEmpty) {
        final existing = await api('GET', '/api/v1/tables/name/$fqn');
        id = existing?['id']?.toString();
      }
      if (id == null || id.isEmpty) {
        stderr.writeln('OM: could not resolve table UUID for $fqn');
        continue;
      }
      tableIdsByName[name] = id;
    }

    final edges =
        (payload['lineageEdges'] as List).cast<Map<String, dynamic>>();
    for (final edge in edges) {
      final fromName = edge['fromEntity']?.toString() ?? '';
      final toName = edge['toEntity']?.toString() ?? '';
      final fromId = tableIdsByName[fromName];
      final toId = tableIdsByName[toName];
      if (fromId == null || toId == null) {
        stderr.writeln(
          'OM: skip lineage $fromName → $toName '
          '(missing UUID: from=$fromId to=$toId)',
        );
        continue;
      }
      final description =
          '${edge['fieldPath']}: ${edge['description'] ?? ''}'.trim();
      await api(
        'PUT',
        '/api/v1/lineage',
        body: buildOmLineagePutBody(
          fromId: fromId,
          toId: toId,
          description: description,
        ),
      );
    }

    if (pushSampleData) {
      await _pushSampleData(
        api: api,
        payload: payload,
        tableIdsByName: tableIdsByName,
      );
    }

    // Stash descriptions for DQ badge merge (returned via side channel).
    payload['_tableDescriptions'] = tableDescriptions;
    return tableIdsByName;
  } finally {
    client.close(force: true);
  }
}

Future<void> _pushSampleData({
  required _OmApi api,
  required Map<String, dynamic> payload,
  required Map<String, String> tableIdsByName,
}) async {
  final sampleByTable = (payload['sampleDataByTable'] as Map?)
          ?.cast<String, dynamic>() ??
      buildSampleDataByTable(
        registry: <String, dynamic>{
          'entries': (payload['tables'] as List)
              .cast<Map<String, dynamic>>()
              .map(
                (t) => <String, dynamic>{
                  'catalogId': t['name'],
                  'payloadFields': (t['columns'] as List? ?? const [])
                      .cast<Map<String, dynamic>>()
                      .map((c) => c['name'])
                      .toList(),
                },
              )
              .toList(),
        },
        sampleEntities: <String, dynamic>{
          'entities': payload['sampleEntities'] ?? const <dynamic>[],
        },
      );

  var pushed = 0;
  for (final entry in sampleByTable.entries) {
    final tableId = tableIdsByName[entry.key];
    if (tableId == null) {
      stderr.writeln('OM: skip sampleData for ${entry.key} (no table UUID)');
      continue;
    }
    final tableData = entry.value is Map<String, dynamic>
        ? entry.value as Map<String, dynamic>
        : Map<String, dynamic>.from(entry.value as Map);
    final res = await api(
      'PUT',
      '/api/v1/tables/$tableId/sampleData',
      body: tableData,
    );
    if (res != null) pushed++;
  }
  stdout.writeln('Sample data pushed for $pushed tables');
}

Future<void> _pushDqBridge({
  required String baseUrl,
  required String token,
  required Map<String, dynamic> payload,
  required Map<String, dynamic> dqPayload,
  required Map<String, String> tableIdsByName,
}) async {
  final client = HttpClient();
  Future<Map<String, dynamic>?> api(
    String method,
    String path, {
    Object? body,
    String? contentType,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final HttpClientRequest req;
    switch (method) {
      case 'PUT':
        req = await client.putUrl(uri);
      case 'PATCH':
        req = await client.patchUrl(uri);
      case 'GET':
        req = await client.getUrl(uri);
      default:
        req = await client.postUrl(uri);
    }
    req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    req.headers.contentType = _omJsonContentType(contentType);
    if (body != null) {
      _writeOmUtf8Body(req, body);
    }
    final res = await req.close();
    final text = await res.transform(utf8.decoder).join();
    if (res.statusCode >= 300) {
      stderr.writeln('OM $method $path → ${res.statusCode}: $text');
      return null;
    }
    if (text.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(text);
    return decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{'value': decoded};
  }

  try {
    final defBody = dqPayload['testDefinition'] as Map<String, dynamic>;
    await api('POST', '/api/v1/dataQuality/testDefinitions', body: defBody);
    // Re-run friendly: try GET by name if create failed.
    await api(
      'GET',
      '/api/v1/dataQuality/testDefinitions/name/${defBody['name']}',
    );

    // Logical hub suite (Observability → Data Quality). Cases attach to
    // per-table executable suites below — OM 1.5.15 rejects case create on
    // a logical suite for this custom definition path.
    final suiteBody = dqPayload['testSuite'] as Map<String, dynamic>;
    await api('POST', '/api/v1/dataQuality/testSuites', body: suiteBody);
    await api(
      'GET',
      '/api/v1/dataQuality/testSuites/name/${suiteBody['name']}',
    );

    final service = payload['service'] as Map<String, dynamic>;
    final database = payload['database'] as Map<String, dynamic>;
    final schema = payload['schema'] as Map<String, dynamic>;
    final schemaFqn =
        '${service['name']}.${database['name']}.${schema['name']}';

    final executableSuites =
        (dqPayload['executableTestSuites'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        <Map<String, dynamic>>[
          for (final name in tableIdsByName.keys)
            buildOmDartDqExecutableTestSuiteBody(
              tableName: name,
              tableFqn: '$schemaFqn.$name',
            ),
        ];

    // POST …/executable; on 409 resolve via GET …/name/{shortName}
    // (GET …/executable/name/{fqn} 405/500s on OM 1.5.15).
    for (final execBody in executableSuites) {
      final shortName = execBody['name']?.toString() ?? '';
      var created = await api(
        'POST',
        '/api/v1/dataQuality/testSuites/executable',
        body: execBody,
      );
      created ??= await api(
        'GET',
        '/api/v1/dataQuality/testSuites/name/$shortName',
      );
      if (created == null) {
        stderr.writeln(
          'OM: could not create/resolve executable suite $shortName',
        );
      }
    }

    final cases =
        (dqPayload['testCases'] as List).cast<Map<String, dynamic>>();
    var caseCount = 0;
    var resultCount = 0;
    for (final raw in cases) {
      final table = raw['_table']?.toString() ?? '';
      final tableFqn = raw['_tableFqn']?.toString() ??
          (table.isEmpty ? '' : '$schemaFqn.$table');
      final createBody = Map<String, dynamic>.from(raw)
        ..remove('_result')
        ..remove('_table')
        ..remove('_tableFqn');
      var created = await api(
        'POST',
        '/api/v1/dataQuality/testCases',
        body: createBody,
      );
      // Executable-suite case FQN is `{tableFqn}.{caseName}` (dots unencoded).
      final fallbackFqn = tableFqn.isEmpty
          ? createBody['name']?.toString() ?? ''
          : '$tableFqn.${createBody['name']}';
      created ??= await api(
        'GET',
        '/api/v1/dataQuality/testCases/name/$fallbackFqn',
      );
      created ??= await api(
        'GET',
        '/api/v1/dataQuality/testCases/name/${createBody['name']}',
      );

      // OM 1.5.15 addTestCaseResult is FQN-only:
      // PUT /api/v1/dataQuality/testCases/{fqn}/testCaseResult
      // Keep `.` literal (do not %2E-encode the FQN path segment).
      final fqn = created?['fullyQualifiedName']?.toString() ?? fallbackFqn;
      if (created != null) caseCount++;

      final result = raw['_result'];
      if (result is Map<String, dynamic> && fqn.isNotEmpty) {
        final ok = await api(
          'PUT',
          '/api/v1/dataQuality/testCases/$fqn/testCaseResult',
          body: result,
        );
        if (ok != null) resultCount++;
      }
    }

    // Description badges (JSON Patch) so Sample Data tables show DQ status.
    final badges =
        (dqPayload['descriptionBadges'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};
    final baseDescriptions =
        (payload['_tableDescriptions'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};
    var patched = 0;
    for (final entry in badges.entries) {
      final tableId = tableIdsByName[entry.key];
      if (tableId == null) continue;
      final base = baseDescriptions[entry.key]?.toString() ?? '';
      // Strip previous bridge section if re-running.
      final cleaned = _stripDqBadge(base);
      final next = '$cleaned${entry.value}';
      final res = await api(
        'PATCH',
        '/api/v1/tables/$tableId',
        body: jsonEncode([
          <String, dynamic>{
            'op': 'add',
            'path': '/description',
            'value': next,
          },
        ]),
        contentType: 'application/json-patch+json',
      );
      if (res != null) patched++;
    }

    stdout.writeln(
      'DQ bridge: testCases=$caseCount results=$resultCount '
      'descriptionPatches=$patched',
    );
  } finally {
    client.close(force: true);
  }
}

String _stripDqBadge(String description) {
  const marker = '\n---\n**Dart DQ bridge**';
  final i = description.indexOf(marker);
  if (i < 0) {
    // Also handle when description starts with badge after blank line variants.
    const alt = '**Dart DQ bridge**';
    final j = description.indexOf(alt);
    if (j < 0) return description.trimRight();
    return description.substring(0, j).trimRight();
  }
  return description.substring(0, i).trimRight();
}
