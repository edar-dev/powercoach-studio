import 'package:flutter/material.dart';

import '../core/sync/offline_models.dart';
import '../core/sync/sync_orchestrator.dart';
import '../l10n/app_localizations.dart';

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

  static String _entityTypeLabel(AppLocalizations l10n, OfflineEntityType t) {
    switch (t) {
      case OfflineEntityType.customer:
        return 'Customer';
      case OfflineEntityType.workoutPlan:
        return 'Workout plan';
      case OfflineEntityType.measurement:
        return 'Measurement';
      case OfflineEntityType.exerciseRecord:
        return 'Exercise record';
      case OfflineEntityType.customExercise:
        return 'Custom exercise';
    }
  }

  Future<void> _showConflictDialog(PendingOperation op) async {
    _showingConflict = true;
    final l10n = AppLocalizations.of(context);
    final choice = await showDialog<ConflictResolutionChoice>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.syncConflictTitle),
        content: Text(
          l10n.syncConflictMessageWithEntity(
            _entityTypeLabel(l10n, op.entityType),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(ConflictResolutionChoice.keepRemote),
            child: Text(l10n.syncConflictUseRemote),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(ConflictResolutionChoice.keepLocal),
            child: Text(l10n.syncConflictUseLocal),
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
    final l10n = AppLocalizations.of(context);
    final status = _sync.status;
    final showBanner = status.isSyncing || status.pendingCount > 0 || status.failedCount > 0;
    final cs = Theme.of(context).colorScheme;
    final text = status.failedCount > 0
        ? l10n.syncFailed(status.failedCount)
        : status.isSyncing
            ? l10n.syncInProgress
            : status.pendingCount > 0
                ? l10n.syncPending(status.pendingCount)
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
                      child: Text(l10n.syncNow),
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
