import 'package:flutter/material.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/ui/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/custom_exercise_item.dart';
import '../../domain/exercise_library_muscle_filter.dart';
import '../../domain/exercise_library_tree_helpers.dart';
import 'exercise_library_card.dart';
import 'exercise_library_list_tile.dart';
import 'exercise_library_toolbar.dart';

const int kExerciseLibraryPageSize = 12;

class ExerciseLibraryTabView extends StatefulWidget {
  const ExerciseLibraryTabView({
    super.key,
    required this.isMobility,
    required this.loading,
    required this.error,
    required this.allItemsEmpty,
    required this.onRefresh,
    required this.buildList,
    required this.searchQuery,
    required this.muscleFilter,
    required this.sortMode,
    required this.viewMode,
    required this.onEdit,
    required this.onDelete,
    required this.onAddVariant,
    required this.onTogglePin,
    required this.isPinned,
  });

  final bool isMobility;
  final bool loading;
  final String? error;
  final bool allItemsEmpty;

  final Future<void> Function() onRefresh;
  final List<CustomExerciseItem> Function() buildList;

  final String searchQuery;
  final ExerciseLibraryMuscleGroup muscleFilter;
  final ExerciseLibrarySortMode sortMode;
  final ExerciseLibraryViewMode viewMode;

  final void Function(CustomExerciseItem item) onEdit;
  final void Function(CustomExerciseItem item) onDelete;
  final void Function(CustomExerciseItem item) onAddVariant;
  final void Function(CustomExerciseItem item) onTogglePin;
  final bool Function(CustomExerciseItem item) isPinned;

  @override
  State<ExerciseLibraryTabView> createState() => _ExerciseLibraryTabViewState();
}

class _ExerciseLibraryTabViewState extends State<ExerciseLibraryTabView> {
  int _page = 0;

