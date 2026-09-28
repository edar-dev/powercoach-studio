import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../l10n/app_localizations.dart';

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
