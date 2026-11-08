import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../auth/supabase_bootstrap.dart';
import '../../routing/app_navigation.dart';
import '../../routing/app_paths.dart';
import '../../theme/stitch_m3_theme.dart';
import '../../../features/auth/data/local_coach_profile_repository.dart';
import '../../../l10n/app_localizations.dart';
import 'connectivity_status_chip.dart';

String _shellProfileInitials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final p = parts.first;
    return p.length >= 2
        ? p.substring(0, 2).toUpperCase()
        : p.toUpperCase();
  }
  return ('${parts.first[0]}${parts.last[0]}').toUpperCase();
}

/// Shared help / notifications / profile trailing actions for shell chrome.
///
/// Used by [PrimaryShellTopChrome] (wide) and phone hub [StitchAppBar]s.
/// No fake FAQ or notification inbox — help is a short tip dialog; bell opens
/// Settings (notifications prefs live there).
class ShellUtilityActions extends StatefulWidget {
  const ShellUtilityActions({
    super.key,
    this.includeSettings = false,
    this.dense = false,
  });

  /// When true (phone hubs), append a settings gear so Settings stays reachable
  /// without the extended rail.
  final bool includeSettings;

  /// Slightly tighter spacing for AppBar action rows.
  final bool dense;

  @override
  State<ShellUtilityActions> createState() => _ShellUtilityActionsState();
}

class _ShellUtilityActionsState extends State<ShellUtilityActions> {
  String _displayName = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadCoachDisplayName();
    });
  }

  Future<void> _loadCoachDisplayName() async {
    final l10n = AppLocalizations.of(context);
    final fallback = l10n.dashboardGreetingFallbackName;
    final uid = SupabaseBootstrap.currentUser?.id;
    if (uid == null || uid.isEmpty) {
      if (!mounted) return;
      setState(() => _displayName = fallback);
      return;
    }
    try {
      final profile =
          await LocalCoachProfileRepository.instance.getProfile(uid);
      if (!mounted) return;
      final name = profile.displayName.trim();
      setState(() => _displayName = name.isEmpty ? fallback : name);
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      if (!mounted) return;
      setState(() => _displayName = fallback);
    }
  }

  void _openHelp() {
    HapticFeedback.selectionClick();
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final dlg = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(dlg.shellHelpDialogTitle),
          content: Text(dlg.shellHelpDialogBody),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                navigateTo(context, AppPaths.settings);
              },
              child: Text(dlg.settingsTitle),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(MaterialLocalizations.of(ctx).closeButtonLabel),
            ),
          ],
        );
      },
    );
  }

  void _openNotifications() {
    HapticFeedback.selectionClick();
    // No fake inbox — notifications prefs live on the settings hub.
    navigateTo(context, AppPaths.settings);
  }

  void _openProfile() {
    HapticFeedback.selectionClick();
    navigateTo(context, AppPaths.personalInfo);
  }

  void _openSettings() {
    HapticFeedback.mediumImpact();
    navigateTo(context, AppPaths.settings);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final gap = widget.dense ? 0.0 : 4.0;
    final name = _displayName.isEmpty
        ? l10n.dashboardGreetingFallbackName
        : _displayName;
    final initials = _shellProfileInitials(name);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConnectivityStatusChip(dense: widget.dense),
        IconButton(
          tooltip: l10n.shellHelpTooltip,
          icon: const Icon(Icons.help_outline),
          onPressed: _openHelp,
        ),
        SizedBox(width: gap),
        IconButton(
          tooltip: l10n.shellNotificationsTooltip,
          icon: const Icon(Icons.notifications_outlined),
          onPressed: _openNotifications,
        ),
        SizedBox(width: gap),
        Padding(
          padding: EdgeInsets.only(right: widget.includeSettings ? 0 : 8),
          child: Tooltip(
            message: l10n.shellProfileTooltip,
            child: InkWell(
              onTap: _openProfile,
              borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: cs.primaryContainer,
                      foregroundColor: cs.onPrimaryContainer,
                      child: Text(
                        initials,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.onPrimaryContainer,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 120),
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (widget.includeSettings)
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTitle,
            onPressed: _openSettings,
          ),
      ],
    );
  }
}

/// Convenience list for phone hub [StitchAppBar.actions].
List<Widget> phoneHubUtilityActions({bool includeSettings = true}) {
  return [
    ShellUtilityActions(
      includeSettings: includeSettings,
      dense: true,
    ),
  ];
}
