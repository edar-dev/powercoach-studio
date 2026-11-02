import 'package:flutter/material.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// Slim-hub page header for the Clienti list (H1 + subtitle + new-customer CTA).
///
/// Owns the single Clienti H1 on wide layouts — [StitchAppBar] omits its title
/// so the heading is not duplicated.
class CustomerListPageHeader extends StatelessWidget {
  const CustomerListPageHeader({super.key, required this.onNewCustomer});

  final VoidCallback onNewCustomer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 640;
        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.customersTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: MarketingDarkColors.text,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.customersSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: MarketingDarkColors.slate400,
              ),
            ),
          ],
        );
        final actions = FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: MarketingDarkColors.cyanBright,
            foregroundColor: MarketingDarkColors.cyanOn,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
          ),
          onPressed: onNewCustomer,
          icon: const Icon(Icons.add, size: 16),
          label: Text(l10n.customersNewCustomer),
        );
        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              titleBlock,
              const SizedBox(height: 16),
              Align(alignment: Alignment.centerLeft, child: actions),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: titleBlock),
            const SizedBox(width: 16),
            actions,
          ],
        );
      },
    );
  }
}
