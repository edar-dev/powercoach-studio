import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Banner shown in standalone (non-customer) workout builder mode.
class WorkoutBuilderSandboxBanner extends StatelessWidget {
  const WorkoutBuilderSandboxBanner({
    super.key,
    required this.onAssignToCustomer,
  });

  final VoidCallback onAssignToCustomer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: cs.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.cloud_off_outlined, color: cs.onSecondaryContainer, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.workoutBuilderSandboxBanner,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.workoutBuilderSandboxBannerHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: onAssignToCustomer,
              style: TextButton.styleFrom(
                foregroundColor: cs.onSecondaryContainer,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text(l10n.workoutBuilderAssignToCustomer),
            ),
          ],
        ),
      ),
    );
  }
}
