import 'package:flutter/material.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/theme/stitch_mobile_colors.dart';
import '../../../../core/ui/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/user_preferences_repository.dart';

/// Workout-builder preferences module for the settings hub (rounding, etc.).
class SettingsWorkoutPrefsModule extends StatelessWidget {
  const SettingsWorkoutPrefsModule({
    super.key,
    required this.maximalWeightRoundingKg,
    required this.onRoundingChanged,
  });

  final double maximalWeightRoundingKg;
  final ValueChanged<double> onRoundingChanged;

  @override
  Widget build(BuildContext context) {
    final phone = !Breakpoints.isTabletOrWider(context);
    return phone ? _buildPhone(context) : _buildDesktop(context);
  }

  Widget _buildPhone(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StitchMobileColors.surfaceContainer,
        borderRadius: BorderRadius.circular(StitchMobileColors.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.settingsWorkoutPrefsModuleTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: StitchMobileColors.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.settingsMaximalWeightRoundingTitle,
            style: theme.textTheme.labelLarge?.copyWith(
              color: StitchMobileColors.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.settingsMaximalWeightRoundingSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: StitchMobileColors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          _RoundingSegmentedControl(
            selected: maximalWeightRoundingKg,
            onChanged: onRoundingChanged,
            phone: true,
            localeCode: Localizations.localeOf(context).languageCode,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MarketingDarkColors.stitchCard,
        borderRadius: BorderRadius.circular(MarketingDarkColors.radius2xl),
        border: Border.all(
          color: MarketingDarkColors.stitchBorderMuted.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.fitness_center_outlined,
                size: 20,
                color: MarketingDarkColors.brandMid,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.settingsWorkoutPrefsModuleTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.settingsMaximalWeightRoundingTitle,
            style: theme.textTheme.labelLarge?.copyWith(
              color: MarketingDarkColors.slate300,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.settingsMaximalWeightRoundingSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: MarketingDarkColors.slate400,
            ),
          ),
          const SizedBox(height: 12),
          _RoundingSegmentedControl(
            selected: maximalWeightRoundingKg,
            onChanged: onRoundingChanged,
            phone: false,
            localeCode: Localizations.localeOf(context).languageCode,
          ),
        ],
      ),
    );
  }
}

class _RoundingSegmentedControl extends StatelessWidget {
  const _RoundingSegmentedControl({
    required this.selected,
    required this.onChanged,
    required this.phone,
    required this.localeCode,
  });

  final double selected;
  final ValueChanged<double> onChanged;
  final bool phone;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final normalized = normalizeMaximalWeightRoundingKg(selected);

    return SegmentedButton<double>(
      segments: [
        for (final kg in kAllowedMaximalWeightRoundingIncrements)
          ButtonSegment<double>(
            value: kg,
            label: Text(
              l10n.settingsMaximalWeightRoundingOptionKg(
                _formatKgLabel(kg, localeCode),
              ),
            ),
          ),
      ],
      selected: {normalized},
      onSelectionChanged: (selection) {
        if (selection.isEmpty) return;
        onChanged(selection.first);
      },
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: phone
            ? StitchMobileColors.primaryContainer
            : MarketingDarkColors.brand,
        selectedForegroundColor:
            phone ? StitchMobileColors.onPrimaryContainer : Colors.white,
        foregroundColor: phone
            ? StitchMobileColors.onSurfaceVariant
            : MarketingDarkColors.slate300,
        backgroundColor: phone
            ? StitchMobileColors.surfaceContainerLow
            : MarketingDarkColors.stitchInput.withValues(alpha: 0.6),
        side: BorderSide(
          color: phone
              ? StitchMobileColors.outline.withValues(alpha: 0.4)
              : MarketingDarkColors.stitchBorder,
        ),
        textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      showSelectedIcon: false,
    );
  }

  /// Locale-friendly label (`0,5` IT / `0.5` EN; whole kilos without decimals).
  static String _formatKgLabel(double kg, String localeCode) {
    if (kg == kg.roundToDouble()) {
      return kg.toInt().toString();
    }
    final raw = kg.toString();
    if (localeCode == 'it') {
      return raw.replaceAll('.', ',');
    }
    return raw;
  }
}
