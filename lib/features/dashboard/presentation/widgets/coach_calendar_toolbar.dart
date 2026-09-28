import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/theme/stitch_mobile_colors.dart';
import '../../../../core/ui/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../customers/data/models/customer.dart';

/// Stitch-styled toolbar for the coach calendar (month nav + actions).
class CoachCalendarToolbar extends StatelessWidget {
  const CoachCalendarToolbar({
    super.key,
    required this.monthLabel,
    required this.onBack,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onToday,
    required this.onAddSession,
    this.customers = const [],
    this.filterCustomerId,
    this.onFilterCustomer,
  });

  final String monthLabel;
  final VoidCallback onBack;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onToday;
  final VoidCallback onAddSession;
  final List<Customer> customers;
  final String? filterCustomerId;
  final ValueChanged<String?>? onFilterCustomer;

  @override
  Widget build(BuildContext context) {
    if (!Breakpoints.isTabletOrWider(context)) {
      return _PhoneToolbar(
        monthLabel: monthLabel,
        onPreviousMonth: onPreviousMonth,
        onNextMonth: onNextMonth,
        onToday: onToday,
        customers: customers,
        filterCustomerId: filterCustomerId,
        onFilterCustomer: onFilterCustomer,
      );
    }
    return _DesktopToolbar(
      monthLabel: monthLabel,
      onBack: onBack,
      onPreviousMonth: onPreviousMonth,
      onNextMonth: onNextMonth,
      onToday: onToday,
      onAddSession: onAddSession,
    );
  }
}

/// Compact phone header: title + primaryContainer CTA (outside toolbar card).
class CoachCalendarPhoneHeader extends StatelessWidget {
  const CoachCalendarPhoneHeader({
    super.key,
    required this.onAddSession,
  });

