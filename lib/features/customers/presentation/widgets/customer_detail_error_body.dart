import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:powercoach_studio/l10n/app_localizations.dart';

class CustomerDetailErrorBody extends StatelessWidget {
  const CustomerDetailErrorBody({
    super.key,
    required this.l10n,
    required this.errorMessage,
  });

  final AppLocalizations l10n;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? l10n.customersLoadError,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.pop(),
              child: Text(l10n.customerCancel),
            ),
          ],
        ),
      ),
    );
  }
}
