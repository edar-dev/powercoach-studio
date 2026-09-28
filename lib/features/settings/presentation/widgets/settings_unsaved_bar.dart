import 'package:flutter/material.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/theme/stitch_mobile_colors.dart';
import '../../../../core/ui/breakpoints.dart';
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
    final phone = !Breakpoints.isTabletOrWider(context);
    return phone ? _buildPhone(context) : _buildDesktop(context);
  }

  Widget _buildPhone(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottomInset.clamp(0, 24)),
        decoration: BoxDecoration(
          color: StitchMobileColors.surface.withValues(alpha: 0.9),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: saving ? null : onCancel,
                  style: FilledButton.styleFrom(
                    backgroundColor: StitchMobileColors.surfaceContainerHigh,
                    foregroundColor: StitchMobileColors.onSurface,
                    disabledBackgroundColor:
                        StitchMobileColors.surfaceContainerHigh
                            .withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(StitchMobileColors.radiusLg),
                    ),
                  ),
                  child: Text(
                    l10n.settingsCancelChanges,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: saving ? null : onSave,
                  style: FilledButton.styleFrom(
                    backgroundColor: StitchMobileColors.primaryContainer,
                    foregroundColor: StitchMobileColors.onPrimaryContainer,
                    disabledBackgroundColor:
                        StitchMobileColors.primaryContainer
                            .withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(StitchMobileColors.radiusLg),
                    ),
                  ),
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: StitchMobileColors.onPrimaryContainer,
                          ),
                        )
                      : Text(
                          l10n.settingsSaveChanges,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: StitchMobileColors.onPrimaryContainer,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
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
                side: const BorderSide(
                  color: MarketingDarkColors.stitchBorderMuted,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(MarketingDarkColors.radiusXl),
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
                  borderRadius:
                      BorderRadius.circular(MarketingDarkColors.radiusXl),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
