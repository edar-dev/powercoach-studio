import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class ExerciseAddSheetLoadingView extends StatelessWidget {
  const ExerciseAddSheetLoadingView({super.key, required this.onCancel});

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onCancel, child: Text(l10n.customerCancel)),
      ],
    );
  }
}

class ExerciseAddSheetLoadErrorView extends StatelessWidget {
  const ExerciseAddSheetLoadErrorView({
    super.key,
    required this.onRetry,
    required this.onCreateNew,
  });

  final VoidCallback onRetry;
  final VoidCallback onCreateNew;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Icon(Icons.cloud_off_outlined, size: 40, color: cs.onSurfaceVariant),
        const SizedBox(height: 12),
        Text(
          l10n.workoutBuilderExerciseLoadError,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(l10n.workoutBuilderExerciseRetry),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: onCreateNew,
          child: Text(l10n.workoutBuilderCreateNew),
        ),
      ],
    );
  }
}
