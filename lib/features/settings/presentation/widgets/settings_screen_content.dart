import 'package:flutter/material.dart';

import '../../../../core/locale/app_locale_controller.dart';
import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/theme/stitch_mobile_colors.dart';
import '../../../../core/ui/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import '../backup_onboarding_dialog.dart';
import 'settings_backup_module.dart';
import 'settings_hub_nav.dart';
import 'settings_notifications_module.dart';
import 'settings_personal_form_card.dart';
import 'settings_unsaved_bar.dart';

/// Stitch dark settings hub body (sidebar + personal / notifications / backup).
class SettingsScreenContent extends StatelessWidget {
  const SettingsScreenContent({
    super.key,
    required this.l10n,
    required this.scrollController,
    required this.personalKey,
    required this.notificationsKey,
    required this.backupKey,
    required this.activeSection,
    required this.onSectionSelected,
    required this.formKey,
    required this.displayNameController,
    required this.emailController,
    required this.phoneController,
    required this.bioController,
    required this.avatarUrlController,
    required this.websiteController,
    required this.emailVerified,
    required this.profileLoadError,
    required this.notificationsEnabled,
    required this.calendarRemindersEnabled,
    required this.calendarReminderLeadHours,
    required this.onNotificationsToggle,
    required this.onCalendarRemindersToggle,
    required this.onPickCalendarLeadHours,
    required this.onExportBackup,
    required this.onImportBackup,
    required this.onUploadCloudBackup,
    required this.onRestoreCloudBackup,
    required this.onSignOut,
    required this.isDirty,
    required this.isSaving,
    required this.onCancelChanges,
    required this.onSaveProfile,
    this.subscriptionPlanIsPro = false,
  });

  final AppLocalizations l10n;
  final ScrollController scrollController;
  final GlobalKey personalKey;
  final GlobalKey notificationsKey;
  final GlobalKey backupKey;
  final SettingsHubSection activeSection;
  final ValueChanged<SettingsHubSection> onSectionSelected;
  final GlobalKey<FormState> formKey;
  final TextEditingController displayNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController bioController;
  final TextEditingController avatarUrlController;
  final TextEditingController websiteController;
  final bool emailVerified;
  final String? profileLoadError;
  final bool notificationsEnabled;
  final bool calendarRemindersEnabled;
  final int calendarReminderLeadHours;
  final ValueChanged<bool> onNotificationsToggle;
  final ValueChanged<bool> onCalendarRemindersToggle;
  final VoidCallback onPickCalendarLeadHours;
  final VoidCallback onExportBackup;
  final VoidCallback onImportBackup;
  final VoidCallback onUploadCloudBackup;
  final VoidCallback onRestoreCloudBackup;
  final VoidCallback onSignOut;
  final bool isDirty;
  final bool isSaving;
  final VoidCallback onCancelChanges;
  final VoidCallback onSaveProfile;
  final bool subscriptionPlanIsPro;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final desktop = Breakpoints.isDesktop(context);
    final phone = !Breakpoints.isTabletOrWider(context);
    final languageTrailing =
        AppLocaleController.instance.locale.languageCode.toUpperCase();

    final header = _SettingsHubHeader(l10n: l10n, phone: phone);
    final nav = SettingsHubNav(
      active: activeSection,
      languageTrailing: languageTrailing,
      onSelect: onSectionSelected,
      horizontal: !desktop,
    );
    final edge = phone ? 16.0 : 24.0;
    final bottomPad = isDirty ? (phone ? 120.0 : 88.0) : (phone ? 32.0 : 24.0);

