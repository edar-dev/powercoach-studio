import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/backup/auto_cloud_snapshot_store.dart';
import 'package:powercoach_studio/core/backup/backup_activity_store.dart';
import 'package:powercoach_studio/core/backup/cloud_upload_success.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('markCloudSnapshotUploadSuccess updates activity and auto stores',
      () async {
    final autoStore = AutoCloudSnapshotStore(defaultEnabledOnWeb: true);
    final at = DateTime.utc(2026, 5, 10, 15, 30);

    await autoStore.markError('coach-1', 'previous failure');
    expect(await autoStore.lastError('coach-1'), 'previous failure');

    await markCloudSnapshotUploadSuccess(
      'coach-1',
      at: at,
      activityStore: BackupActivityStore.instance,
      autoStore: autoStore,
    );

    expect(
      await BackupActivityStore.instance.lastSuccessfulBackupAt('coach-1'),
      at,
    );
    expect(await autoStore.lastSuccessAt('coach-1'), at);
    expect(await autoStore.lastError('coach-1'), isNull);
  });

  test('markCloudSnapshotUploadSuccess no-ops for empty userId', () async {
    final autoStore = AutoCloudSnapshotStore(defaultEnabledOnWeb: true);
    await markCloudSnapshotUploadSuccess(
      '',
      at: DateTime.utc(2026, 1, 1),
      autoStore: autoStore,
    );
    expect(await autoStore.lastSuccessAt(''), isNull);
  });
}
