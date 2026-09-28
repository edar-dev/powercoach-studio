import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../core/auth/supabase_bootstrap.dart';
import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/ui/widgets/stitch_secondary_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/data/local_coach_profile_repository.dart';
import '../widgets/settings_personal_form_card.dart';
import '../widgets/settings_unsaved_bar.dart';

/// Dedicated personal info route – Stitch dark visual language.
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  final _websiteController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _dirty = false;
  String? _loadError;

  String _savedDisplayName = '';
  String _savedPhone = '';
  String _savedBio = '';
  String _savedAvatarUrl = '';
  String _savedWebsite = '';
  String _savedSubscriptionPlan = 'free';

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
    _loadProfile();
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
    super.dispose();
  }

  void _onFieldChanged() {
    final dirty = _displayNameController.text != _savedDisplayName ||
        _phoneController.text != _savedPhone ||
        _bioController.text != _savedBio ||
        _avatarUrlController.text != _savedAvatarUrl ||
        _websiteController.text != _savedWebsite;
    if (mounted) setState(() => _dirty = dirty);
  }

  Future<void> _loadProfile() async {
    final user = SupabaseBootstrap.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _loadError = AppLocalizations.of(context).profileLoadError;
      });
      return;
    }
    try {
      final localProfile =
          await LocalCoachProfileRepository.instance.getProfile(user.id);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = null;
        _applySaved(localProfile);
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = e.toString();
        });
      }
    }
  }

  void _applySaved(LocalUserProfileData profile) {
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

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? true)) return;
    final user = SupabaseBootstrap.currentUser;
    if (user == null) return;

    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    setState(() => _isSaving = true);

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
      setState(() => _applySaved(next));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileSavedMessage),
          backgroundColor: colorScheme.primaryContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileSaveError),
          backgroundColor: colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final user = SupabaseBootstrap.currentUser;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: MarketingDarkColors.stitchPageBg,
        appBar: StitchSecondaryAppBar(title: l10n.settingsPersonalInfoTitle),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null && user == null) {
      return Scaffold(
        backgroundColor: MarketingDarkColors.stitchPageBg,
        appBar: StitchSecondaryAppBar(title: l10n.settingsPersonalInfoTitle),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.profileLoadError,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: MarketingDarkColors.slate400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go('/login'),
                  child: Text(l10n.headerLogin),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: MarketingDarkColors.stitchPageBg,
      appBar: StitchSecondaryAppBar(title: l10n.settingsPersonalInfoTitle),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(24, 24, 24, _dirty ? 100 : 24),
              child: SettingsPersonalFormCard(
                formKey: _formKey,
                displayNameController: _displayNameController,
                emailController: _emailController,
                phoneController: _phoneController,
                bioController: _bioController,
                avatarUrlController: _avatarUrlController,
                websiteController: _websiteController,
                emailVerified: _emailVerified,
                loadError: _loadError,
              ),
            ),
          ),
          if (_dirty)
            Align(
              alignment: Alignment.bottomCenter,
              child: SettingsUnsavedBar(
                saving: _isSaving,
                onCancel: _cancelChanges,
                onSave: _save,
              ),
            ),
        ],
      ),
    );
  }
}
