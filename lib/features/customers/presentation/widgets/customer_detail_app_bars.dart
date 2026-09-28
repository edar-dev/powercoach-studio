import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:powercoach_studio/core/routing/app_navigation.dart';
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
          navigateBack(context, fallback: '/customers');
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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 52);

  String get _shortId {
    final id = customer.id.trim();
    if (id.isEmpty) return '';
    final short = id.length <= 8 ? id : id.substring(0, 8);
    return short.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = !customer.isArchived;
    final shortId = _shortId;

    return AppBar(
      backgroundColor: MarketingDarkColors.bgAlt,
      foregroundColor: MarketingDarkColors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 140,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: TextButton.icon(
          onPressed: () {
            HapticFeedback.mediumImpact();
            navigateBack(context, fallback: '/customers');
          },
          icon: const Icon(Icons.arrow_back, size: 16),
          label: Text(
            l10n.customerBackToList,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          style: TextButton.styleFrom(
            foregroundColor: MarketingDarkColors.slate300,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            visualDensity: VisualDensity.compact,
          ),
        ),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              l10n.customerDetailTitle,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: MarketingDarkColors.text,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isActive
                  ? MarketingDarkColors.emeraldBg
                  : MarketingDarkColors.surface700,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isActive
                    ? MarketingDarkColors.emeraldBorder
                    : MarketingDarkColors.borderMuted,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? MarketingDarkColors.emerald
                        : MarketingDarkColors.slate500,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isActive
                      ? l10n.customersRowStatusActive
                      : l10n.customersRowStatusPaused,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? MarketingDarkColors.emerald
                        : MarketingDarkColors.slate400,
                  ),
                ),
              ],
            ),
          ),
          if (shortId.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              l10n.customerIdChip(shortId),
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: MarketingDarkColors.slate500,
              ),
            ),
          ],
        ],
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Column(
          children: [
            TabBar(
              controller: tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: MarketingDarkColors.text,
              unselectedLabelColor: MarketingDarkColors.slate400,
              indicatorColor: MarketingDarkColors.brandMid,
              indicatorWeight: 2.5,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(text: l10n.customerDetailOverview),
                Tab(text: l10n.customerDetailMeasurements),
                Tab(text: l10n.customerTabWorkouts),
              ],
            ),
            const ColoredBox(
              color: MarketingDarkColors.border,
              child: SizedBox(height: 1, width: double.infinity),
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
