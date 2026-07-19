import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Persistent hint until a customer plan is saved for the first time.
class WorkoutBuilderFirstSaveBanner extends StatelessWidget {
  const WorkoutBuilderFirstSaveBanner({
    super.key,
    required this.onSave,
  });

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: cs.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: cs.onTertiaryContainer, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.workoutBuilderSaveToPersistHint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onTertiaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: onSave,
              style: TextButton.styleFrom(
                foregroundColor: cs.onTertiaryContainer,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text(l10n.workoutBuilderSaveNowAction),
            ),
          ],
        ),
      ),
    );
  }
}
