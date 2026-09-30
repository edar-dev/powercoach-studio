import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../core/billing/billing_checkout.dart';
import '../../../../../core/billing/entitlement_models.dart';
import '../../../../../core/theme/marketing_dark_colors.dart';
import '../../../../../l10n/app_localizations.dart';

class SubscriptionProActionsCard extends StatelessWidget {
  const SubscriptionProActionsCard({
    super.key,
    required this.entitlement,
    required this.busy,
    required this.onPortalOpened,
  });

  final Entitlement entitlement;
  final bool busy;
  final Future<void> Function(PortalFlow flow) onPortalOpened;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final showSwitchToYearly =
        entitlement.billingInterval == BillingInterval.monthly;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MarketingDarkColors.stitchCardElevated,
        borderRadius: BorderRadius.circular(MarketingDarkColors.radius2xl),
        border: Border.all(color: MarketingDarkColors.stitchBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.subscriptionProActionsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.credit_card_outlined,
            label: l10n.subscriptionProActionPaymentMethod,
            onTap: busy ? null : () => onPortalOpened(PortalFlow.paymentMethod),
          ),
          if (showSwitchToYearly)
            _ActionTile(
              icon: Icons.calendar_month_outlined,
              label: l10n.subscriptionProActionSwitchYearly,
              subtitle: l10n.subscriptionProActionSwitchYearlyHint,
              onTap: busy
                  ? null
                  : () => onPortalOpened(PortalFlow.subscriptionUpdate),
            )
          else if (entitlement.billingInterval == BillingInterval.yearly)
            _ActionTile(
              icon: Icons.calendar_month_outlined,
              label: l10n.subscriptionProActionSwitchMonthly,
              onTap: busy
                  ? null
                  : () => onPortalOpened(PortalFlow.subscriptionUpdate),
            ),
          _ActionTile(
            icon: Icons.receipt_long_outlined,
            label: l10n.subscriptionProActionInvoices,
            onTap: busy ? null : () => onPortalOpened(PortalFlow.defaultFlow),
          ),
          _ActionTile(
            icon: Icons.cancel_outlined,
            label: l10n.subscriptionProActionCancel,
            destructive: true,
            onTap: busy
                ? null
                : () => onPortalOpened(PortalFlow.subscriptionCancel),
          ),
          if (!kIsWeb) ...[
            const SizedBox(height: 8),
            Text(
              l10n.subscriptionWebOnlyHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: MarketingDarkColors.slate400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = destructive ? cs.error : MarketingDarkColors.slate300;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: MarketingDarkColors.slate500,
                  ),
            ),
      trailing: const Icon(
        Icons.open_in_new,
        color: MarketingDarkColors.slate500,
        size: 18,
      ),
      onTap: onTap,
    );
  }
}
