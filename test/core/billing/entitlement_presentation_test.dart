import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:powercoach_studio/core/billing/entitlement_models.dart';
import 'package:powercoach_studio/core/billing/entitlement_presentation.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('it');
  });

  Future<AppLocalizations> loadL10n() async {
    return lookupAppLocalizations(const Locale('it'));
  }

  group('EntitlementPresentation', () {
    test('active pro shows renewal detail when period end exists', () async {
      final l10n = await loadL10n();
      final entitlement = Entitlement(
        plan: BillingPlan.pro,
        subscriptionPlan: BillingPlan.pro,
        status: BillingStatus.active,
        currentPeriodEnd: DateTime.utc(2026, 8, 1),
      );

      final viewModel = EntitlementPresentation.viewModel(l10n, entitlement);

      expect(viewModel.chipLabel, l10n.subscriptionStatusActive);
      expect(viewModel.detail, contains('2026'));
    });

    test('grace period shows end date', () async {
      final l10n = await loadL10n();
      final entitlement = Entitlement(
        plan: BillingPlan.pro,
        subscriptionPlan: BillingPlan.pro,
        status: BillingStatus.canceled,
        proUntil: DateTime.utc(2026, 7, 23),
      );

      final viewModel = EntitlementPresentation.viewModel(l10n, entitlement);

      expect(viewModel.chipLabel, l10n.subscriptionStatusGrace);
      expect(viewModel.detail, isNotNull);
    });

    test('promo pro shows invite status', () async {
      final l10n = await loadL10n();
      final entitlement = Entitlement(
        plan: BillingPlan.pro,
        subscriptionPlan: BillingPlan.pro,
        status: BillingStatus.active,
        entitlementSource: EntitlementSource.promo,
      );

      final viewModel = EntitlementPresentation.viewModel(l10n, entitlement);

      expect(viewModel.chipLabel, l10n.subscriptionStatusPromoActive);
      expect(viewModel.detail, l10n.subscriptionStatusPromoActiveDetail);
    });

    test('past due uses warning status', () async {
      final l10n = await loadL10n();
      final entitlement = Entitlement(
        plan: BillingPlan.pro,
        subscriptionPlan: BillingPlan.pro,
        status: BillingStatus.pastDue,
      );

      final viewModel = EntitlementPresentation.viewModel(l10n, entitlement);

      expect(viewModel.chipLabel, l10n.subscriptionStatusPastDue);
      expect(viewModel.chipTone, SubscriptionStatusTone.warning);
    });
  });
}
