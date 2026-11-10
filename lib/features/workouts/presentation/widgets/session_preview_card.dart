import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// One preview row inside a session/section card (exercise or mobility item).
class SessionPreviewRowData {
  const SessionPreviewRowData({
    required this.title,
    this.detail,
  });

  final String title;
  final String? detail;
}

/// Shared day/section preview chrome used by training days and mobility sections.
///
/// Training wraps this via [TrainingPhaseDayCard]; mobility uses it directly so
/// both surfaces share the same card, preview rows, and footer CTA pattern.
class SessionPreviewCard extends StatelessWidget {
  const SessionPreviewCard({
    super.key,
    required this.title,
    required this.previewRows,
    required this.remainingCount,
    required this.footerMetricLabel,
    required this.onOpen,
    this.subtitle,
    this.leadingChip,
    this.bodyTitle,
    this.selected = false,
    this.expandPreview = false,
    this.emptyLabel,
    this.editCtaLabel,
    this.onMenuSelected,
    this.menuItems,
    this.showMenu = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leadingChip;
  final String? bodyTitle;
  final List<SessionPreviewRowData> previewRows;
  final int remainingCount;
  final String footerMetricLabel;
  final VoidCallback onOpen;
  final bool selected;

  /// When true, the preview list expands to fill remaining height (week grid).
  final bool expandPreview;
  final String? emptyLabel;
  final String? editCtaLabel;
  final void Function(String action)? onMenuSelected;
  final List<PopupMenuEntry<String>> Function(BuildContext context)? menuItems;
  final bool showMenu;

  static const int previewLimit = 4;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hint = (subtitle ?? '').trim();
    final customTitle = (bodyTitle ?? '').trim();
    final cta = editCtaLabel ?? l10n.workoutPhaseEditSession;
    final empty = emptyLabel ?? l10n.workoutPhaseNoExercisesYet;

    final previewBody = previewRows.isEmpty
        ? Text(
            empty,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          )
        : ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: !expandPreview,
            physics: expandPreview
                ? const ClampingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            children: [
              for (var i = 0; i < previewRows.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                _SessionPreviewRow(
                  row: previewRows[i],
                  cs: cs,
                  theme: theme,
                ),
              ],
              if (remainingCount > 0) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.workoutPhaseMoreExercises(remainingCount),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          );

    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? cs.primary.withValues(alpha: 0.75)
                  : cs.outlineVariant.withValues(alpha: 0.65),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (leadingChip != null) ...[
                    leadingChip!,
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: (leadingChip == null
                                  ? theme.textTheme.titleSmall
                                  : theme.textTheme.labelMedium)
                              ?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (hint.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            hint,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (showMenu &&
                      onMenuSelected != null &&
                      menuItems != null)
                    PopupMenuButton<String>(
                      tooltip: l10n.workoutBuilderDayMenuTooltip,
                      padding: EdgeInsets.zero,
                      onSelected: onMenuSelected,
                      itemBuilder: menuItems!,
                      child: Icon(
                        Icons.more_vert,
                        size: 18,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(
                height: 1,
                color: cs.outlineVariant.withValues(alpha: 0.55),
              ),
              const SizedBox(height: 12),
              if (customTitle.isNotEmpty) ...[
                Text(
                  customTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],
              if (expandPreview) Expanded(child: previewBody) else previewBody,
              const SizedBox(height: 12),
              Divider(
                height: 1,
                color: cs.outlineVariant.withValues(alpha: 0.55),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      footerMetricLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onOpen,
                    style: TextButton.styleFrom(
                      foregroundColor: cs.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          cta,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.chevron_right, size: 16, color: cs.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionPreviewRow extends StatelessWidget {
  const _SessionPreviewRow({
    required this.row,
    required this.cs,
    required this.theme,
  });

  final SessionPreviewRowData row;
  final ColorScheme cs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final detail = (row.detail ?? '').trim();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            row.title.trim().isEmpty ? '—' : row.title.trim(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (detail.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.primary,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
