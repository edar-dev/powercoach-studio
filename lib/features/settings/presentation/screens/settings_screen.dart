import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/gymblog_api_client.dart';
import '../../../../core/storage/offline_local_store.dart';
import '../../../../core/sync/sync_orchestrator.dart';
import '../../../../core/utils/not_implemented.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/stitch_secondary_app_bar.dart';

const _keyNotificationsEnabled = 'settings_notifications_enabled';

/// Simplified App Settings – Stitch screen ID 8ab8a84172594c1c9911b5762e2a7257.
/// Personal info, Subscription, Notifications, Language, Sign out.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _loadingPrefs = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool(_keyNotificationsEnabled) ?? true;
      _loadingPrefs = false;
    });
  }

  Future<void> _setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, value);
    if (mounted) setState(() => _notificationsEnabled = value);
  }

  void _signOut() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid != null) {
      await OfflineLocalStore.instance.wipeForUser(uid);
    }
    GymBlogApiClient.clearCache();
    await Supabase.instance.client.auth.signOut();
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      appBar: StitchSecondaryAppBar(title: l10n.settingsTitle),
      body: _loadingPrefs
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              children: [
                ListTile(
                  title: Text(l10n.settingsPersonalInfo),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/personal-info'),
                ),
                ListTile(
                  title: Text(l10n.settingsSubscription),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/subscription'),
                ),
                SwitchListTile(
                  title: Text(l10n.settingsNotifications),
                  subtitle: Text(
                    l10n.settingsNotificationsDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  value: _notificationsEnabled,
                  onChanged: _setNotificationsEnabled,
                ),
                ListenableBuilder(
                  listenable: SyncOrchestrator.instance.status,
                  builder: (context, _) {
                    final st = SyncOrchestrator.instance.status;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.settingsSyncSectionTitle,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.syncNow),
                          subtitle: Text(
                            l10n.settingsSyncSectionSubtitle(
                              st.pendingCount,
                              st.failedCount,
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          trailing: const Icon(Icons.sync),
                          onTap: () => SyncOrchestrator.instance.syncNow(),
                        ),
                        if (st.failedCount > 0)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(l10n.settingsSyncRetryFailed),
                            trailing: const Icon(Icons.refresh),
                            onTap: () =>
                                SyncOrchestrator.instance.resetFailedAndDeadLetterToPending(),
                          ),
                      ],
                    );
                  },
                ),
                const Divider(height: 32),
                ListTile(
                  title: Text(l10n.settingsLanguage),
                  subtitle: Text(
                    l10n.settingsLanguageDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showNotImplementedAlert(context),
                ),
                const Divider(height: 32),
                ListTile(
                  title: Text(
                    l10n.profileSignOut,
                    style: TextStyle(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: _signOut,
                ),
              ],
            ),
    );
  }
}
