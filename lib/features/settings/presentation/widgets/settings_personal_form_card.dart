import 'package:flutter/material.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/theme/stitch_mobile_colors.dart';
import '../../../../core/ui/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import 'settings_stitch_field.dart';

/// Personal info card used on the settings hub and dedicated personal-info route.
class SettingsPersonalFormCard extends StatefulWidget {
  const SettingsPersonalFormCard({
    super.key,
    required this.formKey,
    required this.displayNameController,
    required this.emailController,
    required this.phoneController,
    required this.bioController,
    required this.avatarUrlController,
    required this.websiteController,
    required this.emailVerified,
    this.loadError,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController displayNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController bioController;
  final TextEditingController avatarUrlController;
  final TextEditingController websiteController;
  final bool emailVerified;
  final String? loadError;

  @override
  State<SettingsPersonalFormCard> createState() =>
      _SettingsPersonalFormCardState();
}

class _SettingsPersonalFormCardState extends State<SettingsPersonalFormCard> {
  final _avatarFocusNode = FocusNode();
  static const _bioMaxLength = 200;

  String get _initials {
    final parts = widget.displayNameController.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final s = parts.first;
      return s.substring(0, s.length.clamp(1, 2)).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  void dispose() {
    _avatarFocusNode.dispose();
    super.dispose();
  }

  void _focusAvatarField() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _avatarFocusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final phone = !Breakpoints.isTabletOrWider(context);
    if (phone) {
      return _buildPhone(context);
    }
    return _buildDesktop(context);
  }

  Widget _buildPhone(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PhoneProfileHero(
            initials: _initials,
            displayNameController: widget.displayNameController,
            websiteController: widget.websiteController,
            emailVerified: widget.emailVerified,
            onChangePhoto: _focusAvatarField,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: StitchMobileColors.surfaceContainer,
              borderRadius:
                  BorderRadius.circular(StitchMobileColors.radiusXl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.settingsPersonalInfoCardTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: StitchMobileColors.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      l10n.settingsPersonalInfoCardSubtitle,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: StitchMobileColors.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (widget.loadError != null) ...[
                  Text(
                    l10n.profileLoadError,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: StitchMobileColors.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                SettingsStitchField(
                  label: l10n.settingsFullNameLabel,
                  controller: widget.displayNameController,
                  requiredMark: true,
                  textInputAction: TextInputAction.next,
                  mobileStyle: true,
                ),
                const SizedBox(height: 14),
                SettingsStitchField(
                  label: l10n.settingsOfficialEmailLabel,
                  controller: widget.emailController,
                  readOnly: true,
                  requiredMark: true,
                  mobileStyle: true,
                  helper: widget.emailVerified
                      ? l10n.settingsEmailVerified
                      : null,
                ),
                const SizedBox(height: 14),
                SettingsStitchField(
                  label: l10n.settingsPhoneWhatsAppLabel,
                  controller: widget.phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  mobileStyle: true,
                ),
                const SizedBox(height: 14),
                SettingsStitchField(
                  label: l10n.settingsBioCoachLabel,
                  controller: widget.bioController,
                  maxLines: 3,
                  maxLength: _bioMaxLength,
                  textInputAction: TextInputAction.newline,
                  mobileStyle: true,
                ),
                const SizedBox(height: 14),
                SettingsStitchField(
                  label: l10n.profileAvatarUrl,
                  controller: widget.avatarUrlController,
                  focusNode: _avatarFocusNode,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                  mobileStyle: true,
                ),
                const SizedBox(height: 14),
                SettingsStitchField(
                  label: l10n.profileWebsite,
                  controller: widget.websiteController,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                  mobileStyle: true,
                ),
              ],
            ),
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
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.settingsPersonalInfoCardTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.settingsPersonalInfoCardSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: MarketingDarkColors.slate400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.emailVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: MarketingDarkColors.brand.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: MarketingDarkColors.brandMid
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check,
                          size: 14,
                          color: MarketingDarkColors.brandLight,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.settingsProfileVerified,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: MarketingDarkColors.brandLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, color: MarketingDarkColors.stitchBorder),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ListenableBuilder(
                  listenable: widget.displayNameController,
                  builder: (context, _) {
                    return Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          MarketingDarkColors.radius2xl,
                        ),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            StitchMobileColors.primaryContainer,
                            StitchMobileColors.secondary,
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Container(
                        decoration: BoxDecoration(
                          color: MarketingDarkColors.stitchPageBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _initials,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.settingsAvatarTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.settingsAvatarHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: MarketingDarkColors.slate400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, color: MarketingDarkColors.stitchBorder),
            const SizedBox(height: 20),
            if (widget.loadError != null) ...[
              Text(
                l10n.profileLoadError,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
            ],
            LayoutBuilder(
              builder: (context, constraints) {
                final twoCol = constraints.maxWidth >= 560;
                final fields = <Widget>[
                  SettingsStitchField(
                    label: l10n.profileDisplayName,
                    controller: widget.displayNameController,
                    requiredMark: true,
                    textInputAction: TextInputAction.next,
                  ),
                  SettingsStitchField(
                    label: l10n.profileEmail,
                    controller: widget.emailController,
                    readOnly: true,
                    requiredMark: true,
                    suffix: widget.emailVerified
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: MarketingDarkColors.emerald
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: MarketingDarkColors.emeraldBorder,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check,
                                  size: 12,
                                  color: MarketingDarkColors.emerald,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.settingsEmailVerified,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: MarketingDarkColors.emerald,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : null,
                  ),
                  SettingsStitchField(
                    label: l10n.profilePhone,
                    controller: widget.phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                  SettingsStitchField(
                    label: l10n.profileAvatarUrl,
                    controller: widget.avatarUrlController,
                    focusNode: _avatarFocusNode,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.next,
                  ),
                  SettingsStitchField(
                    label: l10n.profileWebsite,
                    controller: widget.websiteController,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.next,
                  ),
                ];

                if (!twoCol) {
                  return Column(
                    children: [
                      for (final f in fields) ...[
                        f,
                        const SizedBox(height: 20),
                      ],
                      SettingsStitchField(
                        label: l10n.profileBio,
                        controller: widget.bioController,
                        maxLines: 4,
                        maxLength: _bioMaxLength,
                        textInputAction: TextInputAction.newline,
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: fields[0]),
                        const SizedBox(width: 20),
                        Expanded(child: fields[1]),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: fields[2]),
                        const SizedBox(width: 20),
                        Expanded(child: fields[3]),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SettingsStitchField(
                      label: l10n.profileBio,
                      controller: widget.bioController,
                      maxLines: 4,
                      maxLength: _bioMaxLength,
                      textInputAction: TextInputAction.newline,
                    ),
                    const SizedBox(height: 20),
                    fields[4],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneProfileHero extends StatelessWidget {
  const _PhoneProfileHero({
    required this.initials,
    required this.displayNameController,
    required this.websiteController,
    required this.emailVerified,
    required this.onChangePhoto,
  });

  final String initials;
  final TextEditingController displayNameController;
  final TextEditingController websiteController;
  final bool emailVerified;
  final VoidCallback onChangePhoto;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StitchMobileColors.surfaceContainer,
        borderRadius: BorderRadius.circular(StitchMobileColors.radiusXl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListenableBuilder(
            listenable: displayNameController,
            builder: (context, _) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          StitchMobileColors.primaryContainer,
                          StitchMobileColors.secondary,
                        ],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: StitchMobileColors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  if (emailVerified)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: StitchMobileColors.tertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListenableBuilder(
                  listenable: displayNameController,
                  builder: (context, _) {
                    final name = displayNameController.text.trim().isEmpty
                        ? '—'
                        : displayNameController.text.trim();
                    return Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: StitchMobileColors.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (emailVerified) ...[
                          const SizedBox(width: 6),
                          const Text(
                            '✓',
                            style: TextStyle(
                              color: StitchMobileColors.secondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                ListenableBuilder(
                  listenable: websiteController,
                  builder: (context, _) {
                    final title = websiteController.text.trim();
                    if (title.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: StitchMobileColors.secondary,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Material(
                    color: StitchMobileColors.surfaceContainerHigh,
                    borderRadius:
                        BorderRadius.circular(StitchMobileColors.radiusLg),
                    child: InkWell(
                      onTap: onChangePhoto,
                      borderRadius:
                          BorderRadius.circular(StitchMobileColors.radiusLg),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Text(
                          l10n.settingsChangePhoto,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: StitchMobileColors.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
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
