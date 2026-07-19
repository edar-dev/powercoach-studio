import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import 'entitlement_models.dart';

/// User-facing labels for entitlement state on the subscription screen.
abstract final class EntitlementPresentation {
  static SubscriptionStatusViewModel viewModel(
    AppLocalizations l10n,
    Entitlement entitlement,
  ) {
    final locale = l10n.localeName;
    final dateFormat = DateFormat.yMMMd(locale);

    if (entitlement.status == BillingStatus.pastDue) {
      return SubscriptionStatusViewModel(
        chipLabel: l10n.subscriptionStatusPastDue,
        chipTone: SubscriptionStatusTone.warning,
        detail: l10n.subscriptionStatusPastDueDetail,
      );
    }

    if (entitlement.isPro && entitlement.status == BillingStatus.trialing) {
      return SubscriptionStatusViewModel(
        chipLabel: l10n.subscriptionStatusTrialing,
        chipTone: SubscriptionStatusTone.positive,
        detail: _formatRenewal(l10n, dateFormat, entitlement.currentPeriodEnd),
      );
    }

    if (entitlement.isPro &&
        entitlement.status == BillingStatus.canceled &&
        entitlement.proUntil != null) {
      return SubscriptionStatusViewModel(
        chipLabel: l10n.subscriptionStatusGrace,
        chipTone: SubscriptionStatusTone.neutral,
        detail: l10n.subscriptionStatusGraceUntil(
          dateFormat.format(entitlement.proUntil!.toLocal()),
        ),
      );
    }

    if (entitlement.isPro &&
        entitlement.entitlementSource == EntitlementSource.promo &&
        entitlement.status == BillingStatus.active) {
      return SubscriptionStatusViewModel(
        chipLabel: l10n.subscriptionStatusPromoActive,
        chipTone: SubscriptionStatusTone.positive,
        detail: l10n.subscriptionStatusPromoActiveDetail,
      );
    }

    if (entitlement.isPro && entitlement.status == BillingStatus.active) {
      return SubscriptionStatusViewModel(
        chipLabel: l10n.subscriptionStatusActive,
        chipTone: SubscriptionStatusTone.positive,
        detail: _formatRenewal(l10n, dateFormat, entitlement.currentPeriodEnd),
      );
    }

    if (entitlement.subscriptionPlan == BillingPlan.pro &&
        !entitlement.isPro) {
      return SubscriptionStatusViewModel(
        chipLabel: l10n.subscriptionStatusExpired,
        chipTone: SubscriptionStatusTone.neutral,
        detail: l10n.subscriptionStatusExpiredDetail,
      );
    }

    return SubscriptionStatusViewModel(
      chipLabel: l10n.subscriptionStatusFree,
      chipTone: SubscriptionStatusTone.neutral,
      detail: l10n.subscriptionStatusFreeDetail,
    );
  }

  static String? _formatRenewal(
    AppLocalizations l10n,
    DateFormat dateFormat,
    DateTime? currentPeriodEnd,
  ) {
    if (currentPeriodEnd == null) return null;
    return l10n.subscriptionStatusRenewsOn(
      dateFormat.format(currentPeriodEnd.toLocal()),
    );
  }
}

enum SubscriptionStatusTone { positive, warning, neutral }

class SubscriptionStatusViewModel {
  const SubscriptionStatusViewModel({
    required this.chipLabel,
    required this.chipTone,
    this.detail,
  });

  final String chipLabel;
  final SubscriptionStatusTone chipTone;
  final String? detail;
}
