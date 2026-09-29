import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:powercoach_studio/core/backup/local_data_probe.dart';
import 'package:powercoach_studio/core/storage/offline_local_store.dart';
import 'package:powercoach_studio/core/sync/offline_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_path_provider_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const uid = '__legacy__';

  setUpAll(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    PathProviderPlatform.instance = FakePathProviderPlatform(
      prefix: 'powercoach_local_probe_test_',
    );
  });

  setUp(() async {
    await OfflineLocalStore.instance.clear();
  });

  test('isCoachDataEmpty is true with no customers or plans', () async {
    final probe = LocalDataProbe(store: OfflineLocalStore.instance);
    expect(await probe.isCoachDataEmpty(uid), isTrue);
  });

  test('isCoachDataEmpty is false when a customer exists', () async {
    await OfflineLocalStore.instance.upsertEntityForUser(uid, {
      'id': 'c1',
      'type': OfflineEntityType.customer.name,
      'scopeId': 'c1',
      'payload': <String, dynamic>{'id': 'c1', 'name': 'A', 'userId': uid},
      'updatedAt': DateTime.utc(2026, 1, 1).toIso8601String(),
      'deleted': false,
      'localOnly': false,
    });
    final probe = LocalDataProbe(store: OfflineLocalStore.instance);
    expect(await probe.isCoachDataEmpty(uid), isFalse);
  });

  test('deleted-only customers still count as empty', () async {
    await OfflineLocalStore.instance.upsertEntityForUser(uid, {
      'id': 'c1',
      'type': OfflineEntityType.customer.name,
      'scopeId': 'c1',
      'payload': <String, dynamic>{'id': 'c1', 'name': 'A', 'userId': uid},
      'updatedAt': DateTime.utc(2026, 1, 1).toIso8601String(),
      'deleted': true,
      'localOnly': false,
    });
    final probe = LocalDataProbe(store: OfflineLocalStore.instance);
    expect(await probe.isCoachDataEmpty(uid), isTrue);
  });

  test('maxEntityUpdatedAt returns newest timestamp', () async {
    await OfflineLocalStore.instance.upsertEntityForUser(uid, {
      'id': 'c1',
      'type': OfflineEntityType.customer.name,
      'scopeId': 'c1',
      'payload': <String, dynamic>{'id': 'c1', 'name': 'A', 'userId': uid},
      'updatedAt': DateTime.utc(2026, 1, 1).toIso8601String(),
      'deleted': false,
      'localOnly': false,
    });
    await OfflineLocalStore.instance.upsertEntityForUser(uid, {
      'id': 'c2',
      'type': OfflineEntityType.customer.name,
      'scopeId': 'c2',
      'payload': <String, dynamic>{'id': 'c2', 'name': 'B', 'userId': uid},
      'updatedAt': DateTime.utc(2026, 5, 1).toIso8601String(),
      'deleted': false,
      'localOnly': false,
    });
    final probe = LocalDataProbe(store: OfflineLocalStore.instance);
    final max = await probe.maxEntityUpdatedAt(uid);
    expect(max, isNotNull);
    expect(max!.year, 2026);
    expect(max.month, 5);
    expect(max.day, 1);
  });
}
