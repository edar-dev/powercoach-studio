import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/billing/billing_alert_presentation.dart';
import 'package:powercoach_studio/core/billing/entitlement_repository.dart';
import 'package:powercoach_studio/core/routing/app_paths.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

import '../../l10n/app_localizations.dart';

/// In-app banner for billing issues (past due, grace ending).
class BillingAlertBanner extends StatelessWidget {
  const BillingAlertBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: EntitlementRepository.instance.entitlement,
      builder: (context, entitlement, _) {
        final l10n = AppLocalizations.of(context);
        final alert = BillingAlertPresentation.forEntitlement(l10n, entitlement);
        if (alert == null) return const SizedBox.shrink();

        final cs = Theme.of(context).colorScheme;
        final isWarning = alert.tone == BillingAlertTone.warning;
        final background = isWarning ? cs.errorContainer : cs.primaryContainer;
        final foreground =
            isWarning ? cs.onErrorContainer : cs.onPrimaryContainer;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: background,
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
            child: InkWell(
              borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
              onTap: () => context.push(AppPaths.subscription),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isWarning ? Icons.warning_amber_rounded : Icons.info_outline,
                      color: foreground,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.message,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: foreground,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            alert.actionLabel,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: foreground,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: foreground),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
