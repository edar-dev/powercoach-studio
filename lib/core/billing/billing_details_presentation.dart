import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import 'entitlement_models.dart';

abstract final class BillingDetailsPresentation {
  static String? intervalLabel(
    AppLocalizations l10n,
    Entitlement entitlement,
  ) {
    return switch (entitlement.billingInterval) {
      BillingInterval.monthly => l10n.subscriptionBillingIntervalMonthly,
      BillingInterval.yearly => l10n.subscriptionBillingIntervalYearly,
      null => null,
    };
  }

  static String? priceLabel(AppLocalizations l10n, Entitlement entitlement) {
    final cents = entitlement.priceAmountCents;
    if (cents == null) return null;

    final currency = (entitlement.currency ?? 'eur').toUpperCase();
    final amount = cents / 100;
    final formatted = NumberFormat.simpleCurrency(name: currency).format(amount);

    return switch (entitlement.billingInterval) {
      BillingInterval.monthly => l10n.subscriptionBillingPriceMonthly(formatted),
      BillingInterval.yearly => l10n.subscriptionBillingPriceYearly(formatted),
      null => formatted,
    };
  }
}