  final VoidCallback onAddSession;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.calendarTitle,
            style: const TextStyle(
              color: StitchMobileColors.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Material(
          color: StitchMobileColors.primaryContainer,
          borderRadius: BorderRadius.circular(StitchMobileColors.radiusLg),
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onAddSession();
            },
            borderRadius: BorderRadius.circular(StitchMobileColors.radiusLg),
            child: Container(
              height: 40,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                l10n.calendarAddSessionShort,
                style: const TextStyle(
                  color: StitchMobileColors.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhoneToolbar extends StatelessWidget {
  const _PhoneToolbar({
    required this.monthLabel,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onToday,
    required this.customers,
    required this.filterCustomerId,
    required this.onFilterCustomer,
  });

  final String monthLabel;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onToday;
  final List<Customer> customers;
  final String? filterCustomerId;
  final ValueChanged<String?>? onFilterCustomer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: StitchMobileColors.surfaceContainer,
        borderRadius: BorderRadius.circular(StitchMobileColors.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    _PhoneIconBtn(
                      label: '‹',
                      onTap: onPreviousMonth,
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          monthLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: StitchMobileColors.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    _PhoneIconBtn(
                      label: '›',
                      onTap: onNextMonth,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Material(
                color: StitchMobileColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
                child: InkWell(
                  onTap: onToday,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    child: Text(
                      l10n.calendarToday.toUpperCase(),
                      style: const TextStyle(
                        color: StitchMobileColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: StitchMobileColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(StitchMobileColors.radiusLg),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PhoneViewChip(
                      label: l10n.calendarViewMonthShort,
                      selected: true,
                      enabled: true,
                    ),
                    _PhoneViewChip(
                      label: l10n.calendarViewWeekShort,
                      selected: false,
                      enabled: false,
                    ),
                    _PhoneViewChip(
                      label: l10n.calendarViewDayShort,
                      selected: false,
                      enabled: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (customers.isNotEmpty && onFilterCustomer != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _AthleteChip(
                    label: l10n.calendarFilterAllAthletes,
                    selected: filterCustomerId == null,
                    onTap: () => onFilterCustomer!(null),
                  ),
                  const SizedBox(width: 4),
                  for (final customer in customers) ...[
                    _AthleteChip(
                      label: _shortName(customer.name),
                      selected: filterCustomerId == customer.id,
                      onTap: () => onFilterCustomer!(customer.id),
                    ),
                    const SizedBox(width: 4),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _shortName(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return name;
    if (parts.length == 1) return parts.first;
    final last = parts.last;
    final initial = last.isEmpty ? '' : '${last[0]}.';
    return '${parts.first} $initial';
  }
}

class _PhoneIconBtn extends StatelessWidget {
  const _PhoneIconBtn({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: StitchMobileColors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(StitchMobileColors.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(StitchMobileColors.radiusLg),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: StitchMobileColors.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhoneViewChip extends StatelessWidget {
  const _PhoneViewChip({
    required this.label,
    required this.selected,
    required this.enabled,
  });

  final String label;
  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: selected
            ? StitchMobileColors.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected
              ? StitchMobileColors.onPrimary
              : StitchMobileColors.onSurfaceVariant,
          fontSize: 11,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
    if (!enabled) {
      return Opacity(opacity: 0.55, child: child);
    }
    return child;
  }
}

class _AthleteChip extends StatelessWidget {
  const _AthleteChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? StitchMobileColors.secondaryContainer
          : StitchMobileColors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? StitchMobileColors.onSurface
                  : StitchMobileColors.onSurfaceVariant,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopToolbar extends StatelessWidget {
  const _DesktopToolbar({
    required this.monthLabel,
    required this.onBack,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onToday,
    required this.onAddSession,
  });

  final String monthLabel;
  final VoidCallback onBack;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onToday;
  final VoidCallback onAddSession;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MarketingDarkColors.surfaceElevated,
        borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
        border: Border.all(color: MarketingDarkColors.stitchBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 720;
          final nav = Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _IconBtn(
                icon: Icons.arrow_back,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onBack();
                },
              ),
              Container(
                width: 1,
                height: 20,
                color: MarketingDarkColors.stitchBorder,
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: MarketingDarkColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: MarketingDarkColors.stitchBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _IconBtn(
                      icon: Icons.chevron_left,
                      compact: true,
                      onTap: onPreviousMonth,
                    ),
                    SizedBox(
                      width: 130,
                      child: Text(
                        monthLabel,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: MarketingDarkColors.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _IconBtn(
                      icon: Icons.chevron_right,
                      compact: true,
                      onTap: onNextMonth,
                    ),
                  ],
                ),
              ),
              _OutlineBtn(label: l10n.calendarToday, onTap: onToday),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: MarketingDarkColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: MarketingDarkColors.stitchBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ViewModeChip(
                      label: l10n.calendarViewMonth,
                      selected: true,
                      enabled: true,
                      onTap: () {},
                    ),
                    _ViewModeChip(
                      label: l10n.calendarViewWeek,
                      selected: false,
                      enabled: false,
                      onTap: () {},
                    ),
                    _ViewModeChip(
                      label: l10n.calendarViewDay,
                      selected: false,
                      enabled: false,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          );

          final actions = FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: MarketingDarkColors.brand,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
            ),
            onPressed: onAddSession,
            icon: const Icon(Icons.add, size: 16),
            label: Text(l10n.calendarAddSession),
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                nav,
                const SizedBox(height: 12),
                actions,
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: nav),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.compact = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: compact ? Colors.transparent : MarketingDarkColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(compact ? 4 : 8),
          decoration: compact
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: MarketingDarkColors.stitchBorder),
                ),
          child: Icon(icon, size: 16, color: MarketingDarkColors.slate300),
        ),
      ),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  const _OutlineBtn({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MarketingDarkColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: MarketingDarkColors.stitchBorder),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: MarketingDarkColors.slate300,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _ViewModeChip extends StatelessWidget {
  const _ViewModeChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? MarketingDarkColors.brand : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: selected
              ? Colors.white
              : enabled
              ? MarketingDarkColors.slate400
              : MarketingDarkColors.slate500.withValues(alpha: 0.5),
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
    if (!enabled) {
      return Opacity(opacity: 0.55, child: child);
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: child,
    );
  }
}
