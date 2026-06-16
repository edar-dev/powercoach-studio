import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../core/storage/offline_local_store.dart';
import '../../../../core/sync/offline_models.dart';
import '../../../../core/sync/pending_operation_resolver.dart';
import '../../../../core/sync/sync_replay_hook.dart';
import '../../../../core/sync/sync_issue_filters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/stitch_m3_theme.dart';
import '../../../../widgets/app_snackbar.dart';
import '../../../../widgets/app_sheet.dart';

/// Lists failed/conflict sync operations and lets the coach resolve them.
class SyncIssuesScreen extends StatefulWidget {
  const SyncIssuesScreen({super.key, this.preselectedOpId});

  final String? preselectedOpId;

  @override
  State<SyncIssuesScreen> createState() => _SyncIssuesScreenState();
}

class _SyncIssuesScreenState extends State<SyncIssuesScreen> {
  final _resolver = PendingOperationResolver();
  bool _loading = true;
  List<PendingOperation> _operations = const [];
  bool _didOpenPreselected = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final ops = await OfflineLocalStore.instance.readPendingOperations();
    if (!mounted) return;
    setState(() {
      _operations = ops;
      _loading = false;
    });
    _maybeOpenPreselected();
  }

  void _maybeOpenPreselected() {
    if (_didOpenPreselected || widget.preselectedOpId == null) return;
    final match = _operations.where((op) => op.id == widget.preselectedOpId);
    if (match.isEmpty) return;
    _didOpenPreselected = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showIssueDetail(match.first);
    });
  }

  List<PendingOperation> get _attentionOps =>
      filterAttentionPendingOperations(_operations);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.syncIssuesScreenTitle),
        actions: [
          IconButton(
            tooltip: l10n.settingsSyncRetryFailed,
            onPressed: _loading ? null : _retryAllFailed,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _attentionOps.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: StitchM3Theme.success,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.syncNoIssues,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: _attentionOps.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final op = _attentionOps[index];
                  return _SyncIssueTile(
                    operation: op,
                    onTap: () => _showIssueDetail(op),
                  );
                },
              ),
            ),
    );
  }

  Future<void> _retryAllFailed() async {
    final l10n = AppLocalizations.of(context);
    final failed = filterFailedPendingOperations(_operations);
    if (failed.isEmpty) {
      showAppSnackBar(context, content: Text(l10n.syncNoIssues));
      return;
    }
    await _resolver.retryAllFailed(_operations);
    await syncReplayHook.requestReplay();
    if (!mounted) return;
    showAppSnackBar(context, content: Text(l10n.syncRetryStarted(failed.length)));
    await _load();
  }

  Future<void> _showIssueDetail(PendingOperation op) async {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final busy = ValueNotifier<bool>(false);

    await showAppBottomSheet<void>(
      context: context,
      title: l10n.syncIssueDetailTitle,
      fullScreen: true,
      bodyBuilder: (sheetContext) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DetailRow(
            label: l10n.dashboardPendingStatusLabel(
              _statusLabel(l10n, op.status),
            ),
            value: op.entityType.name,
          ),
          _DetailRow(label: l10n.syncIssuePathLabel, value: op.path),
          if (op.errorMessage != null && op.errorMessage!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                op.errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(color: cs.error),
              ),
            ),
          Expanded(
            child: DefaultTabController(
              length: op.conflictRemotePayload == null ? 1 : 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (op.conflictRemotePayload != null)
                    TabBar(
                      labelColor: cs.primary,
                      tabs: [
                        Tab(text: l10n.syncIssueLocalVersion),
                        Tab(text: l10n.syncIssueRemoteVersion),
                      ],
                    ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _PayloadPreview(json: op.payload),
                        if (op.conflictRemotePayload != null)
                          _PayloadPreview(json: op.conflictRemotePayload!),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (op.status == PendingOperationStatus.conflict) ...[
            ValueListenableBuilder<bool>(
              valueListenable: busy,
              builder: (_, isBusy, __) => FilledButton(
                onPressed: isBusy
                    ? null
                    : () => _resolve(
                        sheetContext,
                        busy,
                        () => _resolver.keepLocal(op),
                        l10n.syncConflictUseLocal,
                        requestReplay: true,
                      ),
                child: Text(l10n.syncConflictUseLocal),
              ),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<bool>(
              valueListenable: busy,
              builder: (_, isBusy, __) => OutlinedButton(
                onPressed: isBusy || op.conflictRemotePayload == null
                    ? null
                    : () => _resolve(
                        sheetContext,
                        busy,
                        () => _resolver.acceptRemote(op),
                        l10n.syncConflictUseRemote,
                      ),
                child: Text(l10n.syncConflictUseRemote),
              ),
            ),
          ] else if (op.status == PendingOperationStatus.failed) ...[
            ValueListenableBuilder<bool>(
              valueListenable: busy,
              builder: (_, isBusy, __) => FilledButton.icon(
                onPressed: isBusy
                    ? null
                    : () => _resolve(
                        sheetContext,
                        busy,
                        () => _resolver.retry(op),
                        l10n.syncRetry,
                        requestReplay: true,
                      ),
                icon: const Icon(Icons.refresh),
                label: Text(l10n.syncRetry),
              ),
            ),
          ] else if (op.status == PendingOperationStatus.deadLetter ||
              op.status == PendingOperationStatus.blockedAuth) ...[
            ValueListenableBuilder<bool>(
              valueListenable: busy,
              builder: (_, isBusy, __) => OutlinedButton.icon(
                onPressed: isBusy
                    ? null
                    : () => _resolve(
                        sheetContext,
                        busy,
                        () => _resolver.discard(op),
                        l10n.syncIssueDiscard,
                      ),
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.syncIssueDiscard),
              ),
            ),
          ],
        ],
      ),
    );
    if (!mounted) return;
    await _load();
  }

  Future<void> _resolve(
    BuildContext sheetContext,
    ValueNotifier<bool> busy,
    Future<void> Function() action,
    String successLabel, {
    bool requestReplay = false,
  }) async {
    busy.value = true;
    try {
      await action();
      if (requestReplay) {
        await syncReplayHook.requestReplay();
      }
      if (!sheetContext.mounted) return;
      Navigator.of(sheetContext).pop();
      if (!mounted) return;
      showAppSnackBar(context, content: Text(successLabel));
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        content: Text(AppLocalizations.of(context).workoutExportError),
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
      );
    } finally {
      busy.value = false;
    }
  }

  String _statusLabel(AppLocalizations l10n, PendingOperationStatus status) {
    switch (status) {
      case PendingOperationStatus.failed:
        return l10n.dashboardSyncStatusFailed;
      case PendingOperationStatus.conflict:
        return l10n.dashboardSyncStatusConflict;
      case PendingOperationStatus.deadLetter:
        return l10n.dashboardSyncStatusDeadLetter;
      case PendingOperationStatus.blockedAuth:
        return l10n.dashboardSyncStatusBlockedAuth;
      default:
        return status.name;
    }
  }
}

class _SyncIssueTile extends StatelessWidget {
  const _SyncIssueTile({required this.operation, required this.onTap});

  final PendingOperation operation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final (icon, color) = switch (operation.status) {
      PendingOperationStatus.conflict => (
        Icons.compare_arrows,
        StitchM3Theme.warning,
      ),
      PendingOperationStatus.failed => (Icons.error_outline, cs.error),
      PendingOperationStatus.deadLetter => (Icons.block, cs.error),
      PendingOperationStatus.blockedAuth => (Icons.lock_outline, cs.error),
      _ => (Icons.info_outline, cs.onSurfaceVariant),
    };

    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      operation.entityType.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      operation.path,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    if (operation.errorMessage != null &&
                        operation.errorMessage!.trim().isNotEmpty)
                      Text(
                        operation.errorMessage!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.error,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$label\n$value',
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}

class _PayloadPreview extends StatelessWidget {
  const _PayloadPreview({required this.json});

  final Map<String, dynamic> json;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final pretty = const JsonEncoder.withIndent('  ').convert(json);
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: SingleChildScrollView(
        child: SelectableText(
          pretty,
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}
