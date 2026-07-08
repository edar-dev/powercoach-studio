import '../../../l10n/app_localizations.dart';
import '../domain/workout_template_list_helpers.dart';

String templateSortLabel(AppLocalizations l10n, TemplateSort sort) {
  switch (sort) {
    case TemplateSort.nameAsc:
      return l10n.workoutTemplatesSortNameAsc;
    case TemplateSort.updatedDesc:
      return l10n.workoutTemplatesSortUpdatedDesc;
    case TemplateSort.weekCountDesc:
      return l10n.workoutTemplatesSortWeekCountDesc;
  }
}
