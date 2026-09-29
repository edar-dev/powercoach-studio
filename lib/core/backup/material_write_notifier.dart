/// Decouples material write sites from [CloudSnapshotScheduler] to avoid
/// circular imports between storage and backup layers.
class MaterialWriteNotifier {
  MaterialWriteNotifier._();

  static void Function()? _listener;

  /// When true, [notify] is a no-op (bulk restore / merge).
  static bool suppress = false;

  /// Registers the callback invoked after material local writes.
  static void setListener(void Function()? listener) {
    _listener = listener;
  }

  /// Notifies that a material local write completed (no-op if suppressed/unset).
  static void notify() {
    if (suppress) return;
    _listener?.call();
  }

  /// Runs [action] with [suppress] true so writes do not schedule snapshots.
  static Future<T> runSuppressed<T>(Future<T> Function() action) async {
    final previous = suppress;
    suppress = true;
    try {
      return await action();
    } finally {
      suppress = previous;
    }
  }
}
