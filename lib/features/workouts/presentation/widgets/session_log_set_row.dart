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
  });

  final int setIndex;
  final String reps;
  final String load;
  final bool completed;
  final AppLocalizations l10n;
  final ValueChanged<String> onRepsChanged;
  final ValueChanged<String> onLoadChanged;
  final ValueChanged<bool> onCompletedChanged;

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

    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                widget.l10n.sessionLogSetLabel(widget.setIndex + 1),
                style: theme.textTheme.labelMedium,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: widget.l10n.sessionLogSetReps,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
                ),
              ),
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
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
                ),
              ),
              controller: _loadController,
              onChanged: widget.onLoadChanged,
            ),
          ),
          Checkbox(
            value: widget.completed,
            onChanged: (value) => widget.onCompletedChanged(value ?? false),
          ),
        ],
      ),
    );
  }
}
