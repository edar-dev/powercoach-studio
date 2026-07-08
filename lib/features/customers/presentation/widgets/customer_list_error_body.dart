import 'package:flutter/material.dart';

import 'package:powercoach_studio/l10n/app_localizations.dart';

class CustomerListErrorBody extends StatelessWidget {
  const CustomerListErrorBody({
    super.key,
    required this.l10n,
    required this.theme,
    required this.colorScheme,
    required this.error,
    required this.onRetry,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  l10n.customersLoadError,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    error!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: onRetry,
                  child: Text(l10n.customersRetry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
