import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/routing/app_navigation.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

import '../../data/models/customer.dart';
import '../customer_list_filter.dart';

class CustomerListPopulatedBody extends StatelessWidget {
  const CustomerListPopulatedBody({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.customers,
    required this.searchQuery,
    required this.filterChipIndex,
    required this.onSearchChanged,
    required this.onFilterChipSelected,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final List<Customer> customers;
  final String searchQuery;
  final int filterChipIndex;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<int> onFilterChipSelected;

  @override
  Widget build(BuildContext context) {
    final filtered = filterCustomerList(
      customers: customers,
      searchQuery: searchQuery,
      filterChipIndex: filterChipIndex,
    );

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search clients by name or goal',
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                prefixIcon: Icon(
                  Icons.search,
                  color: colorScheme.onSurfaceVariant,
                  size: 22,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: customerListFilterChips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selected = i == filterChipIndex;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onFilterChipSelected(i),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? StitchM3Theme.accent
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        customerListFilterChips[i],
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: selected
                              ? Colors.white
                              : colorScheme.onSurface,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index.isOdd) return const SizedBox(height: 12);
                final itemIndex = index ~/ 2;
                final c = filtered[itemIndex];
                return CustomerListTile(
                  customer: c,
                  theme: theme,
                  colorScheme: colorScheme,
                  showBottomSpacing: itemIndex < filtered.length - 1,
                );
              },
              childCount: filtered.isEmpty ? 0 : filtered.length * 2 - 1,
            ),
          ),
        ),
      ],
    );
  }
}

class CustomerListTile extends StatelessWidget {
  const CustomerListTile({
    super.key,
    required this.customer,
    required this.theme,
    required this.colorScheme,
    required this.showBottomSpacing,
  });

  final Customer customer;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final bool showBottomSpacing;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (customer.email != null && customer.email!.isNotEmpty) customer.email!,
      if (customer.phone != null && customer.phone!.isNotEmpty) customer.phone!,
    ].join(' · ');
    final goalLabel = customer.goals ?? '';

    return Padding(
      padding: EdgeInsets.only(bottom: showBottomSpacing ? 12 : 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        onTap: () => navigateTo(context, '/customers/${customer.id}'),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
            border: Border.all(color: colorScheme.outline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (goalLabel.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          goalLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: StitchM3Theme.accent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
