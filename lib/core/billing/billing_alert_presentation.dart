import '../../l10n/app_localizations.dart';
import 'entitlement_models.dart';

enum BillingAlertTone { warning, info }

class BillingAlertViewModel {
  const BillingAlertViewModel({
    required this.message,
    required this.actionLabel,
    required this.tone,
  });

  final String message;
  final String actionLabel;
  final BillingAlertTone tone;
}

abstract final class BillingAlertPresentation {
  static BillingAlertViewModel? forEntitlement(
    AppLocalizations l10n,
    Entitlement? entitlement,
  ) {
    if (entitlement == null) return null;

    if (entitlement.status == BillingStatus.pastDue) {
      return BillingAlertViewModel(
        message: l10n.billingAlertPastDue,
        actionLabel: l10n.billingAlertUpdatePayment,
        tone: BillingAlertTone.warning,
      );
    }

    if (entitlement.isPro &&
        entitlement.status == BillingStatus.canceled &&
        entitlement.proUntil != null) {
      final daysLeft = entitlement.proUntil!
          .toUtc()
          .difference(DateTime.now().toUtc())
          .inDays;
      if (daysLeft >= 0 && daysLeft <= 7) {
        return BillingAlertViewModel(
          message: l10n.billingAlertGraceEnding(daysLeft),
          actionLabel: l10n.billingAlertManageSubscription,
          tone: BillingAlertTone.info,
        );
      }
    }

    return null;
  }
}
