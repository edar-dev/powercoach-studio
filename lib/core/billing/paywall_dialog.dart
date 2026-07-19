import 'package:flutter/material.dart';
import 'package:powercoach_studio/core/routing/app_navigation.dart';

import '../../l10n/app_localizations.dart';
import 'plan_limits.dart';

enum PaywallFeature {
  customers,
  exportProgress,
  hevy,
  workoutExport,
}

Future<void> showPaywallDialog(
  BuildContext context, {
  required PaywallFeature feature,
  int? activeCustomerCount,
}) {
  final l10n = AppLocalizations.of(context);
  final message = switch (feature) {
    PaywallFeature.customers => _customersMessage(
        l10n,
        activeCustomerCount: activeCustomerCount,
      ),
    PaywallFeature.exportProgress => l10n.paywallMessageExport,
    PaywallFeature.hevy => l10n.paywallMessageHevy,
    PaywallFeature.workoutExport => l10n.paywallMessageWorkoutExport,
  };

  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(l10n.paywallTitle),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.paywallNotNow),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              navigateToSubscription(context);
            },
            child: Text(l10n.paywallUpgradeCta),
          ),
        ],
      );
    },
  );
}

String _customersMessage(
  AppLocalizations l10n, {
  int? activeCustomerCount,
}) {
  final max = PlanLimits.maxActiveCustomers;
  if (activeCustomerCount != null && activeCustomerCount >= max) {
    return l10n.paywallMessageCustomersAtLimit(activeCustomerCount, max);
  }
  if (activeCustomerCount != null && activeCustomerCount >= max - 1) {
    return l10n.paywallMessageCustomersNearLimit(activeCustomerCount, max);
  }
  return l10n.paywallMessageCustomers(max);
}
