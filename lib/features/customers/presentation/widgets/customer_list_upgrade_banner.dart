import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/billing/entitlement_repository.dart';
import 'package:powercoach_studio/core/billing/plan_limits.dart';
import 'package:powercoach_studio/core/billing/plan_usage.dart';
import 'package:powercoach_studio/core/routing/app_paths.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

import '../../../../l10n/app_localizations.dart';

class CustomerListUpgradeBanner extends StatelessWidget {
  const CustomerListUpgradeBanner({
    super.key,
    required this.activeCustomerCount,
  });

  final int activeCustomerCount;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: EntitlementRepository.instance.entitlement,
      builder: (context, entitlement, _) {
        if (entitlement?.isPro ?? false) return const SizedBox.shrink();

        final usage = PlanUsage();
        if (!usage.isNearCustomerLimit(activeCustomerCount)) {
          return const SizedBox.shrink();
        }

        final l10n = AppLocalizations.of(context);
        final cs = Theme.of(context).colorScheme;
        final atLimit = usage.isAtCustomerLimit(activeCustomerCount);
        final message = atLimit
            ? l10n.customerListUpgradeAtLimit(
                activeCustomerCount,
                PlanLimits.maxActiveCustomers,
              )
            : l10n.customerListUpgradeNearLimit(
                activeCustomerCount,
                PlanLimits.maxActiveCustomers,
              );

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Material(
            color: atLimit ? cs.errorContainer : cs.primaryContainer,
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
            child: InkWell(
              borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
              onTap: () => context.push(AppPaths.subscription),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: atLimit
                                  ? cs.onErrorContainer
                                  : cs.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: atLimit
                          ? cs.onErrorContainer
                          : cs.onPrimaryContainer,
                    ),
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
