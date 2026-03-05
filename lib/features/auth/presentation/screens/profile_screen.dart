import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../theme/stitch_m3_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Updated Coach Profile – matches Stitch prototype (screen ID 5863bd21319d467b828ad322f8670305).
/// Loads and saves profile to Supabase public.profiles (id, display_name, avatar_url, bio, phone, website).
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
        Supabase.instance.client.auth.currentUser?.email ?? '';
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
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _loadError = 'Not signed in';
      });
      return;
    }
    try {
      final res = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = null;
          if (res != null) {
            _displayNameController.text = res['display_name'] as String? ?? '';
            _phoneController.text = res['contact_phone'] as String? ?? '';
            _bioController.text = res['bio'] as String? ?? '';
            _avatarUrlController.text = res['avatar_url'] as String? ?? '';
            _websiteController.text = res['website'] as String? ?? '';
          }
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
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    setState(() => _isSaving = true);

    try {
      await Supabase.instance.client.from('profiles').upsert(
            {
              'id': user.id,
              'display_name': _displayNameController.text.trim().isEmpty
                  ? null
                  : _displayNameController.text.trim(),
              'contact_phone': _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
              'bio': _bioController.text.trim().isEmpty
                  ? null
                  : _bioController.text.trim(),
              'avatar_url': _avatarUrlController.text.trim().isEmpty
                  ? null
                  : _avatarUrlController.text.trim(),
              'website': _websiteController.text.trim().isEmpty
                  ? null
                  : _websiteController.text.trim(),
            },
            onConflict: 'id',
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
      if (e is PostgrestException) {
        debugPrint('PostgrestException: ${e.message} (code: ${e.code}, details: ${e.details})');
      }
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
    await Supabase.instance.client.auth.signOut();
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final user = Supabase.instance.client.auth.currentUser;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: StitchM3Theme.bgSecondary,
        appBar: _profileAppBar(context, theme, l10n.profileTitle),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null && user == null) {
      return Scaffold(
        backgroundColor: StitchM3Theme.bgSecondary,
        appBar: _profileAppBar(context, theme, l10n.profileTitle),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.profileLoadError,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: StitchM3Theme.textMuted,
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
      backgroundColor: StitchM3Theme.bgSecondary,
      appBar: _profileAppBar(context, theme, l10n.profileTitle),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_loadError != null) ...[
                  Text(
                    l10n.profileLoadError,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: StitchM3Theme.danger,
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
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: l10n.profileEmail,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.profilePhone,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _bioController,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    labelText: l10n.profileBio,
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _avatarUrlController,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.profileAvatarUrl,
                  ),
                ),
                const SizedBox(height: 20),
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
                    backgroundColor: StitchM3Theme.accent,
                    foregroundColor: Colors.white,
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
                  onPressed: _isSaving ? null : () => context.push('/customers'),
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
                  onPressed: _isSaving ? null : () => context.push('/settings'),
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
    );
  }

  PreferredSizeWidget _profileAppBar(
    BuildContext context,
    ThemeData theme,
    String title,
  ) {
    return AppBar(
      backgroundColor: StitchM3Theme.bg,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black26,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          HapticFeedback.mediumImpact();
          context.pop();
        },
      ),
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: StitchM3Theme.textPrimary,
        ),
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: StitchM3Theme.border, height: 1),
      ),
    );
  }
}
