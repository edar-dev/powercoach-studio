import 'dart:convert';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

/// A single uploaded backup snapshot in cloud storage.
class CloudBackupObject {
  const CloudBackupObject({
    required this.path,
    required this.name,
    required this.createdAt,
  });

  /// Full storage object path (folder + file name) inside the bucket.
  final String path;

  /// File name only, e.g. `2026-08-08T21:00:00.000Z.json`.
  final String name;

  final DateTime createdAt;
}

/// Thin abstraction over Supabase Storage so [CloudBackupRepository] can be
/// unit tested with a fake implementation instead of a live client.
abstract class CloudBackupStorage {
  Future<void> uploadJson(String path, String jsonString);

  /// Lists `.json` backup objects directly under [prefix], newest first.
  Future<List<CloudBackupObject>> list(String prefix);

  Future<String> downloadJson(String path);

  Future<void> remove(List<String> paths);
}

/// [CloudBackupStorage] backed by Supabase Storage (`user-backups` bucket).
class SupabaseCloudBackupStorage implements CloudBackupStorage {
  SupabaseCloudBackupStorage({required this.bucket, SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  final String bucket;

  @override
  Future<void> uploadJson(String path, String jsonString) async {
    await _client.storage
        .from(bucket)
        .uploadBinary(
          path,
          Uint8List.fromList(utf8.encode(jsonString)),
          fileOptions: const FileOptions(
            contentType: 'application/json',
            upsert: true,
          ),
        );
  }

  @override
  Future<List<CloudBackupObject>> list(String prefix) async {
    final files = await _client.storage
        .from(bucket)
        .list(
          path: prefix,
          searchOptions: const SearchOptions(
            sortBy: SortBy(column: 'created_at', order: 'desc'),
          ),
        );
    return [
      for (final file in files)
        if (file.name.endsWith('.json'))
          CloudBackupObject(
            path: '$prefix/${file.name}',
            name: file.name,
            createdAt:
                DateTime.tryParse(file.createdAt ?? '')?.toUtc() ??
                DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
          ),
    ];
  }

  @override
  Future<String> downloadJson(String path) async {
    final bytes = await _client.storage.from(bucket).download(path);
    return utf8.decode(bytes);
  }

  @override
  Future<void> remove(List<String> paths) async {
    if (paths.isEmpty) return;
    await _client.storage.from(bucket).remove(paths);
  }
}
