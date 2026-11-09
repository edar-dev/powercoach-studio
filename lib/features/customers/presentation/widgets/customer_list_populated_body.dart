import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/routing/app_navigation.dart';
import 'package:powercoach_studio/core/theme/marketing_dark_colors.dart';
import 'package:powercoach_studio/core/ui/breakpoints.dart';
import 'package:powercoach_studio/core/ui/widgets/app_avatar.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

import '../../data/models/customer.dart';
import '../customer_list_filter.dart';
import 'customer_new_workout_sheet.dart';

const Color _slate200 = Color(0xFFE2E8F0);

const List<int> kCustomerListPageSizes = [10, 25];

class CustomerListPopulatedBody extends StatefulWidget {
  const CustomerListPopulatedBody({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.customers,
    required this.searchQuery,
    required this.statusFilter,
    required this.sort,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final List<Customer> customers;
  final String searchQuery;
  final CustomerListStatusFilter statusFilter;
  final CustomerListSort sort;

  @override
  State<CustomerListPopulatedBody> createState() =>
      _CustomerListPopulatedBodyState();
}

class _CustomerListPopulatedBodyState extends State<CustomerListPopulatedBody> {
  int _page = 0;
  int _pageSize = kCustomerListPageSizes.first;

  @override
  void didUpdateWidget(covariant CustomerListPopulatedBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.statusFilter != widget.statusFilter ||
        oldWidget.sort != widget.sort ||
        oldWidget.customers != widget.customers) {
      _page = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filtered = filterCustomerList(
      customers: widget.customers,
      searchQuery: widget.searchQuery,
      statusFilter: widget.statusFilter,
      sort: widget.sort,
    );

    if (filtered.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        children: [
          const SizedBox(height: 48),
          const Icon(
            Icons.search_off_rounded,
            size: 48,
            color: MarketingDarkColors.slate500,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.customersSearchEmpty,
            textAlign: TextAlign.center,
            style: const TextStyle(color: MarketingDarkColors.slate400),
          ),
        ],
      );
    }

    final pageCount = (filtered.length / _pageSize).ceil().clamp(1, 0x7fffffff);
    final page = _page.clamp(0, pageCount - 1);
    final start = page * _pageSize;
    final end = (start + _pageSize).clamp(0, filtered.length);
    final pageItems = filtered.sublist(start, end);

    final showColumnHeader = Breakpoints.isDesktop(context);
    final headerOffset = showColumnHeader ? 1 : 0;

    return ListView.separated(
      key: const PageStorageKey<String>('customer-list-scroll'),
      restorationId: 'customer-list-scroll',
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: pageItems.length + 1 + headerOffset,
      separatorBuilder: (_, index) {
        final lastDataIndex = pageItems.length - 1 + headerOffset;
        if (index >= lastDataIndex) return const SizedBox.shrink();
        return const SizedBox(height: 2);
      },
      itemBuilder: (context, index) {
        if (showColumnHeader && index == 0) {
          return const _DesktopColumnHeader();
        }
        final dataIndex = index - headerOffset;
        if (dataIndex == pageItems.length) {
          return _PaginationFooter(
            from: start + 1,
            to: end,
            filteredTotal: filtered.length,
            allTotal: widget.customers.length,
            page: page,
            pageCount: pageCount,
            pageSize: _pageSize,
            onPageSizeChanged: (size) {
              setState(() {
                _pageSize = size;
                _page = 0;
              });
            },
            onPrev: page > 0 ? () => setState(() => _page = page - 1) : null,
            onNext: page < pageCount - 1
                ? () => setState(() => _page = page + 1)
                : null,
          );
        }
        final c = pageItems[dataIndex];
        return CustomerListTile(
          customer: c,
          theme: widget.theme,
          colorScheme: widget.colorScheme,
        );
      },
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({
    required this.from,
    required this.to,
    required this.filteredTotal,
    required this.allTotal,
    required this.page,
    required this.pageCount,
    required this.pageSize,
    required this.onPageSizeChanged,
    required this.onPrev,
    required this.onNext,
  });

  final int from;
  final int to;
  final int filteredTotal;
  final int allTotal;
  final int page;
  final int pageCount;
  final int pageSize;
  final ValueChanged<int> onPageSizeChanged;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.customersShownOfTotal(filteredTotal, allTotal),
            style: theme.textTheme.bodySmall?.copyWith(
              color: MarketingDarkColors.slate400,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: MarketingDarkColors.surface900.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: MarketingDarkColors.border),
            ),
            child: Row(
              children: [
                Text(
                  l10n.customersPageSizeLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: MarketingDarkColors.slate400,
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: pageSize,
                    isDense: true,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.onSurface,
                    ),
                    dropdownColor: MarketingDarkColors.surface,
                    items: [
                      for (final size in kCustomerListPageSizes)
                        DropdownMenuItem(value: size, child: Text('$size')),
                    ],
                    onChanged: (v) {
                      if (v != null) onPageSizeChanged(v);
                    },
                  ),
                ),
                const Spacer(),
                Text(
                  l10n.customersPaginationRange(from, to, filteredTotal),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: MarketingDarkColors.slate300,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  tooltip: l10n.customersPaginationPrev,
                  icon: const Icon(Icons.chevron_left, size: 20),
                  visualDensity: VisualDensity.compact,
                  onPressed: onPrev,
                ),
                Text(
                  '${page + 1}/$pageCount',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: MarketingDarkColors.slate400,
                  ),
                ),
                IconButton(
                  tooltip: l10n.customersPaginationNext,
                  icon: const Icon(Icons.chevron_right, size: 20),
                  visualDensity: VisualDensity.compact,
                  onPressed: onNext,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopColumnHeader extends StatelessWidget {
  const _DesktopColumnHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final style = theme.textTheme.labelSmall?.copyWith(
      color: MarketingDarkColors.slate500,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 2),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(l10n.customersColumnAthlete, style: style),
          ),
          Expanded(
            flex: 2,
            child: Text(l10n.customersColumnStatus, style: style),
          ),
          Expanded(
            flex: 3,
            child: Text(l10n.customersColumnProgram, style: style),
          ),
          SizedBox(
            width: 108,
            child: Text(
              l10n.customersColumnActions,
              style: style,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerListTile extends StatelessWidget {
  const CustomerListTile({
    super.key,
    required this.customer,
    required this.theme,
    required this.colorScheme,
  });

  final Customer customer;
  final ThemeData theme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = customerListRowStatus(customer);
    final wide = Breakpoints.isDesktop(context);
    final age = customerAgeYears(customer.dateOfBirth);
    final email = customer.email?.trim();
    final subtitleParts = <String>[
      if (email != null && email.isNotEmpty) email,
      if (age != null) l10n.customersRowAgeYears(age),
    ];
    final contactLine = subtitleParts.join(' · ');
    final goals = customer.goals?.trim();
    final goalLabel =
        (goals != null && goals.isNotEmpty) ? goals : l10n.customersRowGoalEmpty;
    final planLine = _planLine(l10n, context);
    final muted = status == CustomerListRowStatus.paused;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
        onTap: () => navigateTo(context, customerPath(customer.id)),
        child: Opacity(
          opacity: muted ? 0.85 : 1,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0B1120),
              borderRadius:
                  BorderRadius.circular(MarketingDarkColors.radiusXl),
              border: Border.all(color: MarketingDarkColors.border),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: wide ? 10 : 8,
            ),
            child: wide
                ? _WideRow(
                    customer: customer,
                    status: status,
                    contactLine: contactLine,
                    goalLabel: goalLabel,
                    planLine: planLine,
                    theme: theme,
                    muted: muted,
                  )
                : _NarrowRow(
                    customer: customer,
                    status: status,
                    contactLine: contactLine,
                    goalLabel: goalLabel,
                    planLine: planLine,
                    theme: theme,
                    muted: muted,
                  ),
          ),
        ),
      ),
    );
  }

  String _planLine(AppLocalizations l10n, BuildContext context) {
    if (!customerHasAssignedPlan(customer)) {
      return l10n.customersRowNoPlan;
    }
    final raw = customer.lastPlanUpdateDate!.trim();
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return l10n.customersRowPlanUpdated(raw);
    }
    final formatted =
        MaterialLocalizations.of(context).formatCompactDate(parsed);
    return l10n.customersRowPlanUpdated(formatted);
  }
}

