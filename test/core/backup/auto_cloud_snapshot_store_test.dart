import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/backup/auto_cloud_snapshot_store.dart';
import 'package:powercoach_studio/core/settings/settings_prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('isAutoEnabled defaults true when web default and unset', () async {
    final store = AutoCloudSnapshotStore(defaultEnabledOnWeb: true);
    expect(await store.isAutoEnabled(), isTrue);
  });

  test('isAutoEnabled defaults false when non-web default and unset', () async {
    final store = AutoCloudSnapshotStore(defaultEnabledOnWeb: false);
    expect(await store.isAutoEnabled(), isFalse);
  });

  test('explicit preference overrides default', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      SettingsPrefsKeys.autoCloudSnapshotEnabled: false,
    });
    final store = AutoCloudSnapshotStore(defaultEnabledOnWeb: true);
    expect(await store.isAutoEnabled(), isFalse);

    await store.setAutoEnabled(true);
    expect(await store.isAutoEnabled(), isTrue);
  });

  test('markSuccess clears error and stores timestamp', () async {
    final store = AutoCloudSnapshotStore(defaultEnabledOnWeb: true);
    await store.markError('u1', 'boom');
    expect(await store.lastError('u1'), 'boom');

    final at = DateTime.utc(2026, 3, 1, 12);
    await store.markSuccess('u1', at: at);
    expect(await store.lastError('u1'), isNull);
    expect(await store.lastSuccessAt('u1'), at);
  });

  test('markCloudSyncSuccess stores lastCloudSyncAt', () async {
    final store = AutoCloudSnapshotStore(defaultEnabledOnWeb: true);
    final at = DateTime.utc(2026, 4, 1);
    await store.markCloudSyncSuccess('u1', at: at);
    expect(await store.lastCloudSyncAt('u1'), at);
  });
}
