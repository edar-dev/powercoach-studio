import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/stitch_m3_theme.dart';
import '../../../../core/ui/widgets/app_search_field.dart';
import '../../../../core/ui/widgets/horizontal_fade_scroller.dart';
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
          child: _PlanSearchField(
            hintText: l10n.customerWorkoutsSearchHint,
            onChanged: onSearchQueryChanged,
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: HorizontalFadeScroller(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              for (var index = 0; index < filters.length; index++) ...[
                if (index > 0) const SizedBox(width: 8),
                Builder(
                  builder: (context) {
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
              ],
            ],
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

class _PlanSearchField extends StatefulWidget {
  const _PlanSearchField({
    required this.hintText,
    required this.onChanged,
  });

  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  State<_PlanSearchField> createState() => _PlanSearchFieldState();
}

class _PlanSearchFieldState extends State<_PlanSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppSearchTextField(
      controller: _controller,
      onChanged: (value) {
        setState(() {});
        widget.onChanged(value);
      },
      clearIconColor: cs.onSurfaceVariant,
      decoration: InputDecoration(
        hintText: widget.hintText,
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
    );
  }
}
