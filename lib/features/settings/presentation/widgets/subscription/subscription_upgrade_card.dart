import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../core/billing/entitlement_models.dart';
import '../../../../../core/theme/stitch_m3_theme.dart';
import '../../../../../l10n/app_localizations.dart';

/// Stripe checkout actions for Free users on web.
class SubscriptionUpgradeCard extends StatelessWidget {
  const SubscriptionUpgradeCard({
    super.key,
    required this.busy,
    required this.onCheckoutStarted,
  });

  final bool busy;
  final Future<void> Function(BillingInterval interval) onCheckoutStarted;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.subscriptionUpgrade,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: busy
                  ? null
                  : () => onCheckoutStarted(BillingInterval.monthly),
              child: Text(l10n.subscriptionUpgradeMonthly),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: busy
                  ? null
                  : () => onCheckoutStarted(BillingInterval.yearly),
              child: Text(l10n.subscriptionUpgradeYearly),
            ),
          ],
        ),
      ),
    );
  }
}
