import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Compact Material-style error banner with optional detail and retry CTA.
///
/// Prefer this over a full-screen error-only layout when the page chrome
/// should remain visible.
class InlineErrorBanner extends StatelessWidget {
  const InlineErrorBanner({
    super.key,
    required this.message,
    required this.onRetry,
    this.detail,
    this.retryLabel,
    this.margin = const EdgeInsets.all(16),
    this.filledRetry = true,
  });

  final String message;
  final String? detail;
  final VoidCallback onRetry;
  final String? retryLabel;
  final EdgeInsetsGeometry margin;

  /// When false, uses [TextButton] instead of [FilledButton].
  final bool filledRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final label = retryLabel ?? l10n.customersRetry;

    return Padding(
      padding: margin,
      child: Semantics(
        liveRegion: true,
        child: Material(
          color: cs.errorContainer,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: cs.onErrorContainer,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onErrorContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (detail != null && detail!.trim().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              detail!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onErrorContainer,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: filledRetry
                      ? FilledButton(
                          onPressed: onRetry,
                          style: FilledButton.styleFrom(
                            backgroundColor: cs.error,
                            foregroundColor: cs.onError,
                            minimumSize: const Size(0, 40),
                          ),
                          child: Text(label),
                        )
                      : TextButton(
                          onPressed: onRetry,
                          style: TextButton.styleFrom(
                            foregroundColor: cs.onErrorContainer,
                            minimumSize: const Size(0, 40),
                          ),
                          child: Text(label),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
