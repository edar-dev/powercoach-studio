import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/theme/stitch_mobile_colors.dart';
import '../../../../core/ui/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';

/// Notifications toggles module for the settings hub.
class SettingsNotificationsModule extends StatelessWidget {
  const SettingsNotificationsModule({
    super.key,
    required this.notificationsEnabled,
    required this.calendarRemindersEnabled,
    required this.calendarReminderLeadHours,
    required this.onNotificationsToggle,
    required this.onCalendarRemindersToggle,
    required this.onPickCalendarLeadHours,
  });

  final bool notificationsEnabled;
  final bool calendarRemindersEnabled;
  final int calendarReminderLeadHours;
  final ValueChanged<bool> onNotificationsToggle;
  final ValueChanged<bool> onCalendarRemindersToggle;
  final VoidCallback onPickCalendarLeadHours;

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
            l10n.settingsNotificationsModuleTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: StitchMobileColors.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: StitchMobileColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(StitchMobileColors.radiusLg),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.settingsSessionRemindersTitle,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: StitchMobileColors.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.settingsSessionRemindersSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: StitchMobileColors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: calendarRemindersEnabled && notificationsEnabled,
                  onChanged: kIsWeb
                      ? null
                      : (value) async {
                          if (value && !notificationsEnabled) {
                            onNotificationsToggle(true);
                          }
                          onCalendarRemindersToggle(value);
                        },
                  activeThumbColor: StitchMobileColors.onPrimaryContainer,
                  activeTrackColor: StitchMobileColors.primaryContainer,
                ),
              ],
            ),
          ),
          if (calendarRemindersEnabled && notificationsEnabled) ...[
            const SizedBox(height: 10),
            Material(
              color: StitchMobileColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(StitchMobileColors.radiusLg),
              child: InkWell(
                onTap: kIsWeb ? null : onPickCalendarLeadHours,
                borderRadius: BorderRadius.circular(StitchMobileColors.radiusLg),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.settingsCalendarReminderLeadHours(
                            calendarReminderLeadHours,
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: StitchMobileColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: StitchMobileColors.outline,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
                Icons.info_outline,
                size: 20,
                color: MarketingDarkColors.brandMid,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.settingsNotificationsModuleTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.settingsNotificationsDescription,
            style: theme.textTheme.bodySmall?.copyWith(
              color: MarketingDarkColors.slate400,
            ),
          ),
          const SizedBox(height: 16),
          _ToggleRow(
            title: l10n.settingsNotifications,
            subtitle: l10n.settingsNotificationsDescription,
            value: notificationsEnabled,
            onChanged: kIsWeb ? null : onNotificationsToggle,
          ),
          const SizedBox(height: 10),
          _ToggleRow(
            title: l10n.settingsCalendarRemindersTitle,
            subtitle: l10n.settingsCalendarRemindersSubtitle,
            value: calendarRemindersEnabled,
            onChanged: kIsWeb || !notificationsEnabled
                ? null
                : onCalendarRemindersToggle,
          ),
          if (calendarRemindersEnabled) ...[
            const SizedBox(height: 10),
            Material(
              color: MarketingDarkColors.stitchInput.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
              child: InkWell(
                onTap: kIsWeb ? null : onPickCalendarLeadHours,
                borderRadius:
                    BorderRadius.circular(MarketingDarkColors.radiusXl),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.settingsCalendarReminderLead,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: MarketingDarkColors.slate300,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.settingsCalendarReminderLeadHours(
                                calendarReminderLeadHours,
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: MarketingDarkColors.slate400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: MarketingDarkColors.slate500,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: MarketingDarkColors.stitchInput.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
        border: Border.all(color: MarketingDarkColors.stitchBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: MarketingDarkColors.slate300,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: MarketingDarkColors.slate400,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: MarketingDarkColors.brand,
          ),
        ],
      ),
    );
  }
}
