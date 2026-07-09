import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/settings/backup_onboarding_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('BackupOnboardingStore tracks seen state per user', () async {
    const userA = 'user-a';
    const userB = 'user-b';
    final store = BackupOnboardingStore.instance;

    expect(await store.hasSeen(userA), isFalse);
    await store.markSeen(userA);
    expect(await store.hasSeen(userA), isTrue);
    expect(await store.hasSeen(userB), isFalse);
  });

  test('empty user id is treated as already seen', () async {
    final store = BackupOnboardingStore.instance;
    expect(await store.hasSeen(''), isTrue);
    await store.markSeen('');
    expect(await store.hasSeen(''), isTrue);
  });
}
