import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/legal_urls.dart';
import '../../../core/platform/open_external_url.dart';
import '../../../core/theme/marketing_dark_colors.dart';
import '../../../l10n/app_localizations.dart';

/// Local teal/cyan accents for the Stitch data-protection modal only.
abstract final class _BackupProtectColors {
  static const Color cardBg = MarketingDarkColors.surface; // #0F172A
  static const Color footerBg = Color(0xFF0B101D);
  static const Color glowBlue = Color(0x592563EB); // blue-600 @ ~35%
  static const Color glowCyan = Color(0x3322D3EE);
  static const Color borderGlow = Color(0x4D3B82F6);
  static const Color iconTileTop = Color(0xFF1E293B);
  static const Color amber = Color(0xFFFBBF24);
  static const Color ping = MarketingDarkColors.cyan;
}

/// First-run dialog explaining local-first storage and encouraging JSON backup.
Future<void> showBackupOnboardingDialog(
  BuildContext context, {
  required VoidCallback onOpenSettings,
  required Future<void> Function() onExportBackup,
}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: const Color(0xCC040711),
    builder: (dialogContext) => _BackupProtectDialog(
      onOpenSettings: onOpenSettings,
      onExportBackup: onExportBackup,
    ),
  );
}

class _BackupProtectDialog extends StatelessWidget {
  const _BackupProtectDialog({
    required this.onOpenSettings,
    required this.onExportBackup,
  });

  final VoidCallback onOpenSettings;
  final Future<void> Function() onExportBackup;

