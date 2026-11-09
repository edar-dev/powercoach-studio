import 'package:flutter/material.dart';

import '../../../../core/locale/app_locale_controller.dart';
import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/theme/stitch_mobile_colors.dart';
import '../../../../core/ui/breakpoints.dart';
import '../../../../core/ui/widgets/pinned_section_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../backup_onboarding_dialog.dart';
import 'settings_backup_module.dart';
import 'settings_hub_nav.dart';
import 'settings_notifications_module.dart';
import 'settings_personal_form_card.dart';
import 'settings_unsaved_bar.dart';
import 'settings_workout_prefs_module.dart';

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
    required this.maximalWeightRoundingKg,
    required this.onNotificationsToggle,
    required this.onCalendarRemindersToggle,
    required this.onPickCalendarLeadHours,
    required this.onMaximalWeightRoundingChanged,
    required this.onExportBackup,
    required this.onImportBackup,
    required this.onUploadCloudBackup,
    required this.onRestoreCloudBackup,
    this.autoCloudEnabled = false,
    this.onAutoCloudToggle,
    this.showStoragePersistHint = false,
    this.onDismissStoragePersistHint,
    this.lastBackupAtLabel,
    this.lastAutoCloudAtLabel,
    this.lastCloudSyncAtLabel,
    this.lastErrorLabel,
    this.onPullCloudSync,
    required this.onSignOut,
    required this.isDirty,
    required this.isSaving,
    required this.onCancelChanges,
    required this.onSaveProfile,
    this.subscriptionPlanIsPro = false,
    this.saveEnabled = true,
    this.saveDisabledHint,
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
  final double maximalWeightRoundingKg;
  final ValueChanged<bool> onNotificationsToggle;
  final ValueChanged<bool> onCalendarRemindersToggle;
  final VoidCallback onPickCalendarLeadHours;
  final ValueChanged<double> onMaximalWeightRoundingChanged;
  final VoidCallback onExportBackup;
  final VoidCallback onImportBackup;
  final VoidCallback onUploadCloudBackup;
  final VoidCallback onRestoreCloudBackup;
  final bool autoCloudEnabled;
  final ValueChanged<bool>? onAutoCloudToggle;
  final bool showStoragePersistHint;
  final VoidCallback? onDismissStoragePersistHint;
  final String? lastBackupAtLabel;
  final String? lastAutoCloudAtLabel;
  final String? lastCloudSyncAtLabel;
  final String? lastErrorLabel;
  final VoidCallback? onPullCloudSync;
  final VoidCallback onSignOut;
  final bool isDirty;
  final bool isSaving;
  final VoidCallback onCancelChanges;
  final VoidCallback onSaveProfile;
  final bool subscriptionPlanIsPro;
  final bool saveEnabled;
  final String? saveDisabledHint;

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
    final edge = phone ? 12.0 : (desktop ? 16.0 : 20.0);
    final moduleGap = phone ? 12.0 : 24.0;
    final bottomPad = isDirty ? (phone ? 120.0 : 88.0) : (phone ? 32.0 : 24.0);

    final personalCard = KeyedSubtree(
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
    );
    final workoutPrefs = SettingsWorkoutPrefsModule(
      maximalWeightRoundingKg: maximalWeightRoundingKg,
      onRoundingChanged: onMaximalWeightRoundingChanged,
    );
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
        autoCloudEnabled: autoCloudEnabled,
        onAutoCloudToggle: onAutoCloudToggle,
        showStoragePersistHint: showStoragePersistHint,
        onDismissStoragePersistHint: onDismissStoragePersistHint,
        lastBackupAtLabel: lastBackupAtLabel,
        lastAutoCloudAtLabel: lastAutoCloudAtLabel,
        lastCloudSyncAtLabel: lastCloudSyncAtLabel,
        lastErrorLabel: lastErrorLabel,
        onPullCloudSync: onPullCloudSync,
      ),
    );

    final accountTail = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: onSignOut,
            style: TextButton.styleFrom(
              foregroundColor: phone
                  ? StitchMobileColors.error
                  : theme.colorScheme.error,
              visualDensity: phone ? VisualDensity.compact : null,
            ),
            child: Text(
              l10n.profileSignOut,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          visualDensity: phone ? VisualDensity.compact : null,
          minVerticalPadding: phone ? 4 : null,
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

    final otherList = _PhoneOtherLinks(
      l10n: l10n,
      languageTrailing: languageTrailing,
      subscriptionPlanIsPro: subscriptionPlanIsPro,
      onSectionSelected: onSectionSelected,
    );

    return Stack(
      children: [
        CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(edge, phone ? 8 : 16, edge, 8),
              sliver: SliverToBoxAdapter(child: header),
            ),
            if (!desktop && !phone)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(edge, 0, edge, 16),
                sliver: SliverToBoxAdapter(child: nav),
              ),
            if (phone)
              ..._phonePinnedSlivers(
                context: context,
                edge: edge,
                moduleGap: moduleGap,
                personalCard: personalCard,
                workoutPrefs: workoutPrefs,
                notifications: notifications,
                backup: backup,
                otherList: otherList,
                accountTail: accountTail,
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(edge, 0, edge, 20),
                sliver: SliverToBoxAdapter(
                  child: desktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 280, child: nav),
                            const SizedBox(width: 18),
                            Expanded(
                              child: _DesktopMainColumn(
                                personalCard: personalCard,
                                workoutPrefs: workoutPrefs,
                                notifications: notifications,
                                backup: backup,
                                accountTail: accountTail,
                                moduleGap: moduleGap,
                              ),
                            ),
                          ],
                        )
                      : _DesktopMainColumn(
                          personalCard: personalCard,
                          workoutPrefs: workoutPrefs,
                          notifications: notifications,
                          backup: backup,
                          accountTail: accountTail,
                          moduleGap: moduleGap,
                        ),
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
              saveEnabled: saveEnabled,
              disabledHint: saveDisabledHint,
            ),
          ),
      ],
    );
  }

  List<Widget> _phonePinnedSlivers({
    required BuildContext context,
    required double edge,
    required double moduleGap,
    required Widget personalCard,
    required Widget workoutPrefs,
    required Widget notifications,
    required Widget backup,
    required Widget otherList,
    required Widget accountTail,
  }) {
    Widget sectionTitle(String title) {
      return Padding(
        padding: EdgeInsets.fromLTRB(edge, 4, edge, 4),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: StitchMobileColors.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
        ),
      );
    }

    Widget body(Widget child, {double bottom = 0}) {
      return SliverPadding(
        padding: EdgeInsets.fromLTRB(edge, 0, edge, bottom),
        sliver: SliverToBoxAdapter(
          child: ListTileTheme(
            data: const ListTileThemeData(
              visualDensity: VisualDensity.compact,
              minVerticalPadding: 4,
              contentPadding: EdgeInsets.zero,
            ),
            child: child,
          ),
        ),
      );
    }

    return [
      PinnedSectionHeader(
        height: 32,
        backgroundColor: StitchMobileColors.surface,
        child: sectionTitle(l10n.settingsNavPersonalInfo),
      ),
      body(personalCard, bottom: moduleGap),
      PinnedSectionHeader(
        height: 32,
        backgroundColor: StitchMobileColors.surface,
        child: sectionTitle(l10n.settingsWorkoutPrefsModuleTitle),
      ),
      body(workoutPrefs, bottom: moduleGap),
      PinnedSectionHeader(
        height: 32,
        backgroundColor: StitchMobileColors.surface,
        child: sectionTitle(l10n.settingsNavNotifications),
      ),
      body(notifications, bottom: moduleGap),
      PinnedSectionHeader(
        height: 32,
        backgroundColor: StitchMobileColors.surface,
        child: sectionTitle(l10n.settingsBackupModuleTitle),
      ),
      body(backup, bottom: moduleGap),
      PinnedSectionHeader(
        height: 32,
        backgroundColor: StitchMobileColors.surface,
        child: sectionTitle(l10n.settingsSectionOther),
      ),
      body(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            otherList,
            accountTail,
          ],
        ),
      ),
    ];
  }
}

