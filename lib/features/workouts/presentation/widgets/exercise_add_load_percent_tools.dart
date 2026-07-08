import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../customers/data/models/customer_exercise_record.dart';
import '../../domain/exercise_load_percent_helpers.dart';

class ExerciseAddLoadPercentTools extends StatefulWidget {
  const ExerciseAddLoadPercentTools({
    super.key,
    required this.record,
  });

  final CustomerExerciseRecord record;

  @override
  State<ExerciseAddLoadPercentTools> createState() =>
      _ExerciseAddLoadPercentToolsState();
}

class _ExerciseAddLoadPercentToolsState extends State<ExerciseAddLoadPercentTools> {
  final _loadPercentInputController = TextEditingController();

  @override
  void dispose() {
    _loadPercentInputController.dispose();
    super.dispose();
  }

  String _loadPercentResultLabel(AppLocalizations l10n, CustomerExerciseRecord r) {
    final raw = _loadPercentInputController.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return '—';
    final p = double.tryParse(raw);
    if (p == null || p <= 0 || p > 100) {
      return l10n.workoutBuilderLoadPercentInvalid;
    }
    final load = r.value * p / 100.0;
    final w = formatExerciseLoadForDisplay(load);
    final percentStr = (p - p.round()).abs() < 1e-9
        ? p.round().toString()
        : formatExerciseLoadForDisplay(p);
    return l10n.workoutBuilderLoadPercentResult(w, r.unit, percentStr);
  }

  Widget _buildGuideContent(
    ThemeData theme,
    ColorScheme cs,
    AppLocalizations l10n,
    CustomerExerciseRecord r,
    bool mass,
  ) {
    if (mass) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final p in kExerciseLoadPercentLadder)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                l10n.workoutBuilderLoadPercentGuideRow(
                  p.toString(),
                  formatExerciseLoadForDisplay(r.value * p / 100.0),
                  r.unit,
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  height: 1.45,
                  color: cs.onSurface,
                ),
              ),
            ),
        ],
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        l10n.workoutBuilderLoadPercentGuideBody,
        style: theme.textTheme.bodySmall?.copyWith(
          height: 1.45,
          color: cs.onSurface,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final r = widget.record;
    final mass = isMassBasedExerciseRecordUnit(r.unit);
    final denseDecoration = InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: const OutlineInputBorder(),
    );

    return Card(
      margin: EdgeInsets.zero,
      color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 8),
                title: Text(
                  l10n.workoutBuilderLoadPercentGuideTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  mass
                      ? l10n.workoutBuilderLoadPercentGuideIntroMass
                      : l10n.workoutBuilderLoadPercentGuideIntroReps,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                children: [_buildGuideContent(theme, cs, l10n, r, mass)],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Text(
              l10n.workoutBuilderLoadPercentCalculator,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (mass)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _loadPercentInputController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: denseDecoration.copyWith(
                        labelText: l10n.workoutBuilderLoadPercentFieldLabel,
                        hintText: l10n.workoutBuilderLoadPercentFieldHint,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _loadPercentResultLabel(l10n, r),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              Text(
                l10n.workoutBuilderLoadPercentMassOnly,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ExerciseAddCustomerRecordPanel extends StatelessWidget {
  const ExerciseAddCustomerRecordPanel({
    super.key,
    required this.loading,
    required this.records,
  });

  final bool loading;
  final List<CustomerExerciseRecord> records;

  static Widget recordLine(
    ThemeData theme,
    ColorScheme cs,
    CustomerExerciseRecord record,
  ) {
    final dateStr =
        '${record.recordedAt.day.toString().padLeft(2, '0')}/${record.recordedAt.month.toString().padLeft(2, '0')}/${record.recordedAt.year}';
    return Text(
      '${record.value} ${record.unit} · $dateStr${record.note != null && record.note!.isNotEmpty ? ' · ${record.note}' : ''}',
      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurface),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.workoutBuilderClientRecord,
          style: theme.textTheme.labelMedium?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (records.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              l10n.workoutBuilderNoExerciseRecord,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                recordLine(theme, cs, records.first),
                const SizedBox(height: 10),
                ExerciseAddLoadPercentTools(record: records.first),
              ],
            ),
          ),
      ],
    );
  }
}
