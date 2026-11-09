import 'package:flutter/material.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/theme/stitch_mobile_colors.dart';
import '../../../../core/ui/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';

/// Sticky bottom bar shown when settings child edits are dirty.
class SettingsUnsavedBar extends StatelessWidget {
  const SettingsUnsavedBar({
    super.key,
    required this.saving,
    required this.onCancel,
    required this.onSave,
    this.saveLabel,
    this.onReset,
    this.resetLabel,
    this.showUnsavedHint = true,
    this.saveEnabled = true,
    this.disabledHint,
  });

  final bool saving;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  /// Overrides the primary save button label (defaults to settingsSaveChanges).
  final String? saveLabel;

  /// Optional tertiary reset action (e.g. PDF brand Ripristina).
  final VoidCallback? onReset;
  final String? resetLabel;

  /// When false, hides the desktop amber unsaved hint (compact CTA row).
  final bool showUnsavedHint;

  /// When false, Salva is disabled (still visible) and [disabledHint] may show.
  final bool saveEnabled;

  /// Shown under/near Salva when [saveEnabled] is false.
  final String? disabledHint;

  @override
  Widget build(BuildContext context) {
    final phone = !Breakpoints.isTabletOrWider(context);
    return phone ? _buildPhone(context) : _buildDesktop(context);
  }

  String _resolvedSaveLabel(AppLocalizations l10n) =>
      saveLabel ?? l10n.settingsSaveChanges;

  bool get _canSave => saveEnabled && !saving;

  Widget _buildPhone(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final primaryLabel = _resolvedSaveLabel(l10n);
    final showHint = !saveEnabled &&
        disabledHint != null &&
        disabledHint!.trim().isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottomInset.clamp(0, 24)),
        decoration: BoxDecoration(
          color: StitchMobileColors.surface.withValues(alpha: 0.9),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (onReset != null) ...[
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: saving ? null : onReset,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: StitchMobileColors.onSurface,
                        side: const BorderSide(color: StitchMobileColors.outline),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            StitchMobileColors.radiusLg,
                          ),
                        ),
                      ),
                      child: Text(resetLabel ?? l10n.pdfBrandReset),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: saving ? null : onCancel,
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            StitchMobileColors.surfaceContainerHigh,
                        foregroundColor: StitchMobileColors.onSurface,
                        disabledBackgroundColor:
                            StitchMobileColors.surfaceContainerHigh
                                .withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            StitchMobileColors.radiusLg,
                          ),
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
                    child: Semantics(
                      button: true,
                      enabled: _canSave,
                      label: primaryLabel,
                      child: FilledButton(
                        onPressed: _canSave ? onSave : null,
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              StitchMobileColors.primaryContainer,
                          foregroundColor:
                              StitchMobileColors.onPrimaryContainer,
                          disabledBackgroundColor:
                              StitchMobileColors.primaryContainer
                                  .withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              StitchMobileColors.radiusLg,
                            ),
                          ),
                        ),
                        child: saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                      StitchMobileColors.onPrimaryContainer,
                                ),
                              )
                            : Text(
                                primaryLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color:
                                      StitchMobileColors.onPrimaryContainer,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (showHint) ...[
              const SizedBox(height: 8),
              Text(
                disabledHint!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: StitchMobileColors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final primaryLabel = _resolvedSaveLabel(l10n);
    final showHint = !saveEnabled &&
        disabledHint != null &&
        disabledHint!.trim().isNotEmpty;

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (showUnsavedHint)
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
                  )
                else
                  const Spacer(),
                const SizedBox(width: 12),
                if (onReset != null) ...[
                  OutlinedButton(
                    onPressed: saving ? null : onReset,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: MarketingDarkColors.slate300,
                      side: const BorderSide(
                        color: MarketingDarkColors.stitchBorderMuted,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          MarketingDarkColors.radiusXl,
                        ),
                      ),
                    ),
                    child: Text(resetLabel ?? l10n.pdfBrandReset),
                  ),
                  const SizedBox(width: 8),
                ],
                OutlinedButton(
                  onPressed: saving ? null : onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MarketingDarkColors.slate300,
                    side: const BorderSide(
                      color: MarketingDarkColors.stitchBorderMuted,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        MarketingDarkColors.radiusXl,
                      ),
                    ),
                  ),
                  child: Text(l10n.settingsCancelChanges),
                ),
                const SizedBox(width: 8),
                Semantics(
                  button: true,
                  enabled: _canSave,
                  label: primaryLabel,
                  child: FilledButton.icon(
                    onPressed: _canSave ? onSave : null,
                    icon: saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check, size: 18),
                    label: Text(primaryLabel),
                    style: FilledButton.styleFrom(
                      backgroundColor: MarketingDarkColors.brand,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          MarketingDarkColors.radiusXl,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (showHint) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  disabledHint!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: MarketingDarkColors.slate400,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
