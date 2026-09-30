import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../core/auth/supabase_bootstrap.dart';
import '../../../../core/backup/auto_cloud_snapshot_store.dart';
import '../../../../core/backup/backup_activity_store.dart';
import '../../../../core/backup/web_persistence_coordinator.dart';
import '../../../../core/notifications/calendar_reminder_scheduler.dart';
import '../../../../core/routing/app_navigation.dart';
import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/theme/stitch_mobile_colors.dart';
import '../../../../core/ui/breakpoints.dart';
import '../../../../core/ui/widgets/stitch_secondary_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/data/local_coach_profile_repository.dart';
import '../../data/user_preferences_repository.dart';
import '../backup_onboarding_dialog.dart';
import '../settings_backup_handler.dart';
import '../settings_notification_actions.dart';
import '../settings_sign_out.dart';
import '../widgets/settings_hub_nav.dart';
import '../widgets/settings_screen_content.dart';

/// Settings hub – Stitch dark redesign (profile + platform modules).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserPreferencesRepository _preferences =
      UserPreferencesRepository.instance;
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _personalKey = GlobalKey();
  final _notificationsKey = GlobalKey();
  final _backupKey = GlobalKey();

  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  final _websiteController = TextEditingController();

  bool _notificationsEnabled = true;
  bool _calendarRemindersEnabled = false;
  int _calendarReminderLeadHours = CalendarReminderScheduler.defaultLeadHours;
  bool _loading = true;
  bool _saving = false;
  bool _dirty = false;
  String? _profileLoadError;
  SettingsHubSection _activeSection = SettingsHubSection.personalInfo;

  bool _autoCloudEnabled = false;
  bool _showStoragePersistHint = false;
  DateTime? _lastBackupAt;
  DateTime? _lastAutoCloudAt;
  DateTime? _lastCloudSyncAt;
  String? _lastAutoCloudError;

  String _savedDisplayName = '';
  String _savedPhone = '';
  String _savedBio = '';
  String _savedAvatarUrl = '';
  String _savedWebsite = '';
  String _savedSubscriptionPlan = 'free';

  SettingsBackupHandler get _backupHandler => SettingsBackupHandler(
        context: context,
        onPreferencesReloaded: _loadPreferences,
      );

  bool get _emailVerified =>
      SupabaseBootstrap.currentUser?.emailConfirmedAt != null;

  @override
  void initState() {
    super.initState();
    _emailController.text = SupabaseBootstrap.currentUser?.email ?? '';
    for (final c in [
      _displayNameController,
      _phoneController,
      _bioController,
      _avatarUrlController,
      _websiteController,
    ]) {
      c.addListener(_onFieldChanged);
    }
    // Defer InheritedWidget lookups (l10n) until after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _bootstrap();
    });
  }

  @override
  void dispose() {
    for (final c in [
      _displayNameController,
      _phoneController,
      _bioController,
      _avatarUrlController,
      _websiteController,
    ]) {
      c.removeListener(_onFieldChanged);
      c.dispose();
    }
    _emailController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await Future.wait([
      _loadPreferences(),
      _loadProfile(),
      _loadBackupStatus(),
    ]);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadPreferences() async {
    final snapshot = await loadSettingsNotificationPreferences(_preferences);
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = snapshot.notificationsEnabled;
      _calendarRemindersEnabled = snapshot.calendarRemindersEnabled;
      _calendarReminderLeadHours = snapshot.calendarReminderLeadHours;
    });
  }

  Future<void> _loadBackupStatus() async {
    final user = SupabaseBootstrap.currentUser;
    final autoStore = AutoCloudSnapshotStore.instance;
    final enabled = await autoStore.isAutoEnabled();
    DateTime? lastBackup;
    DateTime? lastAuto;
    DateTime? lastSync;
    String? lastError;
    var showHint = false;
    if (user != null) {
      lastBackup =
          await BackupActivityStore.instance.lastSuccessfulBackupAt(user.id);
      lastAuto = await autoStore.lastSuccessAt(user.id);
      lastSync = await autoStore.lastCloudSyncAt(user.id);
      lastError = await autoStore.lastError(user.id);
      showHint = await WebPersistenceCoordinator.instance
          .shouldShowStoragePersistHint(user.id);
    }
    if (!mounted) return;
    setState(() {
      _autoCloudEnabled = enabled;
      _lastBackupAt = lastBackup;
      _lastAutoCloudAt = lastAuto;
      _lastCloudSyncAt = lastSync;
      _lastAutoCloudError = lastError;
      _showStoragePersistHint = showHint;
    });
  }

  String? _formatTimestamp(DateTime? value) {
    if (value == null) return null;
    final local = value.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }

  Future<void> _onAutoCloudToggle(bool enabled) async {
    await AutoCloudSnapshotStore.instance.setAutoEnabled(enabled);
    if (!mounted) return;
    setState(() => _autoCloudEnabled = enabled);
  }

  Future<void> _onDismissStoragePersistHint() async {
    final user = SupabaseBootstrap.currentUser;
    if (user != null) {
      await AutoCloudSnapshotStore.instance.dismissStoragePersistHint(user.id);
    }
    if (!mounted) return;
    setState(() => _showStoragePersistHint = false);
  }

  Future<void> _onUploadCloudBackup() async {
    final l10n = AppLocalizations.of(context);
    await _backupHandler.uploadCloudBackup(l10n);
    if (!mounted) return;
    await _loadBackupStatus();
  }

  Future<void> _onExportBackup() async {
    final l10n = AppLocalizations.of(context);
    await _backupHandler.exportBackup(l10n);
    if (!mounted) return;
    await _loadBackupStatus();
  }

  Future<void> _onPullCloudSync() async {
    final l10n = AppLocalizations.of(context);
    final previousError = _lastAutoCloudError;
    final synced = await WebPersistenceCoordinator.instance.pullCloudSync();
    if (!mounted) return;
    await _loadBackupStatus();
    if (!mounted) return;
    if (synced) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsCloudSyncSuccess)),
      );
    } else if (_lastAutoCloudError != null &&
        _lastAutoCloudError != previousError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsCloudBackupErrorGeneric)),
      );
    }
  }

  Future<void> _loadProfile() async {
    final user = SupabaseBootstrap.currentUser;
    if (user == null) {
      if (!mounted) return;
      _profileLoadError = AppLocalizations.of(context).profileLoadError;
      return;
    }
    try {
      final profile =
          await LocalCoachProfileRepository.instance.getProfile(user.id);
      if (!mounted) return;
      _applySavedProfile(profile);
      _profileLoadError = null;
    } catch (e) {
      if (!mounted) return;
      _profileLoadError = e.toString();
    }
  }

  void _applySavedProfile(LocalUserProfileData profile) {
    _savedDisplayName = profile.displayName;
    _savedPhone = profile.phone;
    _savedBio = profile.bio;
    _savedAvatarUrl = profile.avatarUrl;
    _savedWebsite = profile.website;
    _savedSubscriptionPlan = profile.subscriptionPlan;
    _displayNameController.text = profile.displayName;
    _phoneController.text = profile.phone;
    _bioController.text = profile.bio;
    _avatarUrlController.text = profile.avatarUrl;
    _websiteController.text = profile.website;
    _dirty = false;
  }

  void _onFieldChanged() {
    final dirty = _displayNameController.text != _savedDisplayName ||
        _phoneController.text != _savedPhone ||
        _bioController.text != _savedBio ||
        _avatarUrlController.text != _savedAvatarUrl ||
        _websiteController.text != _savedWebsite;
    if (!mounted) return;
    setState(() => _dirty = dirty);
  }

  void _cancelChanges() {
    setState(() {
      _displayNameController.text = _savedDisplayName;
      _phoneController.text = _savedPhone;
      _bioController.text = _savedBio;
      _avatarUrlController.text = _savedAvatarUrl;
      _websiteController.text = _savedWebsite;
      _dirty = false;
    });
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? true)) return;
    final user = SupabaseBootstrap.currentUser;
    if (user == null) return;
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    setState(() => _saving = true);
    try {
      final next = LocalUserProfileData(
        displayName: _displayNameController.text.trim(),
        phone: _phoneController.text.trim(),
        bio: _bioController.text.trim(),
        avatarUrl: _avatarUrlController.text.trim(),
        website: _websiteController.text.trim(),
        subscriptionPlan: _savedSubscriptionPlan,
      );
      await LocalCoachProfileRepository.instance.saveProfile(user.id, next);
      if (!mounted) return;
      setState(() => _applySavedProfile(next));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileSavedMessage),
          backgroundColor: cs.primaryContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileSaveError),
          backgroundColor: cs.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _onSectionSelected(SettingsHubSection section) {
    switch (section) {
      case SettingsHubSection.subscription:
        navigateToSubscription(context);
        return;
      case SettingsHubSection.language:
        showSettingsLanguagePicker(context: context, l10n: AppLocalizations.of(context));
        return;
      case SettingsHubSection.privacy:
        openPrivacyPolicy();
        return;
      case SettingsHubSection.terms:
        openTermsOfService();
        return;
      case SettingsHubSection.personalInfo:
      case SettingsHubSection.notifications:
      case SettingsHubSection.backup:
        setState(() => _activeSection = section);
        _scrollTo(
          section == SettingsHubSection.personalInfo
              ? _personalKey
              : section == SettingsHubSection.notifications
                  ? _notificationsKey
                  : _backupKey,
        );
    }
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      alignment: 0.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phone = !Breakpoints.isTabletOrWider(context);

    return Scaffold(
      backgroundColor: phone
          ? StitchMobileColors.surface
          : MarketingDarkColors.stitchPageBg,
      appBar: phone
          ? null
          : StitchSecondaryAppBar(title: l10n.settingsTitle),
      body: SafeArea(
        bottom: false,
        child: _loading
          ? const Center(child: CircularProgressIndicator())
          : SettingsScreenContent(
              l10n: l10n,
              scrollController: _scrollController,
              personalKey: _personalKey,
              notificationsKey: _notificationsKey,
              backupKey: _backupKey,
              activeSection: _activeSection,
              onSectionSelected: _onSectionSelected,
              formKey: _formKey,
              displayNameController: _displayNameController,
              emailController: _emailController,
              phoneController: _phoneController,
              bioController: _bioController,
              avatarUrlController: _avatarUrlController,
              websiteController: _websiteController,
              emailVerified: _emailVerified,
              profileLoadError: _profileLoadError,
              notificationsEnabled: _notificationsEnabled,
              calendarRemindersEnabled: _calendarRemindersEnabled,
              calendarReminderLeadHours: _calendarReminderLeadHours,
              onNotificationsToggle: (value) => toggleSettingsNotifications(
                context: context,
                l10n: l10n,
                preferences: _preferences,
                value: value,
                onChanged: (enabled) =>
                    setState(() => _notificationsEnabled = enabled),
              ),
              onCalendarRemindersToggle: (value) =>
                  toggleSettingsCalendarReminders(
                    context: context,
                    l10n: l10n,
                    notificationsEnabled: _notificationsEnabled,
                    value: value,
                    onChanged: (enabled) =>
                        setState(() => _calendarRemindersEnabled = enabled),
                  ),
              onPickCalendarLeadHours: () =>
                  showSettingsCalendarLeadHoursPicker(
                    context: context,
                    l10n: l10n,
                    currentLeadHours: _calendarReminderLeadHours,
                    onSelected: (hours) =>
                        setState(() => _calendarReminderLeadHours = hours),
                  ),
              onExportBackup: _onExportBackup,
              onImportBackup: () => _backupHandler.importBackup(l10n),
              onUploadCloudBackup: _onUploadCloudBackup,
              onRestoreCloudBackup: () =>
                  _backupHandler.restoreFromCloudBackup(l10n),
              autoCloudEnabled: _autoCloudEnabled,
              onAutoCloudToggle: _onAutoCloudToggle,
              showStoragePersistHint: _showStoragePersistHint,
              onDismissStoragePersistHint: _onDismissStoragePersistHint,
              lastBackupAtLabel: _formatTimestamp(_lastBackupAt),
              lastAutoCloudAtLabel: _formatTimestamp(_lastAutoCloudAt),
              lastCloudSyncAtLabel: _formatTimestamp(_lastCloudSyncAt),
              lastErrorLabel: _lastAutoCloudError,
              onPullCloudSync: _onPullCloudSync,
              onSignOut: () => performSettingsSignOut(
                context,
                onPreferencesReloaded: _loadPreferences,
              ),
              isDirty: _dirty,
              isSaving: _saving,
              onCancelChanges: _cancelChanges,
              onSaveProfile: _saveProfile,
              subscriptionPlanIsPro:
                  _savedSubscriptionPlan.toLowerCase() == 'pro',
            ),
      ),
    );
  }
}
