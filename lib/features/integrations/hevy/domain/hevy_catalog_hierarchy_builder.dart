import '../data/hevy_api_models.dart';

/// Builds a hierarchical import list from flat Hevy exercise templates.
class HevyCatalogHierarchyBuilder {
  static const _mobilityTypes = {'duration', 'distance_duration', 'steps'};

  /// Muscle group sort order for folder roots.
  static const _muscleOrder = [
    'chest',
    'back',
    'shoulders',
    'biceps',
    'triceps',
    'forearms',
    'abs',
    'quads',
    'hamstrings',
    'glutes',
    'calves',
    'cardio',
    'other',
  ];

  /// Returns nodes in parent-before-child order (folders first, then leaves).
  List<HevyCatalogImportNode> build(List<HevyExerciseTemplateDto> templates) {
    if (templates.isEmpty) return const [];

    final nodes = <HevyCatalogImportNode>[];
    final byMuscle = <String, List<HevyExerciseTemplateDto>>{};

    for (final t in templates) {
      if (t.id.isEmpty || t.title.trim().isEmpty) continue;
      final muscle = _normalizeMuscle(t);
      byMuscle.putIfAbsent(muscle, () => []).add(t);
    }

    final muscles = byMuscle.keys.toList()
      ..sort((a, b) {
        final ia = _muscleOrder.indexOf(a);
        final ib = _muscleOrder.indexOf(b);
        final sa = ia >= 0 ? ia : 999;
        final sb = ib >= 0 ? ib : 999;
        if (sa != sb) return sa.compareTo(sb);
        return a.compareTo(b);
      });

    var muscleSort = 0;
    for (final muscle in muscles) {
      final groupKey = 'hevy_grp_$muscle';
      nodes.add(
        HevyCatalogImportNode(
          stableKey: groupKey,
          name: _muscleDisplayName(muscle),
          sortOrder: muscleSort++,
          isFolder: true,
        ),
      );

      final inMuscle = byMuscle[muscle]!..sort((a, b) => a.title.compareTo(b.title));
      final byBase = <String, List<HevyExerciseTemplateDto>>{};

      for (final t in inMuscle) {
        final parsed = _parseTitle(t.title);
        byBase.putIfAbsent(parsed.baseName, () => []).add(t);
      }

      var leafSort = 0;
      for (final entry in byBase.entries) {
        final baseName = entry.key;
        final group = entry.value;
        final useFamily = group.length >= 2 && group.any((t) => _parseTitle(t.title).hasVariant);

        String? familyKey;
        if (useFamily) {
          familyKey = 'hevy_fam_${muscle}_${_slug(baseName)}';
          nodes.add(
            HevyCatalogImportNode(
              stableKey: familyKey,
              name: baseName,
              parentStableKey: groupKey,
              sortOrder: leafSort++,
              isFolder: true,
            ),
          );
        }

        for (final t in group) {
          final isMobility = _isMobilityTemplate(t);
          nodes.add(
            HevyCatalogImportNode(
              stableKey: t.id,
              name: t.title.trim(),
              parentStableKey: familyKey ?? groupKey,
              hevyTemplateId: t.id,
              sortOrder: leafSort++,
              isMobility: isMobility,
              isFolder: false,
            ),
          );
        }
      }
    }

    return nodes;
  }

  static String _normalizeMuscle(HevyExerciseTemplateDto t) {
    if (t.isCustom) return 'custom';
    final raw = t.primaryMuscleGroup?.trim().toLowerCase();
    if (raw == null || raw.isEmpty) return 'other';
    return raw.replaceAll(' ', '_');
  }

  static bool _isMobilityTemplate(HevyExerciseTemplateDto t) {
    final type = t.type?.toLowerCase() ?? '';
    return _mobilityTypes.contains(type);
  }

  static String _muscleDisplayName(String key) {
    switch (key) {
      case 'chest':
        return 'Chest';
      case 'back':
        return 'Back';
      case 'shoulders':
        return 'Shoulders';
      case 'biceps':
        return 'Biceps';
      case 'triceps':
        return 'Triceps';
      case 'forearms':
        return 'Forearms';
      case 'abs':
        return 'Abs';
      case 'quads':
        return 'Quads';
      case 'hamstrings':
        return 'Hamstrings';
      case 'glutes':
        return 'Glutes';
      case 'calves':
        return 'Calves';
      case 'cardio':
        return 'Cardio';
      case 'custom':
        return 'Custom (Hevy)';
      default:
        return key
            .split('_')
            .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
            .join(' ');
    }
  }

  static String _slug(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  static ({String baseName, bool hasVariant}) _parseTitle(String title) {
    final match = RegExp(r'^(.+?)\s*\(([^)]+)\)\s*$').firstMatch(title.trim());
    if (match != null) {
      return (baseName: match.group(1)!.trim(), hasVariant: true);
    }
    return (baseName: title.trim(), hasVariant: false);
  }
}
