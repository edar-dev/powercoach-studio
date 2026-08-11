import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

/// Optional post-session check-in: session RPE and pain level/location.
/// Tapping a selected chip again clears that value (fully skippable).
///
/// Shared between the [session_log_sheet] modal and the gym-mode runner.
class SessionCheckInSection extends StatelessWidget {
  const SessionCheckInSection({
    super.key,
    required this.l10n,
    required this.sessionRpe,
    required this.painLevel,
    required this.painLocationController,
    required this.onSessionRpeChanged,
    required this.onPainLevelChanged,
  });

  final AppLocalizations l10n;
  final int? sessionRpe;
  final int? painLevel;
  final TextEditingController painLocationController;
  final ValueChanged<int?> onSessionRpeChanged;
  final ValueChanged<int?> onPainLevelChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.sessionLogCheckInTitle,
          style: theme.textTheme.labelLarge?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(l10n.sessionLogRpeLabel, style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        _ScaleChipRow(
          min: 1,
          max: 10,
          value: sessionRpe,
          onChanged: onSessionRpeChanged,
        ),
        const SizedBox(height: 12),
        Text(l10n.sessionLogPainLabel, style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        _ScaleChipRow(
          min: 0,
          max: 10,
          value: painLevel,
          onChanged: onPainLevelChanged,
        ),
        if (painLevel != null && painLevel! > 0) ...[
          const SizedBox(height: 8),
          TextField(
            controller: painLocationController,
            decoration: InputDecoration(
              hintText: l10n.sessionLogPainLocationHint,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ScaleChipRow extends StatelessWidget {
  const _ScaleChipRow({
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
  });

  final int min;
  final int max;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var i = min; i <= max; i++)
          ChoiceChip(
            label: Text('$i'),
            selected: value == i,
            onSelected: (selected) => onChanged(selected ? i : null),
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
      ],
    );
  }
}
