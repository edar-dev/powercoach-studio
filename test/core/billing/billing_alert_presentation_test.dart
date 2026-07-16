import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:powercoach_studio/core/billing/billing_alert_presentation.dart';
import 'package:powercoach_studio/core/billing/entitlement_models.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('it');
  });

  Future<AppLocalizations> loadL10n() async {
    return lookupAppLocalizations(const Locale('it'));
  }

  group('BillingAlertPresentation', () {
    test('returns warning for past due subscriptions', () async {
      final l10n = await loadL10n();
      final alert = BillingAlertPresentation.forEntitlement(
        l10n,
        const Entitlement(
          plan: BillingPlan.pro,
          subscriptionPlan: BillingPlan.pro,
          status: BillingStatus.pastDue,
        ),
      );

      expect(alert?.tone, BillingAlertTone.warning);
      expect(alert?.message, l10n.billingAlertPastDue);
    });

    test('returns info banner during grace period ending soon', () async {
      final l10n = await loadL10n();
      final alert = BillingAlertPresentation.forEntitlement(
        l10n,
        Entitlement(
          plan: BillingPlan.pro,
          subscriptionPlan: BillingPlan.pro,
          status: BillingStatus.canceled,
          proUntil: DateTime.now().toUtc().add(const Duration(days: 3)),
        ),
      );

      expect(alert, isNotNull);
      expect(alert!.tone, BillingAlertTone.info);
      expect(alert.actionLabel, l10n.billingAlertManageSubscription);
    });
  });
}