class _DesktopMainColumn extends StatelessWidget {
  const _DesktopMainColumn({
    required this.personalCard,
    required this.workoutPrefs,
    required this.notifications,
    required this.backup,
    required this.accountTail,
    required this.moduleGap,
  });

  final Widget personalCard;
  final Widget workoutPrefs;
  final Widget notifications;
  final Widget backup;
  final Widget accountTail;
  final double moduleGap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sideBySide = constraints.maxWidth >= 720;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            personalCard,
            SizedBox(height: moduleGap),
            workoutPrefs,
            SizedBox(height: moduleGap),
            if (!sideBySide) ...[
              notifications,
              const SizedBox(height: 16),
              backup,
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: notifications),
                  const SizedBox(width: 16),
                  Expanded(child: backup),
                ],
              ),
            SizedBox(height: moduleGap),
            accountTail,
          ],
        );
      },
    );
  }
}

class _PhoneOtherLinks extends StatelessWidget {
  const _PhoneOtherLinks({
    required this.l10n,
    required this.languageTrailing,
    required this.subscriptionPlanIsPro,
    required this.onSectionSelected,
  });

  final AppLocalizations l10n;
  final String languageTrailing;
  final bool subscriptionPlanIsPro;
  final ValueChanged<SettingsHubSection> onSectionSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget tile({
      required IconData icon,
      required String title,
      required VoidCallback onTap,
      Widget? trailing,
    }) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        minVerticalPadding: 4,
        leading: Icon(icon, color: StitchMobileColors.onSurfaceVariant),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: StitchMobileColors.onSurface,
          ),
        ),
        trailing: trailing ??
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: StitchMobileColors.outline,
            ),
        onTap: onTap,
      );
    }

    return Column(
      children: [
        tile(
          icon: Icons.language,
          title: l10n.settingsNavLanguage,
          trailing: Text(
            languageTrailing,
            style: theme.textTheme.labelMedium?.copyWith(
              color: StitchMobileColors.outline,
            ),
          ),
          onTap: () => onSectionSelected(SettingsHubSection.language),
        ),
        tile(
          icon: Icons.picture_as_pdf_outlined,
          title: l10n.settingsNavPdfBrand,
          onTap: () => onSectionSelected(SettingsHubSection.pdfBrand),
        ),
        tile(
          icon: Icons.health_and_safety_outlined,
          title: l10n.settingsNavDataHealth,
          onTap: () => onSectionSelected(SettingsHubSection.dataHealth),
        ),
        tile(
          icon: Icons.credit_card_outlined,
          title: l10n.settingsNavSubscription,
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
        tile(
          icon: Icons.privacy_tip_outlined,
          title: l10n.settingsLegalPrivacy,
          trailing: const Icon(
            Icons.open_in_new,
            size: 16,
            color: StitchMobileColors.outline,
          ),
          onTap: () => onSectionSelected(SettingsHubSection.privacy),
        ),
        tile(
          icon: Icons.description_outlined,
          title: l10n.settingsLegalTerms,
          trailing: const Icon(
            Icons.open_in_new,
            size: 16,
            color: StitchMobileColors.outline,
          ),
          onTap: () => onSectionSelected(SettingsHubSection.terms),
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
      // Title lives in StitchSecondaryAppBar; keep badge + subtitle only.
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Container(
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
                  l10n.settingsHubTitleShort,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.settingsHubSubtitleShort,
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
