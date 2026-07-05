import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';

/// No-op macOS notifications plugin for widget tests on macOS hosts.
class FakeMacOSFlutterLocalNotificationsPlugin
    extends MacOSFlutterLocalNotificationsPlugin {
  @override
  Future<bool?> initialize(
    DarwinInitializationSettings initializationSettings, {
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
  }) async =>
      true;

  @override
  Future<bool?> requestPermissions({
    bool sound = false,
    bool alert = false,
    bool badge = false,
    bool provisional = false,
    bool critical = false,
  }) async =>
      true;

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> cancel(int id) async {}
}

void registerFakeMacOSNotificationsPlatform() {
  FlutterLocalNotificationsPlatform.instance =
      FakeMacOSFlutterLocalNotificationsPlugin();
}
