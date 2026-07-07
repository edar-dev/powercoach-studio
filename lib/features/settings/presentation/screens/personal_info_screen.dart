import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../auth/data/local_coach_profile_repository.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/ui/widgets/stitch_card.dart';
import 'package:powercoach_studio/core/ui/widgets/stitch_secondary_app_bar.dart';

/// Personal Info Settings – Stitch screen ID 0f594d4c05da4c8aa79172ab31ce8790.
/// Edit display name, email (read-only), phone; save locally per user.
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
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
    final colorScheme = theme.colorScheme;
    setState(() => _isSaving = true);

    try {
      final current =
          await LocalCoachProfileRepository.instance.getProfile(user.id);
      await LocalCoachProfileRepository.instance.saveProfile(
        user.id,
        LocalUserProfileData(
          displayName: _displayNameController.text.trim(),
          phone: _phoneController.text.trim(),
          bio: current.bio,
          avatarUrl: current.avatarUrl,
          website: current.website,
          subscriptionPlan: current.subscriptionPlan,
        ),
      );

      if (!mounted) return;
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
      await Sentry.captureException(e, stackTrace: stackTrace);
      if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = SupabaseBootstrap.currentUser;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surfaceContainerHighest,
        appBar: StitchSecondaryAppBar(title: l10n.settingsPersonalInfoTitle),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null && user == null) {
      return Scaffold(
        backgroundColor: colorScheme.surfaceContainerHighest,
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
                    color: colorScheme.onSurfaceVariant,
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
      backgroundColor: colorScheme.surfaceContainerHighest,
      appBar: StitchSecondaryAppBar(title: l10n.settingsPersonalInfoTitle),
      body: SafeArea(
        child: SingleChildScrollView(
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
                        color: colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _displayNameController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: l10n.profileDisplayName),
                  ),
                  const SizedBox(height: StitchM3Theme.formFieldSpacing),
                  TextFormField(
                    controller: _emailController,
                    readOnly: true,
                    decoration: InputDecoration(labelText: l10n.profileEmail),
                  ),
                  const SizedBox(height: StitchM3Theme.formFieldSpacing),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(labelText: l10n.profilePhone),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
