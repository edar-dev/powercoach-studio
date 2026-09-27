import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/theme/marketing_dark_colors.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

class CustomerCreationGoalChips extends StatelessWidget {
  const CustomerCreationGoalChips({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int? selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final goals = [
      (
        Icons.fitness_center_outlined,
        l10n.customerGoalHypertrophy,
        l10n.customerGoalHypertrophySubtitle,
      ),
      (
        Icons.bolt_outlined,
        l10n.customerGoalStrength,
        l10n.customerGoalStrengthSubtitle,
      ),
      (
        Icons.balance_outlined,
        l10n.customerGoalRecomp,
        l10n.customerGoalRecompSubtitle,
      ),
      (
        Icons.directions_run_outlined,
        l10n.customerGoalAthletic,
        l10n.customerGoalAthleticSubtitle,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 480 ? 4 : 2;
        final gap = 10.0;
        final width = (constraints.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < goals.length; i++)
              SizedBox(
                width: width,
                child: _GoalChip(
                  icon: goals[i].$1,
                  title: goals[i].$2,
                  subtitle: goals[i].$3,
                  selected: selectedIndex == i,
                  onTap: () => onSelected(i),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _GoalChip extends StatelessWidget {
  const _GoalChip({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? MarketingDarkColors.brand.withValues(alpha: 0.12)
                : MarketingDarkColors.surfaceInput.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
            border: Border.all(
              color: selected
                  ? MarketingDarkColors.brandMid
                  : MarketingDarkColors.borderSubtle,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected
                    ? MarketingDarkColors.brandLight
                    : MarketingDarkColors.slate400,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? MarketingDarkColors.text
                      : MarketingDarkColors.slate300,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  color: MarketingDarkColors.slate400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
