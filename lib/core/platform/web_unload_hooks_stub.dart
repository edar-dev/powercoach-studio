/// Registers a best-effort page-unload callback. No-op off web.
void registerWebUnloadHook(void Function() onUnload) {}

/// Removes a previously registered unload hook. No-op off web.
void unregisterWebUnloadHook(void Function() onUnload) {}