class _WideRow extends StatelessWidget {
  const _WideRow({
    required this.customer,
    required this.status,
    required this.contactLine,
    required this.goalLabel,
    required this.planLine,
    required this.theme,
    required this.muted,
  });

  final Customer customer;
  final CustomerListRowStatus status;
  final String contactLine;
  final String goalLabel;
  final String planLine;
  final ThemeData theme;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final hasPlan = customerHasAssignedPlan(customer);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: _AthleteCell(
            customer: customer,
            status: status,
            contactLine: contactLine,
            muted: muted,
            theme: theme,
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            goalLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: muted ? MarketingDarkColors.slate400 : _slate200,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            planLine,
            style: theme.textTheme.bodySmall?.copyWith(
              color: hasPlan
                  ? (muted
                      ? MarketingDarkColors.slate400
                      : MarketingDarkColors.slate300)
                  : MarketingDarkColors.slate500,
              fontStyle: hasPlan ? FontStyle.normal : FontStyle.italic,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _StatusPill(status: status),
        const SizedBox(width: 12),
        _QuickActions(customer: customer, status: status),
      ],
    );
  }
}

class _NarrowRow extends StatelessWidget {
  const _NarrowRow({
    required this.customer,
    required this.status,
    required this.contactLine,
    required this.goalLabel,
    required this.planLine,
    required this.theme,
    required this.muted,
  });

