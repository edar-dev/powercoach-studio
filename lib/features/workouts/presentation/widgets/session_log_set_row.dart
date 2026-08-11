import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

/// One editable set row (reps + load) in the session log sheet.
class SessionLogSetRow extends StatefulWidget {
  const SessionLogSetRow({
    super.key,
    required this.setIndex,
    required this.reps,
    required this.load,
    required this.completed,
    required this.l10n,
    required this.onRepsChanged,
    required this.onLoadChanged,
    required this.onCompletedChanged,
    this.compact = true,
  });

  final int setIndex;
  final String reps;
  final String load;
  final bool completed;
  final AppLocalizations l10n;
  final ValueChanged<String> onRepsChanged;
  final ValueChanged<String> onLoadChanged;
  final ValueChanged<bool> onCompletedChanged;

  /// When false, renders larger (48dp+) touch targets for gym-mode use —
  /// no dense text fields, taller row, bigger checkbox tap area.
  final bool compact;

  @override
  State<SessionLogSetRow> createState() => _SessionLogSetRowState();
}

class _SessionLogSetRowState extends State<SessionLogSetRow> {
  late final TextEditingController _repsController;
  late final TextEditingController _loadController;

  @override
  void initState() {
    super.initState();
    _repsController = TextEditingController(text: widget.reps);
    _loadController = TextEditingController(text: widget.load);
  }

  @override
  void didUpdateWidget(covariant SessionLogSetRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reps != widget.reps && _repsController.text != widget.reps) {
      _repsController.text = widget.reps;
    }
    if (oldWidget.load != widget.load && _loadController.text != widget.load) {
      _loadController.text = widget.load;
    }
  }

  @override
  void dispose() {
    _repsController.dispose();
    _loadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compact = widget.compact;

    return Padding(
      padding: EdgeInsets.only(left: 8, bottom: compact ? 8 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: compact ? 52 : 64,
            child: Padding(
              padding: EdgeInsets.only(top: compact ? 14 : 18),
              child: Text(
                widget.l10n.sessionLogSetLabel(widget.setIndex + 1),
                style: compact
                    ? theme.textTheme.labelMedium
                    : theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
              ),
            ),
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: widget.l10n.sessionLogSetReps,
                isDense: compact,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
                ),
              ),
              style: compact ? null : theme.textTheme.titleMedium,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: _repsController,
              onChanged: widget.onRepsChanged,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: widget.l10n.sessionLogSetLoad,
                isDense: compact,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
                ),
              ),
              style: compact ? null : theme.textTheme.titleMedium,
              controller: _loadController,
              onChanged: widget.onLoadChanged,
            ),
          ),
          SizedBox(
            width: compact ? 40 : 48,
            height: compact ? 40 : 48,
            child: Checkbox(
              value: widget.completed,
              onChanged: (value) => widget.onCompletedChanged(value ?? false),
            ),
          ),
        ],
      ),
    );
  }
}
