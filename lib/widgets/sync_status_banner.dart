import 'package:flutter/material.dart';

import '../core/sync/offline_models.dart';
import '../core/sync/sync_orchestrator.dart';

class SyncStatusBanner extends StatefulWidget {
  const SyncStatusBanner({super.key, required this.child});

  final Widget child;

  @override
  State<SyncStatusBanner> createState() => _SyncStatusBannerState();
}

class _SyncStatusBannerState extends State<SyncStatusBanner> {
  final SyncOrchestrator _sync = SyncOrchestrator.instance;
  bool _showingConflict = false;

  @override
  void initState() {
    super.initState();
    _sync.status.addListener(_onStatusChanged);
  }

  @override
  void dispose() {
    _sync.status.removeListener(_onStatusChanged);
    super.dispose();
  }

  void _onStatusChanged() {
    if (!mounted || _showingConflict) return;
    final conflicts = _sync.status.conflicts;
    if (conflicts.isNotEmpty) {
      _showConflictDialog(conflicts.first);
    }
    setState(() {});
  }

  Future<void> _showConflictDialog(PendingOperation op) async {
    _showingConflict = true;
    final choice = await showDialog<ConflictResolutionChoice>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sync conflict detected'),
        content: const Text(
          'There are conflicting local and remote changes. '
          'Choose whether to keep local changes or accept the remote version.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(ConflictResolutionChoice.keepRemote),
            child: const Text('Use remote'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(ConflictResolutionChoice.keepLocal),
            child: const Text('Use local'),
          ),
        ],
      ),
    );
    if (choice != null) {
      await _sync.resolveConflict(op, choice);
    }
    _showingConflict = false;
  }

  @override
  Widget build(BuildContext context) {
    final status = _sync.status;
    final showBanner = status.isSyncing || status.pendingCount > 0 || status.failedCount > 0;
    final cs = Theme.of(context).colorScheme;
    final text = status.failedCount > 0
        ? 'Sync failed: ${status.failedCount} pending'
        : status.isSyncing
            ? 'Synchronizing changes...'
            : status.pendingCount > 0
                ? 'Pending sync: ${status.pendingCount}'
                : '';
    return Stack(
      children: [
        widget.child,
        if (showBanner)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              color: status.failedCount > 0 ? cs.errorContainer : cs.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      status.failedCount > 0
                          ? Icons.sync_problem_outlined
                          : status.isSyncing
                              ? Icons.sync
                              : Icons.schedule,
                      size: 18,
                      color: status.failedCount > 0 ? cs.onErrorContainer : cs.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        text,
                        style: TextStyle(
                          color: status.failedCount > 0 ? cs.onErrorContainer : cs.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _sync.syncNow,
                      child: const Text('Sync now'),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
