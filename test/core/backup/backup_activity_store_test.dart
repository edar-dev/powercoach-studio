import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/backup/backup_activity_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final store = BackupActivityStore.instance;
  const uid = 'user-a';

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('shouldShowBackupReminder is true when never backed up', () async {
    expect(
      await store.shouldShowBackupReminder(uid, now: DateTime.utc(2026, 1, 10)),
      isTrue,
    );
  });

  test('shouldShowBackupReminder is false shortly after a backup', () async {
    await store.markBackupSuccess(uid, at: DateTime.utc(2026, 1, 1));
    expect(
      await store.shouldShowBackupReminder(
        uid,
        now: DateTime.utc(2026, 1, 3),
        maxAgeDays: 7,
      ),
      isFalse,
    );
  });

  test('shouldShowBackupReminder is true once maxAgeDays elapses', () async {
    await store.markBackupSuccess(uid, at: DateTime.utc(2026, 1, 1));
    expect(
      await store.shouldShowBackupReminder(
        uid,
        now: DateTime.utc(2026, 1, 10),
        maxAgeDays: 7,
      ),
      isTrue,
    );
  });

  test(
    'snoozeReminder suppresses the reminder until the window ends',
    () async {
      await store.markBackupSuccess(uid, at: DateTime.utc(2026, 1, 1));
      await store.snoozeReminder(uid, days: 3, now: DateTime.utc(2026, 1, 10));

      expect(
        await store.shouldShowBackupReminder(
          uid,
          now: DateTime.utc(2026, 1, 11),
          maxAgeDays: 7,
        ),
        isFalse,
      );
      expect(
        await store.shouldShowBackupReminder(
          uid,
          now: DateTime.utc(2026, 1, 14),
          maxAgeDays: 7,
        ),
        isTrue,
      );
    },
  );

  test('markBackupSuccess clears an active snooze', () async {
    await store.snoozeReminder(uid, days: 3, now: DateTime.utc(2026, 1, 1));
    await store.markBackupSuccess(uid, at: DateTime.utc(2026, 1, 2));

    expect(await store.reminderSnoozeUntil(uid), isNull);
  });

  test('activity is scoped per userId', () async {
    await store.markBackupSuccess(uid, at: DateTime.utc(2026, 1, 1));
    expect(
      await store.shouldShowBackupReminder(
        'user-b',
        now: DateTime.utc(2026, 1, 2),
      ),
      isTrue,
    );
    expect(
      await store.shouldShowBackupReminder(
        uid,
        now: DateTime.utc(2026, 1, 2),
      ),
      isFalse,
    );
  });
}
