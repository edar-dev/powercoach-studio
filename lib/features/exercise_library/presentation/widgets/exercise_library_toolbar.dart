import 'package:flutter/material.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/ui/widgets/app_search_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/exercise_library_muscle_filter.dart';
import '../../domain/exercise_library_tree_helpers.dart';

enum ExerciseLibraryViewMode { grid, list }

/// Dense search + muscle chips + sort + grid/list toggle (Stitch control bar).
class ExerciseLibraryToolbar extends StatefulWidget {
  const ExerciseLibraryToolbar({
    super.key,
    required this.searchQuery,
    required this.muscleFilter,
    required this.sortMode,
    required this.viewMode,
    required this.onSearchChanged,
    required this.onMuscleFilterSelected,
    required this.onSortChanged,
    required this.onViewModeChanged,
  });

  final String searchQuery;
  final ExerciseLibraryMuscleGroup muscleFilter;
  final ExerciseLibrarySortMode sortMode;
  final ExerciseLibraryViewMode viewMode;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ExerciseLibraryMuscleGroup> onMuscleFilterSelected;
  final ValueChanged<ExerciseLibrarySortMode> onSortChanged;
  final ValueChanged<ExerciseLibraryViewMode> onViewModeChanged;

  @override
  State<ExerciseLibraryToolbar> createState() => _ExerciseLibraryToolbarState();
}

class _ExerciseLibraryToolbarState extends State<ExerciseLibraryToolbar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant ExerciseLibraryToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery &&
        widget.searchQuery != _searchController.text) {
      _searchController.value = TextEditingValue(
        text: widget.searchQuery,
        selection: TextSelection.collapsed(offset: widget.searchQuery.length),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: const BoxDecoration(
        color: MarketingDarkColors.bgAlt,
        border: Border(
          bottom: BorderSide(color: MarketingDarkColors.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AppSearchTextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {});
                    widget.onSearchChanged(value);
                  },
                  style: const TextStyle(
                    color: MarketingDarkColors.text,
                    fontSize: 13,
                  ),
                  cursorColor: MarketingDarkColors.brandLight,
                  clearIconColor: MarketingDarkColors.slate500,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: l10n.exerciseLibrarySearchDenseHint,
                    hintStyle: const TextStyle(
                      color: MarketingDarkColors.slate500,
                      fontSize: 12,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: MarketingDarkColors.slate500,
                      size: 18,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    filled: true,
                    fillColor: MarketingDarkColors.surface900.withValues(
                      alpha: 0.9,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: MarketingDarkColors.border,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: MarketingDarkColors.border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: MarketingDarkColors.brandMid,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<ExerciseLibrarySortMode>(
                tooltip: l10n.exerciseLibrarySortAlphabetical,
                initialValue: widget.sortMode,
                color: MarketingDarkColors.surface800,
                onSelected: widget.onSortChanged,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: ExerciseLibrarySortMode.alphabetical,
                    child: Text(
                      l10n.exerciseLibrarySortAlphabetical,
                      style: const TextStyle(color: MarketingDarkColors.text),
                    ),
                  ),
                  PopupMenuItem(
                    value: ExerciseLibrarySortMode.variantCount,
                    child: Text(
                      l10n.exerciseLibrarySortByVariantCount,
                      style: const TextStyle(color: MarketingDarkColors.text),
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: MarketingDarkColors.surface900.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: MarketingDarkColors.border),
                  ),
                  child: const Icon(
                    Icons.sort,
                    size: 18,
                    color: MarketingDarkColors.slate400,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _ViewToggle(
                viewMode: widget.viewMode,
                onChanged: widget.onViewModeChanged,
                gridTooltip: l10n.exerciseLibraryViewGrid,
                listTooltip: l10n.exerciseLibraryViewList,
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final group in ExerciseLibraryMuscleGroup.values) ...[
                  if (group != ExerciseLibraryMuscleGroup.all)
                    const SizedBox(width: 8),
                  _MuscleChip(
                    label: _muscleLabel(l10n, group),
                    selected: widget.muscleFilter == group,
                    onSelected: () => widget.onMuscleFilterSelected(group),
                    theme: theme,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _muscleLabel(AppLocalizations l10n, ExerciseLibraryMuscleGroup g) {
    return switch (g) {
      ExerciseLibraryMuscleGroup.all => l10n.exerciseLibraryMuscleAll,
      ExerciseLibraryMuscleGroup.chest => l10n.exerciseLibraryMuscleChest,
      ExerciseLibraryMuscleGroup.back => l10n.exerciseLibraryMuscleBack,
      ExerciseLibraryMuscleGroup.legs => l10n.exerciseLibraryMuscleLegs,
      ExerciseLibraryMuscleGroup.shoulders =>
        l10n.exerciseLibraryMuscleShoulders,
      ExerciseLibraryMuscleGroup.arms => l10n.exerciseLibraryMuscleArms,
      ExerciseLibraryMuscleGroup.core => l10n.exerciseLibraryMuscleCore,
    };
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({
    required this.viewMode,
    required this.onChanged,
    required this.gridTooltip,
    required this.listTooltip,
  });

  final ExerciseLibraryViewMode viewMode;
  final ValueChanged<ExerciseLibraryViewMode> onChanged;
  final String gridTooltip;
  final String listTooltip;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MarketingDarkColors.surface900.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: MarketingDarkColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleIcon(
            icon: Icons.grid_view_rounded,
            selected: viewMode == ExerciseLibraryViewMode.grid,
            tooltip: gridTooltip,
            onTap: () => onChanged(ExerciseLibraryViewMode.grid),
          ),
          _ToggleIcon(
            icon: Icons.view_list_rounded,
            selected: viewMode == ExerciseLibraryViewMode.list,
            tooltip: listTooltip,
            onTap: () => onChanged(ExerciseLibraryViewMode.list),
          ),
        ],
      ),
    );
  }
}

class _ToggleIcon extends StatelessWidget {
  const _ToggleIcon({
    required this.icon,
    required this.selected,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: selected
                ? MarketingDarkColors.brand.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(
            icon,
            size: 18,
            color: selected
                ? MarketingDarkColors.brandLight
                : MarketingDarkColors.slate400,
          ),
        ),
      ),
    );
  }
}

class _MuscleChip extends StatelessWidget {
  const _MuscleChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    required this.theme,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: selected ? Colors.white : MarketingDarkColors.slate300,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
      selectedColor: MarketingDarkColors.brand,
      backgroundColor: MarketingDarkColors.surface800,
      side: BorderSide(
        color: selected
            ? MarketingDarkColors.brand
            : MarketingDarkColors.border,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
