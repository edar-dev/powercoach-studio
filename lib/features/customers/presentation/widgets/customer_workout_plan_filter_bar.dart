import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/stitch_m3_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../workouts/domain/workout_plan_list_helpers.dart';
import '../../../workouts/presentation/workout_plan_display_helpers.dart';

class CustomerWorkoutPlanFilterBar extends StatelessWidget {
  const CustomerWorkoutPlanFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onSearchQueryChanged,
    required this.onFilterChanged,
    this.filters = _defaultFilters,
  });

  static const List<WorkoutPlanFilter> _defaultFilters = [
    WorkoutPlanFilter.all,
    WorkoutPlanFilter.archived,
    WorkoutPlanFilter.active,
    WorkoutPlanFilter.scheduled,
    WorkoutPlanFilter.unscheduled,
    WorkoutPlanFilter.ended,
    WorkoutPlanFilter.stale,
  ];

  final WorkoutPlanFilter selectedFilter;
  final ValueChanged<String> onSearchQueryChanged;
  final ValueChanged<WorkoutPlanFilter> onFilterChanged;
  final List<WorkoutPlanFilter> filters;

  List<Widget> buildSlivers(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: TextField(
            onChanged: onSearchQueryChanged,
            decoration: InputDecoration(
              hintText: l10n.customerWorkoutsSearchHint,
              hintStyle: TextStyle(color: cs.onSurfaceVariant),
              prefixIcon: Icon(
                Icons.search,
                color: cs.onSurfaceVariant,
                size: 22,
              ),
              filled: true,
              fillColor: cs.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = filters[index];
              final selected = filter == selectedFilter;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onFilterChanged(filter);
                  },
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? StitchM3Theme.accent
                          : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      workoutPlanFilterLabel(l10n, filter),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: selected ? Colors.white : cs.onSurface,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(shrinkWrap: true, slivers: buildSlivers(context));
  }
}