  void _dismiss(BuildContext context) => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      color: MarketingDarkColors.slate300,
      height: 1.5,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _BackupProtectColors.cardBg,
            borderRadius:
                BorderRadius.circular(MarketingDarkColors.radius3xl),
            border: Border.all(
              color: MarketingDarkColors.borderMuted.withValues(alpha: 0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: _BackupProtectColors.borderGlow,
                blurRadius: 28,
                spreadRadius: -4,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.75),
                blurRadius: 48,
                offset: const Offset(0, 24),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(MarketingDarkColors.radius3xl),
            child: Stack(
              children: [
                Positioned(
                  top: -96,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 360,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: LinearGradient(
                          colors: [
                            _BackupProtectColors.glowBlue,
                            _BackupProtectColors.glowCyan,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: MarketingDarkColors.brand
                                .withValues(alpha: 0.35),
                            blurRadius: 64,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(28, 28, 28, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _ShieldIconTile(),
                                const Spacer(),
                                IconButton(
                                  tooltip: l10n.backupOnboardingCloseSemantic,
                                  onPressed: () => _dismiss(context),
                                  style: IconButton.styleFrom(
                                    foregroundColor:
                                        MarketingDarkColors.textMuted,
                                    hoverColor:
                                        MarketingDarkColors.surface700,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.close, size: 20),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              l10n.backupOnboardingTitle,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: MarketingDarkColors.text,
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text.rich(
                              TextSpan(
                                style: bodyStyle,
                                children: [
                                  TextSpan(
                                    text: l10n.appTitle,
                                    style: const TextStyle(
                                      color: MarketingDarkColors.text,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        l10n.backupOnboardingMessageAfterBrand,
                                  ),
                                  TextSpan(
                                    text: l10n.landingStatusOfflineFirst,
                                    style: const TextStyle(
                                      color: MarketingDarkColors.brandLight,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: l10n
                                        .backupOnboardingMessageAfterOffline,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            const _MobilityCallout(),
                            const SizedBox(height: 16),
                            _RecommendRow(style: bodyStyle),
                            if (kIsWeb) ...[
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(left: 28),
                                child: Text(
                                  l10n.backupOnboardingWebHint,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: MarketingDarkColors.textDim,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    _ActionFooter(
                      onOpenSettings: () {
                        _dismiss(context);
                        onOpenSettings();
                      },
                      onExportBackup: () async {
                        _dismiss(context);
                        await onExportBackup();
                      },
                      onGotIt: () => _dismiss(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShieldIconTile extends StatelessWidget {
  const _ShieldIconTile();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _BackupProtectColors.iconTileTop,
                  MarketingDarkColors.surface,
                ],
              ),
              border: Border.all(
                color: MarketingDarkColors.brand.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: MarketingDarkColors.brand.withValues(alpha: 0.28),
                  blurRadius: 18,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.verified_user_outlined,
                color: MarketingDarkColors.brandLight,
                size: 28,
              ),
            ),
          ),
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              width: 14,
              height: 14,
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _BackupProtectColors.ping.withValues(alpha: 0.35),
                    ),
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF06B6D4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobilityCallout extends StatelessWidget {
  const _MobilityCallout();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MarketingDarkColors.radius2xl),
        gradient: LinearGradient(
          colors: [
            MarketingDarkColors.brand.withValues(alpha: 0.45),
            MarketingDarkColors.indigo.withValues(alpha: 0.35),
            MarketingDarkColors.borderMuted.withValues(alpha: 0.5),
          ],
        ),
      ),
      padding: const EdgeInsets.all(1.2),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(MarketingDarkColors.radius2xl - 1),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              const Color(0x66172A54),
              const Color(0x4D1E1B4B),
              MarketingDarkColors.surface900.withValues(alpha: 0.9),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MarketingDarkColors.brand.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: MarketingDarkColors.brandLight.withValues(alpha: 0.2),
                  ),
                ),
                child: const Icon(
                  Icons.smartphone_outlined,
                  size: 20,
                  color: MarketingDarkColors.brandSoft,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: MarketingDarkColors.slate300,
                      height: 1.45,
                    ),
                    children: [
                      TextSpan(
                        text: l10n.backupOnboardingCalloutLead,
                        style: const TextStyle(
                          color: MarketingDarkColors.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: l10n.backupOnboardingCalloutBody),
                      TextSpan(
                        text: l10n.backupOnboardingCalloutEmphasis,
                        style: const TextStyle(
                          color: MarketingDarkColors.brandSoft,
                          decoration: TextDecoration.underline,
                          decorationColor: MarketingDarkColors.brandSoft,
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendRow extends StatelessWidget {
  const _RecommendRow({required this.style});

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.info_outline,
            size: 16,
            color: _BackupProtectColors.amber,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: style?.copyWith(
                color: MarketingDarkColors.textMuted,
                fontSize: 13,
              ),
              children: [
                TextSpan(text: l10n.backupOnboardingRecommendBefore),
                TextSpan(
                  text: l10n.backupOnboardingRecommendSettings,
                  style: const TextStyle(
                    color: MarketingDarkColors.slate300,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: l10n.backupOnboardingRecommendAfter),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionFooter extends StatelessWidget {
  const _ActionFooter({
    required this.onOpenSettings,
    required this.onExportBackup,
    required this.onGotIt,
  });

  final VoidCallback onOpenSettings;
  final VoidCallback onExportBackup;
  final VoidCallback onGotIt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final settingsLink = TextButton.icon(
      onPressed: onOpenSettings,
      icon: Icon(
        Icons.settings_outlined,
        size: 16,
        color: MarketingDarkColors.slate500,
      ),
      label: Text(l10n.backupOnboardingOpenSettings),
      style: TextButton.styleFrom(
        foregroundColor: MarketingDarkColors.textMuted,
        textStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    final exportBtn = OutlinedButton.icon(
      onPressed: onExportBackup,
      icon: const Icon(Icons.download_outlined, size: 16),
      label: Text(l10n.backupOnboardingExportNow),
      style: OutlinedButton.styleFrom(
        foregroundColor: MarketingDarkColors.slate300,
        side: BorderSide(
          color: MarketingDarkColors.borderMuted.withValues(alpha: 0.9),
        ),
        backgroundColor: MarketingDarkColors.surface800,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    final gotItBtn = FilledButton(
      onPressed: onGotIt,
      style: FilledButton.styleFrom(
        backgroundColor: MarketingDarkColors.brand,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        shadowColor: MarketingDarkColors.brand.withValues(alpha: 0.4),
      ),
      child: Text(
        l10n.backupOnboardingGotIt,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: _BackupProtectColors.footerBg,
        border: Border(
          top: BorderSide(
            color: MarketingDarkColors.border.withValues(alpha: 0.9),
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 560;
          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                settingsLink,
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: exportBtn),
                    const SizedBox(width: 10),
                    Expanded(child: gotItBtn),
                  ],
                ),
              ],
            );
          }
          return Row(
            children: [
              Flexible(child: settingsLink),
              const SizedBox(width: 8),
              exportBtn,
              const SizedBox(width: 10),
              gotItBtn,
            ],
          );
        },
      ),
    );
  }
}

void openPrivacyPolicy() => openExternalUrl(LegalUrls.privacyPolicy);

void openTermsOfService() => openExternalUrl(LegalUrls.termsOfService);

void openAccountDeletionInfo() => openExternalUrl(LegalUrls.accountDeletion);
