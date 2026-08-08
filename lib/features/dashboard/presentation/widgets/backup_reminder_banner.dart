import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/auth/supabase_bootstrap.dart';
import '../../../../core/backup/backup_activity_store.dart';
import '../../../../core/routing/app_navigation.dart';
import '../../../../core/routing/app_paths.dart';
import '../../../../core/theme/stitch_m3_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Dashboard nudge shown when the coach's last backup (file or cloud) is
/// older than [BackupActivityStore]'s reminder window — not shown for
/// signed-out sessions. Dismissible via a 3-day snooze; CTA opens Settings.
class BackupReminderBanner extends StatefulWidget {
  const BackupReminderBanner({super.key});

  @override
  State<BackupReminderBanner> createState() => _BackupReminderBannerState();
}

class _BackupReminderBannerState extends State<BackupReminderBanner> {
  bool _checked = false;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _checkReminder();
  }

  Future<void> _checkReminder() async {
    final uid = SupabaseBootstrap.currentUser?.id;
    if (uid == null || uid.isEmpty) {
      if (mounted) setState(() => _checked = true);
      return;
    }
    final show =
        await BackupActivityStore.instance.shouldShowBackupReminder(uid);
    if (!mounted) return;
    setState(() {
      _visible = show;
      _checked = true;
    });
  }

  Future<void> _snooze() async {
    HapticFeedback.mediumImpact();
    final uid = SupabaseBootstrap.currentUser?.id;
    if (uid != null && uid.isNotEmpty) {
      await BackupActivityStore.instance.snoozeReminder(uid);
    }
    if (!mounted) return;
    setState(() => _visible = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked || !_visible) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
          onTap: () {
            HapticFeedback.mediumImpact();
            navigateTo(context, AppPaths.settings);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.backup_outlined, color: cs.onSecondaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dashboardBackupReminderMessage,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.dashboardBackupReminderCta,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: cs.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _snooze,
                  style: TextButton.styleFrom(
                    foregroundColor: cs.onSecondaryContainer,
                  ),
                  child: Text(l10n.dashboardBackupReminderSnooze),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
