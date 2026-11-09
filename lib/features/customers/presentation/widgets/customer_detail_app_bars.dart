import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:powercoach_studio/core/routing/app_navigation.dart';
import '../../../../core/routing/app_paths.dart';
import 'package:powercoach_studio/core/theme/marketing_dark_colors.dart';
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
    return AppBar(
      backgroundColor: MarketingDarkColors.bgAlt,
      foregroundColor: MarketingDarkColors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: MarketingDarkColors.slate300,
        onPressed: () {
          HapticFeedback.mediumImpact();
          navigateBack(context, fallback: AppPaths.customers);
        },
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: MarketingDarkColors.text,
        ),
      ),
      centerTitle: false,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: ColoredBox(
          color: MarketingDarkColors.border,
          child: SizedBox(height: 1, width: double.infinity),
        ),
      ),
    );
  }
}

/// Slim tabbed app bar for the loaded customer detail screen.
class CustomerDetailLoadedAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CustomerDetailLoadedAppBar({
    super.key,
    required this.l10n,
    required this.tabController,
    required this.customer,
    required this.unreadNotesCount,
    required this.onOpenNotes,
    required this.onEdit,
    required this.onDelete,
  });

  final AppLocalizations l10n;
  final TabController tabController;
  final Customer customer;
  final int unreadNotesCount;
  final VoidCallback onOpenNotes;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 48);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: MarketingDarkColors.bgAlt,
      foregroundColor: MarketingDarkColors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: MarketingDarkColors.slate300,
        onPressed: () {
          HapticFeedback.mediumImpact();
          navigateBack(context, fallback: AppPaths.customers);
        },
      ),
      title: Text(
        customer.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: MarketingDarkColors.text,
        ),
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Column(
          children: [
            TabBar(
              controller: tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 10),
              labelColor: MarketingDarkColors.brandLight,
              unselectedLabelColor: MarketingDarkColors.slate400,
              indicatorColor: MarketingDarkColors.brandMid,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: MarketingDarkColors.border,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(text: l10n.customerDetailOverview),
                Tab(text: l10n.customerDetailMeasurements),
                Tab(text: l10n.customerTabWorkouts),
                Tab(text: l10n.customerTabNotes),
                Tab(text: l10n.customerTabMaximals),
              ],
            ),
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
            onEdit: onEdit,
            onDelete: onDelete,
          ),
          icon: const Icon(Icons.more_vert),
          color: MarketingDarkColors.slate300,
        ),
      ],
    );
  }
}
