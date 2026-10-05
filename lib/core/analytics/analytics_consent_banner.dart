import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/legal_urls.dart';
import '../platform/open_external_url.dart';
import '../../l10n/app_localizations.dart';
import 'posthog_bootstrap.dart';

/// Lightweight EU consent banner for web product analytics + session replay.
///
/// Shown only when `POSTHOG_API_KEY` is configured and consent is undecided.
/// Off-web / unconfigured builds render [child] only.
class AnalyticsConsentBannerHost extends StatefulWidget {
  const AnalyticsConsentBannerHost({super.key, required this.child});

  final Widget child;

  @override
  State<AnalyticsConsentBannerHost> createState() =>
      _AnalyticsConsentBannerHostState();
}

class _AnalyticsConsentBannerHostState
    extends State<AnalyticsConsentBannerHost> {
  bool _ready = false;
  bool _visible = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _syncVisibility();
  }

  Future<void> _syncVisibility() async {
    if (!kIsWeb || !PostHogBootstrap.isConfigured) {
      if (mounted) {
        setState(() {
          _ready = true;
          _visible = false;
        });
      }
      return;
    }
    await PostHogBootstrap.loadConsent();
    if (!mounted) return;
    setState(() {
      _ready = true;
      _visible = PostHogBootstrap.needsConsentBanner;
    });
  }

  Future<void> _accept() async {
    if (_busy) return;
    setState(() => _busy = true);
    await PostHogBootstrap.acceptConsent();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _visible = false;
    });
  }

  Future<void> _decline() async {
    if (_busy) return;
    setState(() => _busy = true);
    await PostHogBootstrap.declineConsent();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _visible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready || !_visible) {
      return widget.child;
    }

    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        widget.child,
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Material(
            elevation: 8,
            color: cs.surfaceContainerHigh,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.analyticsConsentTitle,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.analyticsConsentBody,
                      style: textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: _busy
                            ? null
                            : () => openExternalUrl(LegalUrls.privacyPolicy),
                        child: Text(l10n.analyticsConsentPrivacyLink),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        TextButton(
                          onPressed: _busy ? null : _decline,
                          child: Text(l10n.analyticsConsentDecline),
                        ),
                        FilledButton(
                          onPressed: _busy ? null : _accept,
                          child: Text(l10n.analyticsConsentAccept),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
