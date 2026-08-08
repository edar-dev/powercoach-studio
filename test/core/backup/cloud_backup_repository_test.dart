import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/backup/cloud_backup_repository.dart';
import 'package:powercoach_studio/core/backup/cloud_backup_storage.dart';

class _FakeCloudBackupStorage implements CloudBackupStorage {
  final Map<String, String> files = {};
  final Map<String, DateTime> createdAtByPath = {};
  final List<String> removedPaths = [];

  @override
  Future<void> uploadJson(String path, String jsonString) async {
    files[path] = jsonString;
    createdAtByPath[path] = DateTime.now().toUtc();
  }

  @override
  Future<List<CloudBackupObject>> list(String prefix) async {
    return [
      for (final path in files.keys)
        if (path.startsWith('$prefix/'))
          CloudBackupObject(
            path: path,
            name: path.split('/').last,
            createdAt: createdAtByPath[path]!,
          ),
    ];
  }

  @override
  Future<String> downloadJson(String path) async {
    final content = files[path];
    if (content == null) throw StateError('missing: $path');
    return content;
  }

  @override
  Future<void> remove(List<String> paths) async {
    removedPaths.addAll(paths);
    for (final path in paths) {
      files.remove(path);
      createdAtByPath.remove(path);
    }
  }
}

void main() {
  test('upload writes a timestamped path under {userId}/backups', () async {
    final storage = _FakeCloudBackupStorage();
    final repo = CloudBackupRepository(storage: storage);

    final object = await repo.upload('user-1', '{"a":1}');

    expect(object.path, startsWith('user-1/backups/'));
    expect(object.path, endsWith('.json'));
    expect(storage.files[object.path], '{"a":1}');
  });

  test('upload throws for an empty userId', () async {
    final repo = CloudBackupRepository(storage: _FakeCloudBackupStorage());
    expect(() => repo.upload('', '{}'), throwsStateError);
  });

  test(
    'upload prunes older snapshots beyond the max, keeping newest',
    () async {
      final storage = _FakeCloudBackupStorage();
      final repo = CloudBackupRepository(storage: storage);

      for (var i = 0; i < kCloudBackupMaxSnapshots; i++) {
        final path = 'user-1/backups/seed-$i.json';
        storage.files[path] = '{}';
        storage.createdAtByPath[path] = DateTime.utc(2026, 1, 1 + i);
      }

      await repo.upload('user-1', '{"latest":true}');

      final remaining = await repo.list('user-1');
      expect(remaining.length, kCloudBackupMaxSnapshots);
      expect(storage.removedPaths, contains('user-1/backups/seed-0.json'));
      expect(remaining.any((o) => o.path.contains('seed-0')), isFalse);
    },
  );

  test('list returns snapshots sorted newest first', () async {
    final storage = _FakeCloudBackupStorage();
    final repo = CloudBackupRepository(storage: storage);
    storage.files['user-1/backups/a.json'] = '{}';
    storage.createdAtByPath['user-1/backups/a.json'] = DateTime.utc(2026, 1, 1);
    storage.files['user-1/backups/b.json'] = '{}';
    storage.createdAtByPath['user-1/backups/b.json'] = DateTime.utc(2026, 2, 1);

    final result = await repo.list('user-1');
    expect(result.map((o) => o.name).toList(), ['b.json', 'a.json']);
  });

  test('download returns the stored JSON content', () async {
    final storage = _FakeCloudBackupStorage();
    final repo = CloudBackupRepository(storage: storage);
    storage.files['user-1/backups/a.json'] = '{"ok":true}';
    storage.createdAtByPath['user-1/backups/a.json'] = DateTime.utc(2026, 1, 1);

    expect(await repo.download('user-1', 'user-1/backups/a.json'), '{"ok":true}');
  });

  test('download rejects paths outside the user backups folder', () async {
    final repo = CloudBackupRepository(storage: _FakeCloudBackupStorage());
    expect(
      () => repo.download('user-1', 'user-2/backups/a.json'),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('delete removes the snapshot from storage', () async {
    final storage = _FakeCloudBackupStorage();
    final repo = CloudBackupRepository(storage: storage);
    storage.files['user-1/backups/a.json'] = '{}';
    storage.createdAtByPath['user-1/backups/a.json'] = DateTime.utc(2026, 1, 1);

    await repo.delete('user-1', 'user-1/backups/a.json');

    expect(storage.removedPaths, ['user-1/backups/a.json']);
    expect(await repo.list('user-1'), isEmpty);
  });
}
