import 'package:flutter/material.dart';

import '../../../../core/theme/stitch_m3_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/workout_plan_api_model.dart';

typedef WorkoutPlanTemplateTileBuilder =
    Widget Function(BuildContext context, WorkoutPlanApiModel template);

class WorkoutPlanTemplateSearchBar extends StatelessWidget {
  const WorkoutPlanTemplateSearchBar({
    super.key,
    required this.onSearchQueryChanged,
  });

  final ValueChanged<String> onSearchQueryChanged;

  SliverToBoxAdapter buildSliver(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: TextField(
          onChanged: onSearchQueryChanged,
          decoration: InputDecoration(
            hintText: l10n.workoutTemplatesSearchHint,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(shrinkWrap: true, slivers: [buildSliver(context)]);
  }
}

class WorkoutPlanTemplateList extends StatelessWidget {
  const WorkoutPlanTemplateList({
    super.key,
    required this.templates,
    required this.onSearchQueryChanged,
    required this.tileBuilder,
    required this.semanticLabel,
  });

  final List<WorkoutPlanApiModel> templates;
  final ValueChanged<String> onSearchQueryChanged;
  final WorkoutPlanTemplateTileBuilder tileBuilder;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final searchBar = WorkoutPlanTemplateSearchBar(
      onSearchQueryChanged: onSearchQueryChanged,
    );
    return Semantics(
      container: true,
      label: semanticLabel,
      explicitChildNodes: true,
      child: CustomScrollView(
        slivers: [
          searchBar.buildSliver(context),
          if (templates.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.workoutTemplatesNoMatch,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index.isOdd) return const SizedBox(height: 12);
                  return tileBuilder(context, templates[index ~/ 2]);
                }, childCount: templates.length * 2 - 1),
              ),
            ),
        ],
      ),
    );
  }
}

class WorkoutPlanTemplateEmptyState extends StatelessWidget {
  const WorkoutPlanTemplateEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_outline,
              size: 64,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.workoutTemplatesEmpty,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
