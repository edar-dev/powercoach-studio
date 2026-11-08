import 'dart:async';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../platform/network_reachability.dart';

/// Discreet offline chip. Hidden while online to avoid stealing chrome.
///
/// Web uses [navigator.onLine]; native probes DNS via [probeNetworkReachability]
/// (no new dependency). Polls periodically and refreshes on app resume.
class ConnectivityStatusChip extends StatefulWidget {
  const ConnectivityStatusChip({
    super.key,
    this.pollInterval = const Duration(seconds: 8),
    this.dense = true,
    this.isOnlineOverride,
  });

  final Duration pollInterval;
  final bool dense;

  /// Test injection — when non-null, skips network probe.
  final bool Function()? isOnlineOverride;

  @override
  State<ConnectivityStatusChip> createState() => _ConnectivityStatusChipState();
}

class _ConnectivityStatusChipState extends State<ConnectivityStatusChip>
    with WidgetsBindingObserver {
  bool _online = true;
  Timer? _timer;
  int _refreshToken = 0;

  static const bool _inFlutterTest =
      bool.fromEnvironment('FLUTTER_TEST');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_refresh());
    // Skip periodic polling under widget tests — FakeTimers would leak.
    if (!_inFlutterTest) {
      _timer = Timer.periodic(widget.pollInterval, (_) {
        unawaited(_refresh());
      });
    }
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
      unawaited(_refresh());
    }
  }

  Future<void> _refresh() async {
    final token = ++_refreshToken;
    final bool online;
    if (widget.isOnlineOverride != null) {
      online = widget.isOnlineOverride!();
    } else if (_inFlutterTest) {
      // Avoid InternetAddress.lookup / orphan Timers in widget tests.
      online = true;
    } else {
      online = await probeNetworkReachability();
    }
    if (!mounted || token != _refreshToken) return;
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