  @override
  void didUpdateWidget(covariant ExerciseLibraryTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.muscleFilter != widget.muscleFilter ||
        oldWidget.sortMode != widget.sortMode ||
        oldWidget.viewMode != widget.viewMode ||
        oldWidget.isMobility != widget.isMobility ||
        oldWidget.loading != widget.loading) {
      _page = 0;
    }
  }

  List<CustomExerciseItem> _filteredRoots() {
    final roots = widget.buildList();
    final queried = filterExerciseTreeByQuery(roots, widget.searchQuery);
    final muscled = filterExerciseRootsByMuscle(queried, widget.muscleFilter);
    return sortExerciseTree(
      muscled,
      mode: widget.sortMode,
      isPinned: widget.isPinned,
    );
  }

  void _onCardAdd(CustomExerciseItem item) {
    if (item.children.isNotEmpty) {
      widget.onAddVariant(item);
    } else {
      widget.onEdit(item);
    }
  }

  int _gridColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.desktop) return 3;
    if (width >= AppBreakpoints.tablet) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: MarketingDarkColors.brandLight,
      backgroundColor: MarketingDarkColors.surface,
      child: widget.error != null
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 48),
                Text(
                  widget.error!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: FilledButton(
                    onPressed: widget.onRefresh,
                    child: Text(l10n.exerciseLibraryRetry),
                  ),
                ),
              ],
            )
          : widget.loading && widget.allItemsEmpty
              ? const Center(child: CircularProgressIndicator())
              : Builder(
                  builder: (context) {
                    final list = _filteredRoots();
                    if (list.isEmpty) {
                      final hasSearch = widget.searchQuery.trim().isNotEmpty;
                      final hasMuscleFilter = widget.muscleFilter !=
                          ExerciseLibraryMuscleGroup.all;
                      final hasFilter = hasSearch || hasMuscleFilter;
                      final emptyLabel = hasSearch
                          ? l10n.searchNoResults
                          : hasMuscleFilter
                              ? l10n.exerciseLibrarySearchEmpty
                              : (widget.isMobility
                                  ? l10n.exerciseLibraryEmptyMobility
                                  : l10n.exerciseLibraryEmpty);
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(32),
                        children: [
                          const SizedBox(height: 48),
                          Icon(
                            hasFilter
                                ? Icons.search_off_rounded
                                : Icons.fitness_center_outlined,
                            size: 64,
                            color: cs.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            emptyLabel,
                            style: theme.textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          if (!hasFilter) ...[
                            const SizedBox(height: 8),
                            Text(
                              widget.isMobility
                                  ? l10n.exerciseLibraryEmptyMobilityHint
                                  : l10n.exerciseLibraryEmptyHint,
                              style: theme.textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      );
                    }

                    final pageCount =
                        (list.length / kExerciseLibraryPageSize)
                            .ceil()
                            .clamp(1, 0x7fffffff);
                    final page = _page.clamp(0, pageCount - 1);
                    final start = page * kExerciseLibraryPageSize;
                    final end =
                        (start + kExerciseLibraryPageSize).clamp(0, list.length);
                    final pageItems = list.sublist(start, end);

                    if (widget.viewMode == ExerciseLibraryViewMode.list) {
                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ).copyWith(bottom: 112),
                        itemCount: pageItems.length + 1,
                        itemBuilder: (context, index) {
                          if (index == pageItems.length) {
                            return _PaginationFooter(
                              from: start + 1,
                              to: end,
                              total: list.length,
                              page: page,
                              pageCount: pageCount,
                              onPrev: page > 0
                                  ? () => setState(() => _page = page - 1)
                                  : null,
                              onNext: page < pageCount - 1
                                  ? () => setState(() => _page = page + 1)
                                  : null,
                            );
                          }
                          final it = pageItems[index];
                          return ExerciseLibraryListTile(
                            item: it,
                            isPinned: widget.isPinned,
                            onEdit: widget.onEdit,
                            onDelete: widget.onDelete,
                            onAddVariant: widget.onAddVariant,
                            onTogglePin: widget.onTogglePin,
                          );
                        },
                      );
                    }

                    final columns = _gridColumns(context);
                    return CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: columns == 1 ? 1.15 : 0.78,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final it = pageItems[index];
                                return ExerciseLibraryCard(
                                  item: it,
                                  isPinned: widget.isPinned(it),
                                  onDetails: () => widget.onEdit(it),
                                  onAdd: () => _onCardAdd(it),
                                  onDelete: () => widget.onDelete(it),
                                  onTogglePin: () => widget.onTogglePin(it),
                                  onEdit: () => widget.onEdit(it),
                                );
                              },
                              childCount: pageItems.length,
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 112),
                            child: _PaginationFooter(
                              from: start + 1,
                              to: end,
                              total: list.length,
                              page: page,
                              pageCount: pageCount,
                              onPrev: page > 0
                                  ? () => setState(() => _page = page - 1)
                                  : null,
                              onNext: page < pageCount - 1
                                  ? () => setState(() => _page = page + 1)
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({
    required this.from,
    required this.to,
    required this.total,
    required this.page,
    required this.pageCount,
    required this.onPrev,
    required this.onNext,
  });

  final int from;
  final int to;
  final int total;
  final int page;
  final int pageCount;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: MarketingDarkColors.surface900.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: MarketingDarkColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l10n.exerciseLibraryPaginationRange(from, to, total),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: MarketingDarkColors.slate300,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              tooltip: l10n.exerciseLibraryPaginationPrev,
              icon: const Icon(Icons.chevron_left, size: 20),
              visualDensity: VisualDensity.compact,
              onPressed: onPrev,
            ),
            Text(
              '${page + 1}/$pageCount',
              style: theme.textTheme.labelSmall?.copyWith(
                color: MarketingDarkColors.slate400,
              ),
            ),
            IconButton(
              tooltip: l10n.exerciseLibraryPaginationNext,
              icon: const Icon(Icons.chevron_right, size: 20),
              visualDensity: VisualDensity.compact,
              onPressed: onNext,
            ),
          ],
        ),
      ),
    );
  }
}
