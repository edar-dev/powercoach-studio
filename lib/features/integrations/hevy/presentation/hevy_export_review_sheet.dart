import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../theme/stitch_m3_theme.dart';
import '../../../exercise_library/data/custom_exercise_item.dart';
import '../../../exercise_library/data/custom_exercise_repository.dart';
import '../../../workouts/data/workout_routine_model.dart';
import '../data/hevy_exercise_mapping_repository.dart';
import '../domain/hevy_exercise_resolver.dart';
import '../domain/hevy_export_day_usecase.dart';
import '../domain/exercise_catalog_source.dart';

/// Review unmapped exercises and confirm Hevy export.
Future<bool?> showHevyExportReviewSheet({
  required BuildContext context,
  required Day day,
  required String programName,
  int? weekIndex,
  int? dayIndex,
  String? customerName,
}) {
  final l10n = AppLocalizations.of(context);
  final cs = Theme.of(context).colorScheme;

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: cs.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(StitchM3Theme.radiusXl)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.hevyExportSheetTitle,
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _HevyExportReviewBody(
                day: day,
                programName: programName,
                weekIndex: weekIndex,
                dayIndex: dayIndex,
                customerName: customerName,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _HevyExportReviewBody extends StatefulWidget {
  const _HevyExportReviewBody({
    required this.day,
    required this.programName,
    this.weekIndex,
    this.dayIndex,
    this.customerName,
  });

  final Day day;
  final String programName;
  final int? weekIndex;
  final int? dayIndex;
  final String? customerName;

  @override
  State<_HevyExportReviewBody> createState() => _HevyExportReviewBodyState();
}

class _HevyExportReviewBodyState extends State<_HevyExportReviewBody> {
  final _resolver = HevyExerciseResolver();
  final _export = HevyExportDayUseCase();
  final _mappingRepo = HevyExerciseMappingRepository();
  final _exerciseRepo = CustomExerciseRepository();

  Map<String, HevyResolvedExercise> _resolved = {};
  bool _loading = true;
  bool _exporting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final resolved = await _resolver.resolveDay(widget.day);
    if (!mounted) return;
    setState(() {
      _resolved = resolved;
      _loading = false;
    });
  }

  List<HevyResolvedExercise> get _unmapped =>
      _resolved.values.where((r) => !r.isMapped).toList();

  Future<void> _pickHevyTemplate(HevyResolvedExercise row) async {
    final l10n = AppLocalizations.of(context);
    final leaves = (await _exerciseRepo.getTree(catalogSource: ExerciseCatalogSource.hevy))
        .expand((r) => r.flat)
        .where((e) => e.isHevyLeaf)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    if (!mounted) return;
    if (leaves.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.hevyExportNoCatalogHint)),
      );
      return;
    }

    final picked = await showModalBottomSheet<CustomExerciseItem>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.6,
            child: ListView.builder(
              itemCount: leaves.length,
              itemBuilder: (_, i) {
                final item = leaves[i];
                return ListTile(
                  title: Text(item.name),
                  onTap: () => Navigator.pop(ctx, item),
                );
              },
            ),
          ),
        );
      },
    );

    if (picked?.hevyTemplateId == null) return;
    await _mappingRepo.saveMapping(row.exerciseId, picked!.hevyTemplateId!);
    await _load();
  }

  Future<void> _runExport() async {
    final l10n = AppLocalizations.of(context);
    if (_unmapped.isNotEmpty) {
      setState(() => _error = l10n.hevyExportUnmappedBlock);
      return;
    }
    setState(() {
      _exporting = true;
      _error = null;
    });
    final result = await _export.execute(
      day: widget.day,
      programName: widget.programName,
      weekIndex: widget.weekIndex,
      dayIndex: widget.dayIndex,
      customerName: widget.customerName,
    );
    if (!mounted) return;
    if (result.success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.hevyExportSuccess)),
      );
    } else {
      setState(() {
        _exporting = false;
        _error = result.errorMessage ?? l10n.hevyExportError;
      });
      if (result.unmapped.isNotEmpty) {
        await _load();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final unmapped = _unmapped;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (unmapped.isEmpty)
          Text(l10n.hevyExportAllMapped)
        else
          Text(l10n.hevyExportUnmappedIntro(unmapped.length)),
        const SizedBox(height: 12),
        ...unmapped.map(
          (r) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(r.exerciseName),
            trailing: TextButton(
              onPressed: _exporting ? null : () => _pickHevyTemplate(r),
              child: Text(l10n.hevyExportMapExercise),
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
          ),
        ],
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _exporting ? null : _runExport,
          child: _exporting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.hevyExportConfirm),
        ),
      ],
    );
  }
}
