import 'package:flutter/material.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// Sticky bottom bar shown when personal profile edits are dirty.
class SettingsUnsavedBar extends StatelessWidget {
  const SettingsUnsavedBar({
    super.key,
    required this.saving,
    required this.onCancel,
    required this.onSave,
  });

  final bool saving;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: MarketingDarkColors.stitchPageBg.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(MarketingDarkColors.radius2xl),
          border: Border.all(color: MarketingDarkColors.stitchBorderMuted),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: MarketingDarkColors.amber,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      l10n.settingsUnsavedChanges,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: MarketingDarkColors.slate400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: saving ? null : onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: MarketingDarkColors.slate300,
                side: const BorderSide(color: MarketingDarkColors.stitchBorderMuted),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
                ),
              ),
              child: Text(l10n.settingsCancelChanges),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: saving ? null : onSave,
              icon: saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check, size: 18),
              label: Text(l10n.settingsSaveChanges),
              style: FilledButton.styleFrom(
                backgroundColor: MarketingDarkColors.brand,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
