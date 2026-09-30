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
    this.autoCloudEnabled = false,
    this.onAutoCloudToggle,
    this.showStoragePersistHint = false,
    this.onDismissStoragePersistHint,
    this.lastBackupAtLabel,
    this.lastAutoCloudAtLabel,
    this.lastCloudSyncAtLabel,
    this.lastErrorLabel,
    this.onPullCloudSync,
  });

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

  @override
  Widget build(BuildContext context) {
    final phone = !Breakpoints.isTabletOrWider(context);
    return phone ? _buildPhone(context) : _buildDesktop(context);
  }

  Widget _statusBlock(BuildContext context, {required bool phone}) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = phone
        ? StitchMobileColors.onSurfaceVariant
        : MarketingDarkColors.slate400;
    final onSurface =
        phone ? StitchMobileColors.onSurface : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showStoragePersistHint) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  l10n.settingsStoragePersistHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: phone
                        ? StitchMobileColors.tertiary
                        : MarketingDarkColors.amber,
                  ),
                ),
              ),
              if (onDismissStoragePersistHint != null) ...[
                const SizedBox(width: 4),
                Semantics(
                  button: true,
                  label: l10n.settingsStoragePersistHintDismissSemantic,
                  child: TextButton(
                    onPressed: onDismissStoragePersistHint,
                    style: TextButton.styleFrom(
                      foregroundColor: phone
                          ? StitchMobileColors.onSurfaceVariant
                          : MarketingDarkColors.slate400,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(l10n.settingsStoragePersistHintDismiss),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
        ],
        if (onAutoCloudToggle != null) ...[
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              l10n.settingsAutoCloudBackupToggle,
              style: theme.textTheme.labelLarge?.copyWith(
                color: onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              l10n.settingsAutoCloudBackupHint,
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
            value: autoCloudEnabled,
            onChanged: onAutoCloudToggle,
          ),
          const SizedBox(height: 4),
        ],
        if (lastBackupAtLabel != null)
          Text(
            l10n.settingsBackupLastSuccess(lastBackupAtLabel!),
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
        if (lastAutoCloudAtLabel != null) ...[
          const SizedBox(height: 2),
          Text(
            l10n.settingsBackupLastCloud(lastAutoCloudAtLabel!),
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
        ],
        if (lastCloudSyncAtLabel != null) ...[
          const SizedBox(height: 2),
          Text(
            l10n.settingsCloudLastSync(lastCloudSyncAtLabel!),
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
        ],
        if (lastErrorLabel != null && lastErrorLabel!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            l10n.settingsBackupLastError(lastErrorLabel!),
            style: theme.textTheme.bodySmall?.copyWith(
              color: phone
                  ? StitchMobileColors.error
                  : const Color(0xFFF43F5E),
            ),
          ),
        ],
        if (onPullCloudSync != null) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onPullCloudSync,
              icon: const Icon(Icons.cloud_sync_outlined, size: 18),
              label: Text(l10n.settingsCloudSyncNow),
              style: TextButton.styleFrom(
                foregroundColor: phone
                    ? StitchMobileColors.onSurfaceVariant
                    : MarketingDarkColors.brandLight,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          Text(
            l10n.settingsCloudSyncNowHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: muted,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
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
          const SizedBox(height: 10),
          _statusBlock(context, phone: true),
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
          const SizedBox(height: 12),
          _statusBlock(context, phone: false),
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
