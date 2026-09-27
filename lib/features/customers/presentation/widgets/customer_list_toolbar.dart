import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/routing/app_navigation.dart';
import 'package:powercoach_studio/core/theme/marketing_dark_colors.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

import '../../data/models/customer.dart';
import '../customer_list_filter.dart';

/// Search + status chips + sort + New customer CTA (Stitch control bar).
class CustomerListToolbar extends StatelessWidget {
  const CustomerListToolbar({
    super.key,
    required this.customers,
    required this.searchQuery,
    required this.statusFilter,
    required this.sort,
    required this.onSearchChanged,
    required this.onStatusFilterSelected,
    required this.onSortChanged,
  });

  final List<Customer> customers;
  final String searchQuery;
  final CustomerListStatusFilter statusFilter;
  final CustomerListSort sort;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<CustomerListStatusFilter> onStatusFilterSelected;
  final ValueChanged<CustomerListSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: MarketingDarkColors.bgAlt,
        border: Border(
          bottom: BorderSide(color: MarketingDarkColors.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  onChanged: onSearchChanged,
                  style: const TextStyle(
                    color: MarketingDarkColors.text,
                    fontSize: 13,
                  ),
                  cursorColor: MarketingDarkColors.brandLight,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: l10n.customersSearchHint,
                    hintStyle: const TextStyle(
                      color: MarketingDarkColors.slate500,
                      fontSize: 12,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: MarketingDarkColors.slate500,
                      size: 18,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    filled: true,
                    fillColor: MarketingDarkColors.surface900.withValues(
                      alpha: 0.9,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: MarketingDarkColors.border,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: MarketingDarkColors.border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: MarketingDarkColors.brandMid,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => navigateTo(context, '/customers/new'),
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.customersNewCustomer),
                style: FilledButton.styleFrom(
                  backgroundColor: MarketingDarkColors.brand,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  elevation: 4,
                  shadowColor: MarketingDarkColors.brand.withValues(alpha: 0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: MarketingDarkColors.surface900,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: MarketingDarkColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final f in customerListStatusFilters)
                        _StatusChip(
                          label: _labelFor(l10n, f),
                          count: countForStatusFilter(customers, f),
                          selected: statusFilter == f,
                          onTap: () => onStatusFilterSelected(f),
                        ),
                    ],
                  ),
                ),
              ),
              _SortControl(
                sort: sort,
                onSortChanged: onSortChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _labelFor(AppLocalizations l10n, CustomerListStatusFilter f) {
    return switch (f) {
      CustomerListStatusFilter.all => l10n.customersFilterAll,
      CustomerListStatusFilter.active => l10n.customersFilterActive,
      CustomerListStatusFilter.paused => l10n.customersFilterPaused,
      CustomerListStatusFilter.unassigned => l10n.customersFilterUnassigned,
    };
  }
}

class _SortControl extends StatelessWidget {
  const _SortControl({
    required this.sort,
    required this.onSortChanged,
  });

  final CustomerListSort sort;
  final ValueChanged<CustomerListSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = switch (sort) {
      CustomerListSort.recent => l10n.customersSortRecent,
      CustomerListSort.nameAsc => l10n.customersSortNameAsc,
    };

    return PopupMenuButton<CustomerListSort>(
      onSelected: onSortChanged,
      color: MarketingDarkColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: MarketingDarkColors.border),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: CustomerListSort.recent,
          child: Text(
            l10n.customersSortRecent,
            style: TextStyle(
              color: sort == CustomerListSort.recent
                  ? MarketingDarkColors.text
                  : MarketingDarkColors.slate300,
              fontWeight: sort == CustomerListSort.recent
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          ),
        ),
        PopupMenuItem(
          value: CustomerListSort.nameAsc,
          child: Text(
            l10n.customersSortNameAsc,
            style: TextStyle(
              color: sort == CustomerListSort.nameAsc
                  ? MarketingDarkColors.text
                  : MarketingDarkColors.slate300,
              fontWeight: sort == CustomerListSort.nameAsc
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: MarketingDarkColors.surface900,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: MarketingDarkColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 12,
                  color: MarketingDarkColors.slate300,
                ),
                children: [
                  TextSpan(text: '${l10n.customersSortPrefix} '),
                  TextSpan(
                    text: label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: MarketingDarkColors.text,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: MarketingDarkColors.slate400,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? MarketingDarkColors.surface700 : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected
                      ? MarketingDarkColors.text
                      : MarketingDarkColors.slate400,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                l10n.customersFilterCount(count),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: selected
                      ? MarketingDarkColors.slate300
                      : MarketingDarkColors.slate500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
