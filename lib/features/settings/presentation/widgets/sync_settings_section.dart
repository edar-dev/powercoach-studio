import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/offline_local_store.dart';
import '../../../../core/sync/pending_operation_resolver.dart';
import '../../../../core/sync/sync_replay_hook.dart';
import '../../../../core/sync/sync_issue_filters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/app_snackbar.dart';

/// Sync queue summary and entry point to issue resolution.
class SyncSettingsSection extends StatefulWidget {
  const SyncSettingsSection({super.key});

  @override
  State<SyncSettingsSection> createState() => _SyncSettingsSectionState();
}

class _SyncSettingsSectionState extends State<SyncSettingsSection> {
  bool _loading = true;
  int _queued = 0;
  int _attention = 0;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final ops = await OfflineLocalStore.instance.readPendingOperations();
    if (!mounted) return;
    setState(() {
      _queued = countQueuedPendingOperations(ops);
      _attention = countAttentionPendingOperations(ops);
      _loading = false;
    });
  }

  Future<void> _retryFailed(AppLocalizations l10n) async {
    final ops = await OfflineLocalStore.instance.readPendingOperations();
    final failed = filterFailedPendingOperations(ops);
    if (failed.isEmpty) {
      if (!mounted) return;
      showAppSnackBar(context, content: Text(l10n.syncNoIssues));
      return;
    }
    await PendingOperationResolver().retryAllFailed(ops);
    await syncReplayHook.requestReplay();
    if (!mounted) return;
    showAppSnackBar(context, content: Text(l10n.syncRetryStarted(failed.length)));
    await _loadCounts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.settingsSyncSectionTitle,
          style: theme.textTheme.titleSmall?.copyWith(color: cs.primary),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.settingsSyncSectionSubtitle(_queued, _attention),
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            _attention > 0 ? Icons.sync_problem : Icons.sync,
            color: _attention > 0 ? cs.error : cs.onSurfaceVariant,
          ),
          title: Text(l10n.syncIssuesScreenTitle),
          subtitle: _loading
              ? null
              : Text(
                  _attention > 0
                      ? l10n.syncFailed(_attention)
                      : l10n.syncNoIssues,
                ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            await context.push('/settings/sync-issues');
            if (!mounted) return;
            await _loadCounts();
          },
        ),
        if (_attention > 0)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _loading ? null : () => _retryFailed(l10n),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.settingsSyncRetryFailed),
            ),
          ),
      ],
    );
  }
}
