import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/settings/settings_prefs_keys.dart';
import 'package:powercoach_studio/features/exercise_library/data/pinned_exercises_store.dart';
import 'package:powercoach_studio/features/exercise_library/data/recent_exercises_store.dart';
import 'package:powercoach_studio/features/settings/data/user_preferences_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UserPreferencesRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    repository = UserPreferencesRepository.instance;
  });

  group('locale', () {
    test('defaults to Italian', () async {
      expect(await repository.getLocaleCode(), 'it');
    });

    test('persists locale code', () async {
      await repository.setLocaleCode('en');
      expect(await repository.getLocaleCode(), 'en');
    });
  });

  group('notifications', () {
    test('defaults to enabled', () async {
      expect(await repository.getNotificationsEnabled(), isTrue);
    });

    test('persists disabled state', () async {
      await repository.setNotificationsEnabled(false);
      expect(await repository.getNotificationsEnabled(), isFalse);
    });
  });

  group('calendar reminders', () {
    test('defaults to disabled with 24h lead', () async {
      expect(await repository.getCalendarRemindersEnabled(), isFalse);
      expect(await repository.getCalendarReminderLeadHours(), 24);
    });

    test('persists calendar reminder settings', () async {
      await repository.setCalendarRemindersEnabled(true);
      await repository.setCalendarReminderLeadHours(48);
      expect(await repository.getCalendarRemindersEnabled(), isTrue);
      expect(await repository.getCalendarReminderLeadHours(), 48);
    });
  });

  group('loadAll', () {
    test('returns snapshot from stored prefs', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        SettingsPrefsKeys.appLocaleCode: 'en',
        SettingsPrefsKeys.notificationsEnabled: false,
        SettingsPrefsKeys.calendarRemindersEnabled: true,
        SettingsPrefsKeys.calendarReminderLeadHours: 12,
      });

      final snapshot = await repository.loadAll();
      expect(snapshot.localeCode, 'en');
      expect(snapshot.notificationsEnabled, isFalse);
      expect(snapshot.calendarRemindersEnabled, isTrue);
      expect(snapshot.calendarReminderLeadHours, 12);
      expect(snapshot.workoutBuilderCompactAdd, isNull);
      expect(snapshot.workoutBuilderIncludeMobilityDefault, isFalse);
    });
  });

  group('workout builder prefs', () {
    test('compact add tri-state', () async {
      expect(await repository.getWorkoutBuilderCompactAdd(), isNull);
      await repository.setWorkoutBuilderCompactAdd(true);
      expect(await repository.getWorkoutBuilderCompactAdd(), isTrue);
      await repository.setWorkoutBuilderCompactAdd(null);
      expect(await repository.getWorkoutBuilderCompactAdd(), isNull);
    });

    test('include mobility default is off', () async {
      expect(await repository.getWorkoutBuilderIncludeMobilityDefault(), isFalse);
      await repository.setWorkoutBuilderIncludeMobilityDefault(true);
      expect(await repository.getWorkoutBuilderIncludeMobilityDefault(), isTrue);
      await repository.setWorkoutBuilderIncludeMobilityDefault(false);
      expect(await repository.getWorkoutBuilderIncludeMobilityDefault(), isFalse);
    });
  });

  group('backup pin/recent id lists', () {
    test('exportForBackup emits native Lists', () async {
      await PinnedExercisesStore.instance.replaceAll({'ex-a', 'ex-b'});
      await RecentExercisesStore.instance.replaceAll(['ex-b', 'ex-c']);

      final map = await repository.exportForBackup();
      expect(
        map[SettingsPrefsKeys.pinnedExerciseIdsJson],
        isA<List>(),
      );
      expect(
        map[SettingsPrefsKeys.recentExerciseIdsJson],
        isA<List>(),
      );
      expect(
        (map[SettingsPrefsKeys.pinnedExerciseIdsJson] as List).toSet(),
        {'ex-a', 'ex-b'},
      );
      expect(
        map[SettingsPrefsKeys.recentExerciseIdsJson],
        ['ex-b', 'ex-c'],
      );
    });

    test('applyFromBackupMap accepts List and legacy JSON string', () async {
      await PinnedExercisesStore.instance.replaceAll({});
      await RecentExercisesStore.instance.replaceAll([]);

      await repository.applyFromBackupMap({
        SettingsPrefsKeys.pinnedExerciseIdsJson: <String>['ex-list'],
        SettingsPrefsKeys.recentExerciseIdsJson: jsonEncode(['ex-string']),
      });

      expect(await PinnedExercisesStore.instance.getPinnedIds(), {'ex-list'});
      expect(await RecentExercisesStore.instance.getRecentIds(), ['ex-string']);
    });
  });
}
