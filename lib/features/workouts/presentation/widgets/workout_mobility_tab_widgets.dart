import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';

class MobilitySectionChip extends StatelessWidget {
  const MobilitySectionChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.onEdit,
    this.onDelete,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    return Material(
      color: selected
          ? StitchM3Theme.accent
          : cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 4, top: 4, bottom: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: selected ? Colors.white : cs.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (selected)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_horiz,
                    size: 18,
                    color: selected ? Colors.white : cs.onSurfaceVariant,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(l10n.workoutBuilderEditExercise),
                    ),
                    if (onDelete != null)
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          l10n.workoutBuilderDeleteExercise,
                          style: const TextStyle(color: StitchM3Theme.danger),
                        ),
                      ),
                  ],
                )
              else
                const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class MobilityItemCard extends StatefulWidget {
  const MobilityItemCard({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.index,
    required this.title,
    required this.subtitle,
    this.shortTitle = '',
    this.onEdit,
    this.onDelete,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final int index;
  final String title;
  final String subtitle;
  final String shortTitle;
  final void Function(String title, String subtitle, String shortTitle)? onEdit;
  final VoidCallback? onDelete;

  @override
  State<MobilityItemCard> createState() => _MobilityItemCardState();
}

class _MobilityItemCardState extends State<MobilityItemCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final cs = widget.colorScheme;
    final l10n = AppLocalizations.of(context);
    final summary = widget.subtitle.trim().isNotEmpty
        ? widget.subtitle
        : (widget.shortTitle.trim().isNotEmpty ? widget.shortTitle : null);
    final secondaryColor = cs.onSurface.withValues(alpha: 0.72);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ReorderableDragStartListener(
                index: widget.index,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.drag_indicator,
                    size: 20,
                    color: secondaryColor,
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _expanded = !_expanded),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!_expanded && summary != null) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              summary,
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: secondaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                padding: EdgeInsets.zero,
                tooltip: _expanded
                    ? MaterialLocalizations.of(context).expandedIconTapHint
                    : MaterialLocalizations.of(context).collapsedIconTapHint,
                icon: Icon(
                  _expanded ? Icons.expand_less : Icons.chevron_right,
                  color: cs.onSurfaceVariant,
                ),
                onPressed: () => setState(() => _expanded = !_expanded),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 24, color: cs.onSurfaceVariant),
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                onSelected: (value) {
                  if (value == 'edit' && widget.onEdit != null) {
                    showEditMobilityItemDialog(
                      context,
                      widget.title,
                      widget.subtitle,
                      widget.shortTitle,
                      widget.onEdit!,
                    );
                  } else if (value == 'delete') {
                    widget.onDelete?.call();
                  }
                },
                itemBuilder: (ctx) {
                  final menuL10n = AppLocalizations.of(ctx);
                  return [
                    if (widget.onEdit != null)
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(menuL10n.workoutBuilderEditExercise),
                      ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        menuL10n.workoutBuilderDeleteExercise,
                        style: const TextStyle(color: StitchM3Theme.danger),
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 4, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.shortTitle.trim().isNotEmpty)
                  Text(
                    widget.shortTitle,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: secondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (widget.subtitle.trim().isNotEmpty) ...[
                  if (widget.shortTitle.trim().isNotEmpty)
                    const SizedBox(height: 6),
                  Text(
                    widget.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface,
                    ),
                  ),
                ],
                if (widget.subtitle.trim().isEmpty &&
                    widget.shortTitle.trim().isEmpty)
                  Text(
                    l10n.workoutBuilderNotePlaceholder,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: secondaryColor,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (widget.onEdit != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => showEditMobilityItemDialog(
                        context,
                        widget.title,
                        widget.subtitle,
                        widget.shortTitle,
                        widget.onEdit!,
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: Text(l10n.workoutBuilderEditExercise),
                    ),
                  ),
                ],
              ],
            ),
          ),
        Divider(
          height: 1,
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
      ],
    );
  }
}

void showEditMobilityItemDialog(
  BuildContext context,
  String initialTitle,
  String initialSubtitle,
  String initialShortTitle,
  void Function(String title, String subtitle, String shortTitle) onSave,
) {
  final l10n = AppLocalizations.of(context);
  final titleController = TextEditingController(text: initialTitle);
  final subtitleController = TextEditingController(text: initialSubtitle);
  final shortTitleController = TextEditingController(text: initialShortTitle);
  showAppBottomSheet<void>(
    context: context,
    title: l10n.workoutBuilderEditMobilityExerciseTitle,
    fullScreen: false,
    bodyBuilder: (sheetContext) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: titleController,
          decoration: InputDecoration(labelText: l10n.mobilityTitle),
          autofocus: false,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: shortTitleController,
          decoration: InputDecoration(labelText: l10n.mobilityShortTitleLabel),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: subtitleController,
          decoration: InputDecoration(labelText: l10n.mobilitySubtitle),
          maxLines: 2,
        ),
      ],
    ),
    primaryActionLabel: l10n.customerSave,
    onPrimaryAction: () {
      onSave(
        titleController.text.trim(),
        subtitleController.text.trim(),
        shortTitleController.text.trim(),
      );
      Navigator.of(context).pop();
    },
  );
}

class MobilityDashedButton extends StatelessWidget {
  const MobilityDashedButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: onPressed != null
              ? StitchM3Theme.accent.withValues(alpha: 0.5)
              : cs.outline.withValues(alpha: 0.35),
          width: 1.2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        ),
        foregroundColor: onPressed != null
            ? StitchM3Theme.accent
            : cs.onSurface.withValues(alpha: 0.72),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
