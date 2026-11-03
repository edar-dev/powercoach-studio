import 'package:flutter/material.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/custom_exercise_item.dart';

/// Grid card for a root exercise family (placeholder media + actions).
class ExerciseLibraryCard extends StatelessWidget {
  const ExerciseLibraryCard({
    super.key,
    required this.item,
    required this.isPinned,
    required this.onDetails,
    required this.onAdd,
    required this.onDelete,
    required this.onTogglePin,
    this.onEdit,
  });

  final CustomExerciseItem item;
  final bool isPinned;
  final VoidCallback onDetails;
  final VoidCallback onAdd;
  final VoidCallback onDelete;
  final VoidCallback onTogglePin;

  /// Optional explicit edit; defaults to [onDetails] when null.
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final hasChildren = item.children.isNotEmpty;
    final description = item.description?.trim();
    final subtitle = (description != null && description.isNotEmpty)
        ? description
        : l10n.exerciseLibraryVariantCount(item.children.length);

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: MarketingDarkColors.stitchCard,
          borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
          border: Border.all(color: MarketingDarkColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A243A),
                      Color(0xFF0F172A),
                      Color(0xFF11192B),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    hasChildren
                        ? Icons.folder_outlined
                        : Icons.fitness_center,
                    size: 40,
                    color: MarketingDarkColors.slate500,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: MarketingDarkColors.text,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.more_vert,
                            size: 18,
                            color: MarketingDarkColors.slate400,
                          ),
                          color: MarketingDarkColors.surface800,
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'pin',
                              child: Text(
                                isPinned
                                    ? l10n.exerciseLibraryUnpin
                                    : l10n.exerciseLibraryPin,
                                style: const TextStyle(
                                  color: MarketingDarkColors.text,
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'edit',
                              child: Text(
                                l10n.exerciseLibraryEdit,
                                style: const TextStyle(
                                  color: MarketingDarkColors.text,
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                l10n.exerciseLibraryDelete,
                                style: const TextStyle(
                                  color: MarketingDarkColors.text,
                                ),
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'pin') onTogglePin();
                            if (value == 'edit') (onEdit ?? onDetails)();
                            if (value == 'delete') onDelete();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: MarketingDarkColors.slate400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: onDetails,
                          style: TextButton.styleFrom(
                            foregroundColor: MarketingDarkColors.slate300,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          icon: const Icon(Icons.visibility_outlined, size: 14),
                          label: Text(l10n.exerciseLibraryDetails),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: onAdd,
                          style: FilledButton.styleFrom(
                            backgroundColor: MarketingDarkColors.brand,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: Text('+ ${l10n.exerciseLibraryAddShort}'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
