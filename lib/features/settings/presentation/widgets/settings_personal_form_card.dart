import 'package:flutter/material.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../l10n/app_localizations.dart';
import 'settings_stitch_field.dart';

/// Personal info card used on the settings hub and dedicated personal-info route.
class SettingsPersonalFormCard extends StatelessWidget {
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

  String get _initials {
    final parts = displayNameController.text
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
  Widget build(BuildContext context) {
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
        key: formKey,
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
                if (emailVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: MarketingDarkColors.brand.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: MarketingDarkColors.brandMid.withValues(alpha: 0.2),
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
                  listenable: displayNameController,
                  builder: (context, _) {
                    return Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(MarketingDarkColors.radius2xl),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            MarketingDarkColors.brand,
                            Color(0xFF2563EB),
                            Color(0xFF4338CA),
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
            if (loadError != null) ...[
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
                    controller: displayNameController,
                    requiredMark: true,
                    textInputAction: TextInputAction.next,
                  ),
                  SettingsStitchField(
                    label: l10n.profileEmail,
                    controller: emailController,
                    readOnly: true,
                    requiredMark: true,
                    suffix: emailVerified
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: MarketingDarkColors.emerald.withValues(
                                alpha: 0.1,
                              ),
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
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                  SettingsStitchField(
                    label: l10n.profileAvatarUrl,
                    controller: avatarUrlController,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.next,
                  ),
                  SettingsStitchField(
                    label: l10n.profileWebsite,
                    controller: websiteController,
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
                        controller: bioController,
                        maxLines: 4,
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
                      controller: bioController,
                      maxLines: 4,
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
