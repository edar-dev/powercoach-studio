import 'dart:convert';
import 'dart:io';

import 'om_catalog_payload.dart';
import 'om_live_defaults.dart';

/// Custom OpenMetadata ingestion for the PowerCoach data catalog spike.
///
/// Reads [tool/openmetadata/fixtures/registry.json] (+ optional sample entities)
/// and either:
/// - `--dry-run` (default): writes an OM-oriented payload JSON for inspection
/// - `--live`: POSTs service / schema / tables / lineage to a local OM server
///
/// No secrets are required for dry-run. Live mode uses the local OM 1.5.15
/// quickstart defaults (`admin@open-metadata.org` / `admin`) against
/// http://localhost:8585 — never for prod. The login API receives a
/// Base64-encoded password; lineage edges use table UUIDs (not FQNs).
///
/// Usage (from repo root):
///   dart run tool/openmetadata/ingestion/ingest_from_registry.dart
///   dart run tool/openmetadata/ingestion/ingest_from_registry.dart --live
void main(List<String> args) async {
  final live = args.contains('--live');
  final root = _findRepoRoot();
  final fixturesDir = Directory('${root.path}/tool/openmetadata/fixtures');
  final registryFile = File('${fixturesDir.path}/registry.json');
  final sampleFile = File('${fixturesDir.path}/sample_entities.json');
  final outFile = File('${fixturesDir.path}/om_catalog_payload.json');

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
  stdout.writeln('Wrote ${outFile.path}');
  stdout.writeln(
    'tables=${(payload['tables'] as List).length} '
    'lineageEdges=${(payload['lineageEdges'] as List).length}',
  );

  if (!live) {
    stdout.writeln(
      'Dry-run only. Pass --live after `docker compose up` to push.',
    );
    return;
  }

  final baseUrl = Platform.environment['OM_BASE_URL'] ?? kOmDefaultBaseUrl;
  final token = await _login(
    baseUrl: baseUrl,
    email: Platform.environment['OM_EMAIL'] ?? kOmDefaultEmail,
    // OM_PASSWORD is plaintext; the login API requires Base64.
    password: Platform.environment['OM_PASSWORD'] ?? kOmDefaultPassword,
  );
  await _ingestLive(baseUrl: baseUrl, token: token, payload: payload);
  stdout.writeln('Live ingestion finished against $baseUrl');
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

Future<String> _login({
  required String baseUrl,
  required String email,
  required String password,
}) async {
  final client = HttpClient();
  try {
    final req = await client.postUrl(Uri.parse('$baseUrl/api/v1/users/login'));
    req.headers.contentType = ContentType.json;
    req.write(
      jsonEncode(<String, dynamic>{
        'email': email,
        'password': encodeOmLoginPassword(password),
      }),
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

Future<void> _ingestLive({
  required String baseUrl,
  required String token,
  required Map<String, dynamic> payload,
}) async {
  final client = HttpClient();
  Future<Map<String, dynamic>?> api(
    String method,
    String path, {
    Object? body,
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
    req.headers.contentType = ContentType.json;
    if (body != null) req.write(jsonEncode(body));
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
    // OM lineage EntityReference.id must be a UUID (not an FQN).
    final tableIdsByName = <String, String>{};
    for (final table in tables) {
      final name = table['name']?.toString() ?? '';
      final fqn = '$schemaFqn.$name';
      final created = await api(
        'POST',
        '/api/v1/tables',
        body: <String, dynamic>{
          'name': name,
          'displayName': table['displayName'],
          'description': table['description'],
          'tableType': 'Regular',
          'columns': table['columns'],
          'databaseSchema': schemaFqn,
        },
      );
      var id = created?['id']?.toString();
      if (id == null || id.isEmpty) {
        // Re-run / already exists: resolve UUID by FQN.
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
  } finally {
    client.close(force: true);
  }
}