    final mainColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KeyedSubtree(
          key: personalKey,
          child: SettingsPersonalFormCard(
            formKey: formKey,
            displayNameController: displayNameController,
            emailController: emailController,
            phoneController: phoneController,
            bioController: bioController,
            avatarUrlController: avatarUrlController,
            websiteController: websiteController,
            emailVerified: emailVerified,
            loadError: profileLoadError,
          ),
        ),
        SizedBox(height: phone ? 16 : 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final sideBySide = !phone && constraints.maxWidth >= 720;
            final notifications = KeyedSubtree(
              key: notificationsKey,
              child: SettingsNotificationsModule(
                notificationsEnabled: notificationsEnabled,
                calendarRemindersEnabled: calendarRemindersEnabled,
                calendarReminderLeadHours: calendarReminderLeadHours,
                onNotificationsToggle: onNotificationsToggle,
                onCalendarRemindersToggle: onCalendarRemindersToggle,
                onPickCalendarLeadHours: onPickCalendarLeadHours,
              ),
            );
            final backup = KeyedSubtree(
              key: backupKey,
              child: SettingsBackupModule(
                onExportBackup: onExportBackup,
                onImportBackup: onImportBackup,
                onUploadCloudBackup: onUploadCloudBackup,
                onRestoreCloudBackup: onRestoreCloudBackup,
              ),
            );
            if (!sideBySide) {
              return Column(
                children: [
                  notifications,
                  SizedBox(height: phone ? 16 : 16),
                  backup,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: notifications),
                const SizedBox(width: 16),
                Expanded(child: backup),
              ],
            );
          },
        ),
        SizedBox(height: phone ? 16 : 24),
        if (phone) ...[
          // Compact language / legal access without hub sidebar.
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.language,
              color: StitchMobileColors.onSurfaceVariant,
            ),
            title: Text(
              l10n.settingsNavLanguage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: StitchMobileColors.onSurface,
              ),
            ),
            trailing: Text(
              languageTrailing,
              style: theme.textTheme.labelMedium?.copyWith(
                color: StitchMobileColors.outline,
              ),
            ),
            onTap: () => onSectionSelected(SettingsHubSection.language),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.credit_card_outlined,
              color: StitchMobileColors.onSurfaceVariant,
            ),
            title: Text(
              l10n.settingsNavSubscription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: StitchMobileColors.onSurface,
              ),
            ),
            trailing: subscriptionPlanIsPro
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: StitchMobileColors.primaryContainer.withValues(
                        alpha: 0.2,
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      l10n.settingsProBadge,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: StitchMobileColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  )
                : Text(
                    l10n.subscriptionPlanFree,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: StitchMobileColors.outline,
                    ),
                  ),
            onTap: () => onSectionSelected(SettingsHubSection.subscription),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.privacy_tip_outlined,
              color: StitchMobileColors.onSurfaceVariant,
            ),
            title: Text(
              l10n.settingsLegalPrivacy,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: StitchMobileColors.onSurface,
              ),
            ),
            trailing: const Icon(
              Icons.open_in_new,
              size: 16,
              color: StitchMobileColors.outline,
            ),
            onTap: () => onSectionSelected(SettingsHubSection.privacy),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.description_outlined,
              color: StitchMobileColors.onSurfaceVariant,
            ),
            title: Text(
              l10n.settingsLegalTerms,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: StitchMobileColors.onSurface,
              ),
            ),
            trailing: const Icon(
              Icons.open_in_new,
              size: 16,
              color: StitchMobileColors.outline,
            ),
            onTap: () => onSectionSelected(SettingsHubSection.terms),
          ),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: onSignOut,
            style: TextButton.styleFrom(
              foregroundColor: phone
                  ? StitchMobileColors.error
                  : theme.colorScheme.error,
            ),
            child: Text(
              l10n.profileSignOut,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            Icons.person_off_outlined,
            color: phone
                ? StitchMobileColors.outline
                : MarketingDarkColors.slate400,
          ),
          title: Text(
            l10n.settingsLegalAccountDeletion,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: phone
                  ? StitchMobileColors.onSurfaceVariant
                  : MarketingDarkColors.slate400,
            ),
          ),
          trailing: Icon(
            Icons.open_in_new,
            size: 16,
            color: phone
                ? StitchMobileColors.outline
                : MarketingDarkColors.slate500,
          ),
          onTap: openAccountDeletionInfo,
        ),
        SizedBox(height: bottomPad),
      ],
    );

    return Stack(
      children: [
        CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(edge, phone ? 8 : 24, edge, 8),
              sliver: SliverToBoxAdapter(child: header),
            ),
            if (!desktop && !phone)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(edge, 0, edge, 16),
                sliver: SliverToBoxAdapter(child: nav),
              ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(edge, 0, edge, phone ? 16 : 24),
              sliver: SliverToBoxAdapter(
                child: desktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 280,
                            child: nav,
                          ),
                          const SizedBox(width: 28),
                          Expanded(child: mainColumn),
                        ],
                      )
                    : mainColumn,
              ),
            ),
          ],
        ),
        if (isDirty)
          Align(
            alignment: Alignment.bottomCenter,
            child: SettingsUnsavedBar(
              saving: isSaving,
              onCancel: onCancelChanges,
              onSave: onSaveProfile,
            ),
          ),
      ],
    );
  }
}

class _SettingsHubHeader extends StatelessWidget {
  const _SettingsHubHeader({required this.l10n, required this.phone});

  final AppLocalizations l10n;
  final bool phone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (phone) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.settingsHubTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: StitchMobileColors.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: StitchMobileColors.headlineSize,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: StitchMobileColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: StitchMobileColors.tertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.settingsHubSyncPill,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: StitchMobileColors.tertiary,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.settingsHubSubtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: StitchMobileColors.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsHubTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.settingsHubSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: MarketingDarkColors.slate400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: MarketingDarkColors.emerald.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: MarketingDarkColors.emeraldBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: MarketingDarkColors.emerald,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.settingsHubSyncPill,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: MarketingDarkColors.emerald,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
