import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/notifications/notification_scheduler_service.dart';
import '../../../../core/notifications/reminder_store.dart';
import '../../../../core/storage/offline_local_store.dart';

Future<void> performSettingsSignOut(BuildContext context) async {
  if (!kIsWeb &&
      NotificationSchedulerService.instance.supportsLocalNotifications) {
    await NotificationSchedulerService.instance.cancelAllScheduled();
    await ReminderStore.instance.clear();
  }
  final uid = SupabaseBootstrap.currentUser?.id;
  if (uid != null) {
    await OfflineLocalStore.instance.wipeForUser(uid);
  }
  await Supabase.instance.client.auth.signOut();
  if (context.mounted) context.go('/');
}
