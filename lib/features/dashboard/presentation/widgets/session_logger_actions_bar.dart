import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

/// Sticky bottom actions for the session detail logger chrome.
class SessionLoggerActionsBar extends StatelessWidget {
  const SessionLoggerActionsBar({
    super.key,
    required this.onSkip,
    required this.onLog,
    required this.onComplete,
    this.busy = false,
  });

  final VoidCallback onSkip;
  final VoidCallback onLog;
  final VoidCallback onComplete;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Material(
      elevation: 8,
      color: cs.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: busy
                      ? null
                      : () {
                          HapticFeedback.selectionClick();
                          onSkip();
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.error,
                    side: BorderSide(color: cs.error.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
                    ),
                  ),
                  child: Text(l10n.sessionLoggerSkipAction),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: busy
                      ? null
                      : () {
                          HapticFeedback.selectionClick();
                          onLog();
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.onSurface,
                    side: BorderSide(color: cs.outline.withValues(alpha: 0.6)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
                    ),
                  ),
                  child: Text(l10n.sessionLoggerLogAction),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: busy
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          onComplete();
                        },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
                    ),
                  ),
                  child: Text(l10n.sessionLoggerCompleteAction),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
