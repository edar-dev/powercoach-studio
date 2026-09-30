import 'auto_cloud_snapshot_store.dart';
import 'backup_activity_store.dart';

/// Marks a successful cloud snapshot upload in both activity and auto stores.
///
/// Used by manual Settings upload and [CloudSnapshotScheduler] so
/// "Last backup" and "Last automatic cloud backup" stay aligned.
Future<void> markCloudSnapshotUploadSuccess(
  String userId, {
  DateTime? at,
  BackupActivityStore? activityStore,
  AutoCloudSnapshotStore? autoStore,
}) async {
  if (userId.isEmpty) return;
  final activity = activityStore ?? BackupActivityStore.instance;
  final auto = autoStore ?? AutoCloudSnapshotStore.instance;
  await activity.markBackupSuccess(userId, at: at);
  await auto.markSuccess(userId, at: at);
}
