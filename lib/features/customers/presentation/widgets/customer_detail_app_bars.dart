import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:powercoach_studio/core/routing/app_navigation.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

import '../../data/models/customer.dart';
import 'customer_detail_actions_sheet.dart';

/// App bar for loading and error states on the customer detail screen.
class CustomerDetailFallbackAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CustomerDetailFallbackAppBar({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          HapticFeedback.mediumImpact();
          navigateBack(context, fallback: '/customers');
        },
      ),
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        ),
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: cs.outline, height: 1),
      ),
    );
  }
}

/// Tabbed app bar for the loaded customer detail screen.
class CustomerDetailLoadedAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CustomerDetailLoadedAppBar({
    super.key,
    required this.l10n,
    required this.tabController,
    required this.customer,
    required this.unreadNotesCount,
    required this.onOpenNotes,
    required this.onOpenReminder,
    required this.onEdit,
    required this.onDelete,
  });

  final AppLocalizations l10n;
  final TabController tabController;
  final Customer customer;
  final int unreadNotesCount;
  final VoidCallback onOpenNotes;
  final VoidCallback onOpenReminder;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 48);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          HapticFeedback.mediumImpact();
          navigateBack(context, fallback: '/customers');
        },
      ),
      title: Text(
        l10n.customerDetailTitle,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Column(
          children: [
            TabBar(
              controller: tabController,
              tabs: [
                Tab(text: l10n.customerDetailOverview),
                Tab(text: l10n.customerDetailMeasurements),
                Tab(text: l10n.customerDetailRecords),
              ],
            ),
            Container(color: colorScheme.outline, height: 1),
          ],
        ),
      ),
      actions: [
        IconButton(
          tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
          onPressed: () => showCustomerDetailActionsSheet(
            context: context,
            l10n: l10n,
            customer: customer,
            unreadNotesCount: unreadNotesCount,
            onOpenNotes: onOpenNotes,
            onOpenReminder: onOpenReminder,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }
}
