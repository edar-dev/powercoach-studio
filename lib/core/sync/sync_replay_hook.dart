/// Optional hook invoked after a pending op is queued for retry.
///
/// Today the app is local-only; a future [SyncOrchestrator] can register here
/// to replay the outbox when connectivity returns.
abstract class SyncReplayHook {
  Future<void> requestReplay();
}

class NoOpSyncReplayHook implements SyncReplayHook {
  const NoOpSyncReplayHook();

  static const SyncReplayHook instance = NoOpSyncReplayHook();

  @override
  Future<void> requestReplay() async {}
}

/// Global replay hook. Replace in DI/bootstrap when remote sync ships.
SyncReplayHook syncReplayHook = NoOpSyncReplayHook.instance;
