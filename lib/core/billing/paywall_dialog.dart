import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
}) {
  final l10n = AppLocalizations.of(context);
  final message = switch (feature) {
    PaywallFeature.customers => l10n.paywallMessageCustomers(PlanLimits.maxActiveCustomers),
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
              context.push('/settings/subscription');
            },
            child: Text(l10n.paywallUpgradeCta),
          ),
        ],
      );
    },
  );
}
