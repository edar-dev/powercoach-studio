import 'package:flutter/material.dart';
import 'package:powercoach_studio/core/billing/entitlement_models.dart';
import 'package:powercoach_studio/core/billing/entitlement_presentation.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

import '../../../../../l10n/app_localizations.dart';

class SubscriptionStatusCard extends StatelessWidget {
  const SubscriptionStatusCard({
    super.key,
    required this.entitlement,
    required this.planLabel,
  });

  final Entitlement entitlement;
  final String planLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final status = EntitlementPresentation.viewModel(l10n, entitlement);

    return Card(
      elevation: 0,
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        side: BorderSide(color: cs.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.subscriptionCurrentPlan,
              style: theme.textTheme.labelLarge?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              planLabel,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _StatusChip(label: status.chipLabel, tone: status.chipTone),
            if (status.detail != null) ...[
              const SizedBox(height: 12),
              Text(
                status.detail!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.tone});

  final String label;
  final SubscriptionStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (background, foreground) = switch (tone) {
      SubscriptionStatusTone.positive => (
          cs.primaryContainer,
          cs.onPrimaryContainer,
        ),
      SubscriptionStatusTone.warning => (
          cs.errorContainer,
          cs.onErrorContainer,
        ),
      SubscriptionStatusTone.neutral => (
          cs.surfaceContainerHighest,
          cs.onSurfaceVariant,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
