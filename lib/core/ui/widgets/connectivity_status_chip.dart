import 'dart:async';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../platform/web_online_status.dart';

/// Discreet offline chip. Hidden while online to avoid stealing chrome.
///
/// Uses [isNavigatorOnline] (stub always true on non-web; navigator.onLine on
/// web). Polls periodically and refreshes on app resume.
class ConnectivityStatusChip extends StatefulWidget {
  const ConnectivityStatusChip({
    super.key,
    this.pollInterval = const Duration(seconds: 8),
    this.dense = true,
    this.isOnlineOverride,
  });

  final Duration pollInterval;
  final bool dense;

  /// Test injection — when non-null, skips [isNavigatorOnline].
  final bool Function()? isOnlineOverride;

  @override
  State<ConnectivityStatusChip> createState() => _ConnectivityStatusChipState();
}

class _ConnectivityStatusChipState extends State<ConnectivityStatusChip>
    with WidgetsBindingObserver {
  bool _online = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
    _timer = Timer.periodic(widget.pollInterval, (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  void _refresh() {
    final online = widget.isOnlineOverride?.call() ?? isNavigatorOnline();
    if (!mounted) return;
    if (online != _online) {
      setState(() => _online = online);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_online) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final label = l10n.connectivityOffline;
    final pad = widget.dense
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 6);

    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        child: Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Material(
            color: cs.errorContainer.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: pad,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_off_outlined,
                    size: widget.dense ? 14 : 16,
                    color: cs.onErrorContainer,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onErrorContainer,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
