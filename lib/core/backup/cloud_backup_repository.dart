import 'cloud_backup_storage.dart';

/// Supabase Storage bucket used for optional cloud backup snapshots.
const kCloudBackupBucket = 'user-backups';

/// Max snapshots kept per user; older ones are pruned after each upload.
const kCloudBackupMaxSnapshots = 5;

/// Optional Supabase Storage snapshots of the local backup JSON envelope.
///
/// This is **not** live sync: uploads happen only when the coach explicitly
/// taps "save to cloud" (or chooses to upload before signing out). See
/// `docs/sync-strategy.md` ("Cloud snapshots != sync").
class CloudBackupRepository {
  CloudBackupRepository({CloudBackupStorage? storage})
    : _storage =
          storage ?? SupabaseCloudBackupStorage(bucket: kCloudBackupBucket);

  static final CloudBackupRepository instance = CloudBackupRepository();

  final CloudBackupStorage _storage;

  String _backupsPrefix(String userId) => '$userId/backups';

  /// Uploads [jsonString] as a new timestamped snapshot for [userId], then
  /// prunes snapshots beyond [kCloudBackupMaxSnapshots] (oldest first).
  Future<CloudBackupObject> upload(String userId, String jsonString) async {
    if (userId.isEmpty) {
      throw StateError('userId required');
    }
    final now = DateTime.now().toUtc();
    final isoTimestamp = now.toIso8601String();
    final path = '${_backupsPrefix(userId)}/$isoTimestamp.json';

    await _storage.uploadJson(path, jsonString);
    await _pruneOldSnapshots(userId);

    return CloudBackupObject(
      path: path,
      name: '$isoTimestamp.json',
      createdAt: now,
    );
  }

  /// Lists snapshots for [userId], newest first.
  Future<List<CloudBackupObject>> list(String userId) async {
    if (userId.isEmpty) return const [];
    final objects = await _storage.list(_backupsPrefix(userId));
    return [...objects]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<String> download(String userId, String path) {
    _assertOwnedBackupPath(userId, path);
    return _storage.downloadJson(path);
  }

  Future<void> delete(String userId, String path) {
    _assertOwnedBackupPath(userId, path);
    return _storage.remove([path]);
  }

  void _assertOwnedBackupPath(String userId, String path) {
    if (userId.isEmpty) {
      throw StateError('userId required');
    }
    final prefix = '${_backupsPrefix(userId)}/';
    if (!path.startsWith(prefix)) {
      throw ArgumentError.value(path, 'path', 'outside user backups folder');
    }
  }

  Future<void> _pruneOldSnapshots(String userId) async {
    final all = await list(userId);
    if (all.length <= kCloudBackupMaxSnapshots) return;
    final toRemove = all
        .skip(kCloudBackupMaxSnapshots)
        .map((o) => o.path)
        .toList();
    await _storage.remove(toRemove);
  }
}
