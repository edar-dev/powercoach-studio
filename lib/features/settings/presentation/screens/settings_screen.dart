import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/gymblog_api_client.dart';
import '../../../../core/utils/not_implemented.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/stitch_m3_theme.dart';

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
      backgroundColor: StitchM3Theme.bgSecondary,
      appBar: AppBar(
        backgroundColor: StitchM3Theme.bg,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black26,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.pop();
          },
        ),
        title: Text(
          l10n.settingsTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: StitchM3Theme.textPrimary,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: StitchM3Theme.border, height: 1),
        ),
      ),
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
                      color: StitchM3Theme.textMuted,
                    ),
                  ),
                  value: _notificationsEnabled,
                  onChanged: _setNotificationsEnabled,
                ),
                ListTile(
                  title: Text(l10n.settingsLanguage),
                  subtitle: Text(
                    l10n.settingsLanguageDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: StitchM3Theme.textMuted,
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
