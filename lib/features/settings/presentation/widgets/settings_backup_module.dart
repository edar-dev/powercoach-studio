import 'package:flutter/material.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/theme/stitch_mobile_colors.dart';
import '../../../../core/ui/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';

/// Backup export/import/cloud module for the settings hub.
class SettingsBackupModule extends StatelessWidget {
  const SettingsBackupModule({
    super.key,
    required this.onExportBackup,
    required this.onImportBackup,
    required this.onUploadCloudBackup,
    required this.onRestoreCloudBackup,
  });

  final VoidCallback onExportBackup;
  final VoidCallback onImportBackup;
  final VoidCallback onUploadCloudBackup;
  final VoidCallback onRestoreCloudBackup;

  @override
  Widget build(BuildContext context) {
    final phone = !Breakpoints.isTabletOrWider(context);
    return phone ? _buildPhone(context) : _buildDesktop(context);
  }

  Widget _buildPhone(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StitchMobileColors.surfaceContainer,
        borderRadius: BorderRadius.circular(StitchMobileColors.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.settingsBackupModuleTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: StitchMobileColors.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                l10n.settingsOfflineReadyPill,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: StitchMobileColors.tertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: StitchMobileColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(StitchMobileColors.radiusLg),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.settingsBackupExportLocalTitle,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: StitchMobileColors.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.settingsBackupExportLocalSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: StitchMobileColors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: StitchMobileColors.surfaceContainerHigh,
                  borderRadius:
                      BorderRadius.circular(StitchMobileColors.radiusLg),
                  child: InkWell(
                    onTap: onExportBackup,
                    borderRadius:
                        BorderRadius.circular(StitchMobileColors.radiusLg),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Text(
                        l10n.settingsBackupDownloadAction,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: StitchMobileColors.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: FilledButton(
              onPressed: onUploadCloudBackup,
              style: FilledButton.styleFrom(
                backgroundColor: StitchMobileColors.surfaceContainerHigh,
                foregroundColor: StitchMobileColors.onSurface,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(StitchMobileColors.radiusLg),
                ),
              ),
              child: Text(
                l10n.settingsCloudSyncSnapshot,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(
                onPressed: onImportBackup,
                style: TextButton.styleFrom(
                  foregroundColor: StitchMobileColors.onSurfaceVariant,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(l10n.settingsBackupImport),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: onRestoreCloudBackup,
                style: TextButton.styleFrom(
                  foregroundColor: StitchMobileColors.onSurfaceVariant,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(l10n.settingsCloudBackupRestore),
              ),
            ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.cloud_upload_outlined,
                size: 20,
                color: MarketingDarkColors.emerald,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.settingsBackupModuleTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.settingsBackupSectionSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: MarketingDarkColors.slate400,
            ),
          ),
          const SizedBox(height: 16),
          _ActionRow(
            icon: Icons.download_outlined,
            iconColor: MarketingDarkColors.brandLight,
            title: l10n.settingsBackupExport,
            onTap: onExportBackup,
          ),
          const SizedBox(height: 8),
          _ActionRow(
            icon: Icons.upload_outlined,
            iconColor: MarketingDarkColors.amber,
            title: l10n.settingsBackupImport,
            onTap: onImportBackup,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.settingsCloudBackupSectionTitle,
            style: theme.textTheme.labelLarge?.copyWith(
              color: MarketingDarkColors.slate400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.settingsCloudBackupSectionSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: MarketingDarkColors.slate400,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          _ActionRow(
            icon: Icons.cloud_upload_outlined,
            iconColor: MarketingDarkColors.emerald,
            title: l10n.settingsCloudBackupUpload,
            onTap: onUploadCloudBackup,
          ),
          const SizedBox(height: 8),
          _ActionRow(
            icon: Icons.cloud_download_outlined,
            iconColor: MarketingDarkColors.brandLight,
            title: l10n.settingsCloudBackupRestore,
            onTap: onRestoreCloudBackup,
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: MarketingDarkColors.stitchInput,
      borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
            border: Border.all(color: MarketingDarkColors.stitchBorderMuted),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: MarketingDarkColors.slate500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
