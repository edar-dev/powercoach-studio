import 'package:flutter/material.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

/// Compact routine title field. Collapses to a single hint line when empty
/// until the user taps to edit (or when [readOnly]).
class WorkoutRoutineNameBar extends StatefulWidget {
  const WorkoutRoutineNameBar({
    super.key,
    required this.controller,
    required this.l10n,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final AppLocalizations l10n;
  final bool readOnly;

  @override
  State<WorkoutRoutineNameBar> createState() => _WorkoutRoutineNameBarState();
}

class _WorkoutRoutineNameBarState extends State<WorkoutRoutineNameBar> {
  late final FocusNode _focusNode;
  var _editing = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant WorkoutRoutineNameBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus && mounted) {
      setState(() => _editing = false);
    }
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  bool get _hasTitle => widget.controller.text.trim().isNotEmpty;

  void _startEditing() {
    if (widget.readOnly) return;
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final showField = widget.readOnly || _editing || _hasTitle;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: showField
          ? TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              readOnly: widget.readOnly,
              enableInteractiveSelection: !widget.readOnly,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
              maxLines: 1,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _focusNode.unfocus(),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 6),
                border: InputBorder.none,
                hintText: widget.l10n.workoutBuilderRoutineNameHint,
                hintStyle: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface.withValues(alpha: 0.72),
                ),
              ),
            )
          : InkWell(
              onTap: _startEditing,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  widget.l10n.workoutBuilderRoutineNameHint,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface.withValues(alpha: 0.72),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
    );
  }
}
