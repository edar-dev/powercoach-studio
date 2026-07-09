import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';
import 'package:powercoach_studio/core/routing/app_navigation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../data/local_coach_profile_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../settings/presentation/settings_sign_out.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/widgets/stitch_card.dart';
import 'package:powercoach_studio/core/ui/widgets/stitch_secondary_app_bar.dart';

/// Updated Coach Profile – matches Stitch prototype (screen ID 5863bd21319d467b828ad322f8670305).
/// Loads and saves profile locally per authenticated user.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  final _websiteController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _emailController.text =
        SupabaseBootstrap.currentUser?.email ?? '';
    _loadProfile();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _avatarUrlController.dispose();
    _websiteController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = SupabaseBootstrap.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _loadError = 'Not signed in';
      });
      return;
    }
    try {
      final localProfile =
          await LocalCoachProfileRepository.instance.getProfile(user.id);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = null;
          _displayNameController.text = localProfile.displayName;
          _phoneController.text = localProfile.phone;
          _bioController.text = localProfile.bio;
          _avatarUrlController.text = localProfile.avatarUrl;
          _websiteController.text = localProfile.website;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = e.toString();
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = SupabaseBootstrap.currentUser;
    if (user == null) return;

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    setState(() => _isSaving = true);

    try {
      final current =
          await LocalCoachProfileRepository.instance.getProfile(user.id);
      await LocalCoachProfileRepository.instance.saveProfile(
        user.id,
        LocalUserProfileData(
          displayName: _displayNameController.text.trim(),
          phone: _phoneController.text.trim(),
          bio: _bioController.text.trim(),
          avatarUrl: _avatarUrlController.text.trim(),
          website: _websiteController.text.trim(),
          subscriptionPlan: current.subscriptionPlan,
        ),
      );

      if (!mounted) return;
      final colorScheme = theme.colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.profileSavedMessage,
            style: TextStyle(color: colorScheme.onPrimaryContainer),
          ),
          backgroundColor: colorScheme.primaryContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Profile save error: $e');
      debugPrint(stackTrace.toString());
      await Sentry.captureException(e, stackTrace: stackTrace);
      if (!mounted) return;
      final colorScheme = theme.colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.profileSaveError,
            style: TextStyle(color: colorScheme.onErrorContainer),
          ),
          backgroundColor: colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _signOut() async {
    await requestSignOut(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final user = SupabaseBootstrap.currentUser;

    final cs = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: cs.surfaceContainerHighest,
        appBar: StitchSecondaryAppBar(title: l10n.profileTitle),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null && user == null) {
      return Scaffold(
        backgroundColor: cs.surfaceContainerHighest,
        appBar: StitchSecondaryAppBar(title: l10n.profileTitle),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.profileLoadError,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: cs.onSurfaceVariant,
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
      backgroundColor: cs.surfaceContainerHighest,
      appBar: StitchSecondaryAppBar(title: l10n.profileTitle),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: StitchCard(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_loadError != null) ...[
                    Text(
                      l10n.profileLoadError,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _displayNameController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.profileDisplayName,
                    ),
                  ),
                  const SizedBox(height: StitchM3Theme.formFieldSpacing),
                  TextFormField(
                    controller: _emailController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: l10n.profileEmail,
                    ),
                  ),
                  const SizedBox(height: StitchM3Theme.formFieldSpacing),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.profilePhone,
                    ),
                  ),
                  const SizedBox(height: StitchM3Theme.formFieldSpacing),
                  TextFormField(
                    controller: _bioController,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      labelText: l10n.profileBio,
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: StitchM3Theme.formFieldSpacing),
                  TextFormField(
                    controller: _avatarUrlController,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.profileAvatarUrl,
                    ),
                  ),
                  const SizedBox(height: StitchM3Theme.formFieldSpacing),
                  TextFormField(
                    controller: _websiteController,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: l10n.profileWebsite,
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _isSaving ? null : _save,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.profileSave),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: _isSaving ? null : () => navigateTo(context, '/customers'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                      ),
                    ),
                    icon: const Icon(Icons.people_outline),
                    label: Text(l10n.customersTitle),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _isSaving ? null : () => navigateTo(context, '/settings'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                      ),
                    ),
                    icon: const Icon(Icons.settings_outlined),
                    label: Text(l10n.settingsTitle),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _isSaving ? null : _signOut,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                      ),
                    ),
                    child: Text(l10n.profileSignOut),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