  final Customer customer;
  final CustomerListRowStatus status;
  final String contactLine;
  final String goalLabel;
  final String planLine;
  final ThemeData theme;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final hasPlan = customerHasAssignedPlan(customer);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _AthleteCell(
                customer: customer,
                status: status,
                contactLine: contactLine,
                muted: muted,
                theme: theme,
              ),
            ),
            const SizedBox(width: 8),
            _StatusPill(status: status),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          goalLabel,
          style: theme.textTheme.bodySmall?.copyWith(
            color: muted ? MarketingDarkColors.slate400 : _slate200,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          planLine,
          style: theme.textTheme.bodySmall?.copyWith(
            color: hasPlan
                ? (muted
                    ? MarketingDarkColors.slate400
                    : MarketingDarkColors.slate300)
                : MarketingDarkColors.slate500,
            fontStyle: hasPlan ? FontStyle.normal : FontStyle.italic,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: _QuickActions(customer: customer, status: status),
        ),
      ],
    );
  }
}

class _AthleteCell extends StatelessWidget {
  const _AthleteCell({
    required this.customer,
    required this.status,
    required this.contactLine,
    required this.muted,
    required this.theme,
  });

  final Customer customer;
  final CustomerListRowStatus status;
  final String contactLine;
  final bool muted;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final avatar = _avatarColors(customer, status);
    final dotColor = switch (status) {
      CustomerListRowStatus.active => MarketingDarkColors.emerald,
      CustomerListRowStatus.unassigned => MarketingDarkColors.cyan,
      CustomerListRowStatus.paused => MarketingDarkColors.slate500,
    };

    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            AppAvatar(
              size: 36,
              initials: customerInitials(customer.name),
              backgroundColor: avatar.$1,
              foregroundColor: avatar.$3,
              fontSize: 11,
              border: Border.all(color: avatar.$2),
              semanticLabel: customer.name,
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF0B1120),
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Tooltip(
                message: customer.name,
                child: Text(
                  customer.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: muted
                        ? MarketingDarkColors.slate300
                        : MarketingDarkColors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (contactLine.isNotEmpty)
                Text(
                  contactLine,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: muted
                        ? MarketingDarkColors.slate500
                        : MarketingDarkColors.slate400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// (bg, border, text)
  (Color, Color, Color) _avatarColors(
    Customer customer,
    CustomerListRowStatus status,
  ) {
    if (status == CustomerListRowStatus.paused) {
      return (
        MarketingDarkColors.surface700.withValues(alpha: 0.35),
        MarketingDarkColors.borderMuted.withValues(alpha: 0.6),
        MarketingDarkColors.slate400,
      );
    }
    final palette = <(Color, Color, Color)>[
      (
        MarketingDarkColors.brand.withValues(alpha: 0.2),
        MarketingDarkColors.brandMid.withValues(alpha: 0.35),
        MarketingDarkColors.brandLight,
      ),
      (
        MarketingDarkColors.cyan.withValues(alpha: 0.18),
        MarketingDarkColors.cyan.withValues(alpha: 0.35),
        MarketingDarkColors.cyan,
      ),
      (
        const Color(0xFF14B8A6).withValues(alpha: 0.18),
        const Color(0xFF14B8A6).withValues(alpha: 0.35),
        const Color(0xFF2DD4BF),
      ),
      (
        MarketingDarkColors.indigo.withValues(alpha: 0.18),
        MarketingDarkColors.indigo.withValues(alpha: 0.35),
        MarketingDarkColors.indigo,
      ),
    ];
    final i = customer.name.hashCode.abs() % palette.length;
    return palette[i];
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final CustomerListRowStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, fg, bg, border, dot) = switch (status) {
      CustomerListRowStatus.active => (
          l10n.customersRowStatusActive,
          MarketingDarkColors.emerald,
          MarketingDarkColors.emerald.withValues(alpha: 0.1),
          MarketingDarkColors.emerald.withValues(alpha: 0.2),
          MarketingDarkColors.emerald,
        ),
      CustomerListRowStatus.paused => (
          l10n.customersRowStatusPaused,
          MarketingDarkColors.slate400,
          MarketingDarkColors.surface700,
          MarketingDarkColors.borderMuted,
          MarketingDarkColors.slate500,
        ),
      CustomerListRowStatus.unassigned => (
          l10n.customersRowStatusUnassigned,
          MarketingDarkColors.cyan,
          MarketingDarkColors.cyan.withValues(alpha: 0.1),
          MarketingDarkColors.cyan.withValues(alpha: 0.2),
          MarketingDarkColors.cyan,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.customer,
    required this.status,
  });

  final Customer customer;
  final CustomerListRowStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (status) {
      CustomerListRowStatus.active => _ActionButton(
          label: l10n.customersRowActionOpenPlan,
          onPressed: () =>
              navigateTo(context, customerWorkoutsPath(customer.id)),
          emphasis: _ActionEmphasis.neutral,
        ),
      CustomerListRowStatus.unassigned => _ActionButton(
          label: l10n.customersRowActionAssign,
          onPressed: () => showCustomerNewWorkoutSheet(
            context,
            customerId: customer.id,
          ),
          emphasis: _ActionEmphasis.brandSoft,
        ),
      CustomerListRowStatus.paused => _ActionButton(
          label: l10n.customersRowActionOpen,
          onPressed: () => navigateTo(context, customerPath(customer.id)),
          emphasis: _ActionEmphasis.neutral,
        ),
    };
  }
}

enum _ActionEmphasis { neutral, brandSoft }

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onPressed,
    required this.emphasis,
  });

  final String label;
  final VoidCallback onPressed;
  final _ActionEmphasis emphasis;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (emphasis) {
      _ActionEmphasis.neutral => (
          MarketingDarkColors.surface700,
          _slate200,
          Colors.transparent,
        ),
      _ActionEmphasis.brandSoft => (
          MarketingDarkColors.brand.withValues(alpha: 0.2),
          MarketingDarkColors.brandSoft,
          MarketingDarkColors.brandMid.withValues(alpha: 0.3),
        ),
    };

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: border),
        ),
        textStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      child: Text(label),
    );
  }
}
