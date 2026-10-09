import 'package:flutter/material.dart';

import '../../../../core/ui/breakpoints.dart';
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
    final stacked = !Breakpoints.isTabletOrWider(context);

    final copy = Column(
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
    );

    final cta = FilledButton(
      onPressed: onAssignToCustomer,
      child: Text(l10n.workoutBuilderAssignToCustomer),
    );

    return Material(
      color: cs.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: stacked
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.cloud_off_outlined,
                        color: cs.onSecondaryContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: copy),
                    ],
                  ),
                  const SizedBox(height: 12),
                  cta,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.cloud_off_outlined,
                    color: cs.onSecondaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: copy),
                  const SizedBox(width: 12),
                  cta,
                ],
              ),
      ),
    );
  }
}
