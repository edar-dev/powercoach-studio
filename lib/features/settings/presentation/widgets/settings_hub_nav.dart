import 'package:flutter/material.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../l10n/app_localizations.dart';

enum SettingsHubSection {
  personalInfo,
  subscription,
  notifications,
  backup,
  language,
  privacy,
  terms,
}

/// Sidebar / chip navigation for the settings hub.
class SettingsHubNav extends StatelessWidget {
  const SettingsHubNav({
    super.key,
    required this.active,
    required this.languageTrailing,
    required this.onSelect,
    this.horizontal = false,
  });

  final SettingsHubSection active;
  final String languageTrailing;
  final ValueChanged<SettingsHubSection> onSelect;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = <_NavItem>[
      _NavItem(
        section: SettingsHubSection.personalInfo,
        label: l10n.settingsNavPersonalInfo,
        icon: Icons.person_outline,
      ),
      _NavItem(
        section: SettingsHubSection.subscription,
        label: l10n.settingsNavSubscription,
        icon: Icons.credit_card_outlined,
        badge: l10n.settingsProBadge,
      ),
      _NavItem(
        section: SettingsHubSection.notifications,
        label: l10n.settingsNavNotifications,
        icon: Icons.notifications_outlined,
      ),
      _NavItem(
        section: SettingsHubSection.backup,
        label: l10n.settingsNavBackup,
        icon: Icons.cloud_outlined,
      ),
      _NavItem(
        section: SettingsHubSection.language,
        label: l10n.settingsNavLanguage,
        icon: Icons.language,
        trailingText: languageTrailing,
      ),
    ];
    final legal = <_NavItem>[
      _NavItem(
        section: SettingsHubSection.privacy,
        label: l10n.settingsNavPrivacy,
        icon: Icons.privacy_tip_outlined,
        muted: true,
        external: true,
      ),
      _NavItem(
        section: SettingsHubSection.terms,
        label: l10n.settingsNavTerms,
        icon: Icons.description_outlined,
        muted: true,
        external: true,
      ),
    ];

    if (horizontal) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final item in [...items, ...legal]) ...[
              _ChipNavButton(
                item: item,
                selected: active == item.section,
                onTap: () => onSelect(item.section),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
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
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _SidebarNavButton(
                item: item,
                selected: active == item.section,
                onTap: () => onSelect(item.section),
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: MarketingDarkColors.stitchBorder),
          ),
          for (final item in legal)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _SidebarNavButton(
                item: item,
                selected: false,
                onTap: () => onSelect(item.section),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.section,
    required this.label,
    required this.icon,
    this.badge,
    this.trailingText,
    this.muted = false,
    this.external = false,
  });

  final SettingsHubSection section;
  final String label;
  final IconData icon;
  final String? badge;
  final String? trailingText;
  final bool muted;
  final bool external;
}

class _SidebarNavButton extends StatelessWidget {
  const _SidebarNavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = selected
        ? Colors.white
        : item.muted
            ? MarketingDarkColors.slate400
            : MarketingDarkColors.slate300;
    final iconColor = selected
        ? Colors.white
        : item.muted
            ? MarketingDarkColors.slate500
            : MarketingDarkColors.slate400;

    return Material(
      color: selected ? MarketingDarkColors.brand : Colors.transparent,
      borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: selected ? 12 : 10,
          ),
          child: Row(
            children: [
              Icon(item.icon, size: 20, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: fg,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (item.badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: MarketingDarkColors.stitchBorder,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: MarketingDarkColors.stitchBorderMuted),
                  ),
                  child: Text(
                    item.badge!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: MarketingDarkColors.brandLight,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else if (item.trailingText != null)
                Text(
                  item.trailingText!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: MarketingDarkColors.slate400,
                  ),
                )
              else
                Icon(
                  item.external ? Icons.open_in_new : Icons.chevron_right,
                  size: 16,
                  color: selected
                      ? Colors.white.withValues(alpha: 0.75)
                      : MarketingDarkColors.slate500,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipNavButton extends StatelessWidget {
  const _ChipNavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? MarketingDarkColors.brand
          : MarketingDarkColors.stitchCard,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? MarketingDarkColors.brand
                  : MarketingDarkColors.stitchBorderMuted,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                size: 16,
                color: selected ? Colors.white : MarketingDarkColors.slate400,
              ),
              const SizedBox(width: 8),
              Text(
                item.label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: selected ? Colors.white : MarketingDarkColors.slate300,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (item.badge != null) ...[
                const SizedBox(width: 6),
                Text(
                  item.badge!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: selected
                        ? Colors.white70
                        : MarketingDarkColors.brandLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
