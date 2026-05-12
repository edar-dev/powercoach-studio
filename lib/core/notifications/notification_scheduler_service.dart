import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../routing/root_navigator_key.dart';
import '../settings/settings_prefs_keys.dart';
import 'reminder.dart';
import 'reminder_store.dart';

/// Local notification plugin wiring: channels, permissions, zoned schedule, cancel.
class NotificationSchedulerService {
  NotificationSchedulerService._();

  static final NotificationSchedulerService instance =
      NotificationSchedulerService._();

  static const _androidChannelId = 'powercoach_reminders';
  static const _androidChannelName = 'Reminders';
  static const _androidChannelDescription =
      'Session and client reminders scheduled in the app';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  bool get supportsLocalNotifications =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    if (!supportsLocalNotifications) {
      _initialized = true;
      return;
    }

    tz_data.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          _androidChannelId,
          _androidChannelName,
          description: _androidChannelDescription,
          importance: Importance.defaultImportance,
        ),
      );
    }

    _initialized = true;
  }

  void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = appRootNavigatorKey.currentContext;
      if (ctx == null || !ctx.mounted) return;
      final router = GoRouter.maybeOf(ctx);
      if (router == null) return;
      router.go(payload);
    });
  }

  /// Ask OS for notification permission. Returns `true` if granted / provisional.
  Future<bool> requestOsPermission() async {
    if (!supportsLocalNotifications) return false;
    await ensureInitialized();

    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      if (granted != null) return granted;
      return true;
    }

    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final r = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return r ?? false;
    }

    if (Platform.isMacOS) {
      final mac = _plugin.resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>();
      final r = await mac?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return r ?? false;
    }

    return false;
  }

  Future<bool> _notificationsPreferenceEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(SettingsPrefsKeys.notificationsEnabled) ?? true;
  }

  /// Cancels all pending local notifications for this app.
  Future<void> cancelAllScheduled() async {
    if (!supportsLocalNotifications) return;
    await ensureInitialized();
    await _plugin.cancelAll();
  }

  Future<void> cancelReminder(Reminder reminder) async {
    if (!supportsLocalNotifications) return;
    await ensureInitialized();
    await _plugin.cancel(Reminder.stableNotificationId(reminder.id));
  }

  /// Schedules one reminder at its UTC instant (inexact alarm on Android — Play-friendly).
  Future<void> scheduleReminder(Reminder reminder) async {
    if (!supportsLocalNotifications) return;
    await ensureInitialized();
    if (!await _notificationsPreferenceEnabled()) return;

    final now = DateTime.now().toUtc();
    if (!reminder.scheduledAtUtc.toUtc().isAfter(now)) return;

    final when = tz.TZDateTime.from(reminder.scheduledAtUtc.toUtc(), tz.UTC);

    const androidDetails = AndroidNotificationDetails(
      _androidChannelId,
      _androidChannelName,
      channelDescription: _androidChannelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _plugin.zonedSchedule(
      Reminder.stableNotificationId(reminder.id),
      reminder.title,
      reminder.body,
      when,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: reminder.routePayload,
    );
  }

  /// Re-schedules all future reminders when notifications preference is on.
  Future<void> syncWithNotificationPreference() async {
    if (!supportsLocalNotifications) return;
    await ensureInitialized();

    if (!await _notificationsPreferenceEnabled()) {
      await _plugin.cancelAll();
      return;
    }

    await _plugin.cancelAll();
    final reminders = await ReminderStore.instance.loadAll();
    final now = DateTime.now().toUtc();
    for (final r in reminders) {
      if (r.scheduledAtUtc.toUtc().isAfter(now)) {
        await scheduleReminder(r);
      }
    }
  }

  /// If preference says enabled but OS denied permission, turn preference off.
  Future<void> downgradePreferenceIfOsDenied() async {
    if (!supportsLocalNotifications) return;
    await ensureInitialized();
    final prefs = await SharedPreferences.getInstance();
    final want = prefs.getBool(SettingsPrefsKeys.notificationsEnabled) ?? true;
    if (!want) return;

    var allowed = true;
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      allowed = await android?.areNotificationsEnabled() ?? true;
    }

    if (!allowed) {
      await prefs.setBool(SettingsPrefsKeys.notificationsEnabled, false);
      await _plugin.cancelAll();
    }
  }
}
