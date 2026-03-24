import 'package:flutter/foundation.dart';

import 'offline_models.dart';

class SyncStatusController extends ChangeNotifier {
  bool _isSyncing = false;
  int _pendingCount = 0;
  int _failedCount = 0;
  List<PendingOperation> _conflicts = const <PendingOperation>[];

  bool get isSyncing => _isSyncing;
  int get pendingCount => _pendingCount;
  int get failedCount => _failedCount;
  List<PendingOperation> get conflicts => _conflicts;

  bool get hasConflicts => _conflicts.isNotEmpty;
  bool get hasPendingWork => _pendingCount > 0 || _isSyncing;

  void update({
    required bool isSyncing,
    required int pendingCount,
    required int failedCount,
    required List<PendingOperation> conflicts,
  }) {
    _isSyncing = isSyncing;
    _pendingCount = pendingCount;
    _failedCount = failedCount;
    _conflicts = conflicts;
    notifyListeners();
  }
}
