import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/settings/settings_prefs_keys.dart';
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
      expect(snapshot.workoutBuilderIncludeMobilityDefault, isTrue);
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

    test('include mobility default persists', () async {
      await repository.setWorkoutBuilderIncludeMobilityDefault(false);
      expect(await repository.getWorkoutBuilderIncludeMobilityDefault(), isFalse);
    });
  });
}
