import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/billing/billing_details_presentation.dart';
import '../../../../../core/billing/entitlement_models.dart';
import '../../../../../core/theme/marketing_dark_colors.dart';
import '../../../../../l10n/app_localizations.dart';

class SubscriptionBillingDetailsCard extends StatelessWidget {
  const SubscriptionBillingDetailsCard({
    super.key,
    required this.entitlement,
  });

  final Entitlement entitlement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final interval = BillingDetailsPresentation.intervalLabel(l10n, entitlement);
    final price = BillingDetailsPresentation.priceLabel(l10n, entitlement);
    final renewal = entitlement.currentPeriodEnd == null
        ? null
        : l10n.subscriptionStatusRenewsOn(
            DateFormat.yMMMd(l10n.localeName)
                .format(entitlement.currentPeriodEnd!.toLocal()),
          );

    if (interval == null && price == null && renewal == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MarketingDarkColors.stitchCardElevated,
        borderRadius: BorderRadius.circular(MarketingDarkColors.radius2xl),
        border: Border.all(color: MarketingDarkColors.stitchBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.subscriptionBillingDetailsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (interval != null) ...[
            const SizedBox(height: 12),
            _DetailRow(
              label: l10n.subscriptionBillingCycleLabel,
              value: interval,
            ),
          ],
          if (price != null) ...[
            const SizedBox(height: 8),
            _DetailRow(
              label: l10n.subscriptionBillingAmountLabel,
              value: price,
            ),
          ],
          if (renewal != null) ...[
            const SizedBox(height: 8),
            _DetailRow(
              label: l10n.subscriptionBillingRenewalLabel,
              value: renewal,
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: MarketingDarkColors.slate400,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
