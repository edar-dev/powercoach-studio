import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/auth/supabase_bootstrap.dart';
import '../../../../core/backup/backup_activity_store.dart';
import '../../../../core/routing/app_navigation.dart';
import '../../../../core/routing/app_paths.dart';
import '../../../../l10n/app_localizations.dart';

/// Teal alert palette matching Stitch `data-purpose="backup-alert-banner"`.
abstract final class _BackupBannerColors {
  static const Color surfaceStart = Color(0xFF005F56);
  static const Color surfaceMid = Color(0xFF01685E);
  static const Color surfaceEnd = Color(0xFF044C45);
  static const Color border = Color(0x662DD4BF); // teal-400 @ 40%
  static const Color iconTileBg = Color(0x99042F2A); // teal-950/60 feel
  static const Color iconTileBorder = Color(0x4D5EEAD4); // teal-300/30
  static const Color iconFg = Color(0xFF99F6E4); // teal-200
  static const Color subtitle = Color(0xE5CCFBF1); // teal-100/90
  static const Color chipBg = Color(0x80134E4A); // teal-900/50
  static const Color chipBorder = Color(0x4D14B8A6); // teal-500/30
  static const Color chipFg = Color(0xFFCCFBF1); // teal-100
}

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

  void _openSettings() {
    HapticFeedback.mediumImpact();
    navigateTo(context, AppPaths.settings);
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked || !_visible) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _openSettings,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  _BackupBannerColors.surfaceStart,
                  _BackupBannerColors.surfaceMid,
                  _BackupBannerColors.surfaceEnd,
                ],
              ),
              border: Border.all(color: _BackupBannerColors.border),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x66042F2A),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final stackActions = constraints.maxWidth < 520;
                  final actions = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _snooze,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _BackupBannerColors.chipBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _BackupBannerColors.chipBorder,
                              ),
                            ),
                            child: Text(
                              l10n.dashboardBackupReminderSnooze,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: _BackupBannerColors.chipFg,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.dashboardBackupReminderDismissSemantic,
                        onPressed: _snooze,
                        visualDensity: VisualDensity.compact,
                        style: IconButton.styleFrom(
                          foregroundColor: _BackupBannerColors.iconFg,
                        ),
                        icon: const Icon(Icons.close, size: 20),
                      ),
                    ],
                  );

                  final body = Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _BackupBannerColors.iconTileBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _BackupBannerColors.iconTileBorder,
                          ),
                        ),
                        child: const Icon(
                          Icons.cloud_download_outlined,
                          color: _BackupBannerColors.iconFg,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.dashboardBackupReminderMessage,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.dashboardBackupReminderSubtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _BackupBannerColors.subtitle,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              l10n.dashboardBackupReminderCta,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                                decorationThickness: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );

                  if (stackActions) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        body,
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: actions,
                        ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: body),
                      const SizedBox(width: 8),
                      actions,
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
