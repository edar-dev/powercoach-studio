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
    this.emptyHint,
  });

  final TextEditingController controller;
  final AppLocalizations l10n;
  final bool readOnly;

  /// Softer placeholder when the routine has no title yet (e.g. customer name).
  final String? emptyHint;

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

  String get _hintText {
    final custom = widget.emptyHint?.trim();
    if (custom != null && custom.isNotEmpty) return custom;
    return widget.l10n.workoutBuilderRoutineNameHint;
  }

  void _startEditing() {
    if (widget.readOnly) return;
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  TextStyle? _titleStyle(
    ThemeData theme,
    ColorScheme cs, {
    required bool hint,
  }) {
    return theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: hint ? cs.onSurfaceVariant : cs.onSurface,
      fontStyle: FontStyle.normal,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final showField = widget.readOnly || _editing || _hasTitle;
    final hint = _hintText;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, showField ? 4 : 0, 16, 0),
      child: showField
          ? TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              readOnly: widget.readOnly,
              enableInteractiveSelection: !widget.readOnly,
              style: _titleStyle(theme, cs, hint: false),
              maxLines: 1,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _focusNode.unfocus(),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 6),
                border: InputBorder.none,
                hintText: hint,
                hintStyle: _titleStyle(theme, cs, hint: true),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                const iconGap = 6.0;
                const iconSize = 16.0;
                final maxLabelWidth =
                    (constraints.maxWidth - iconGap - iconSize)
                        .clamp(0.0, double.infinity);
                return Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: _startEditing,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxLabelWidth),
                            child: Text(
                              hint,
                              style: _titleStyle(theme, cs, hint: true),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: iconGap),
                          Icon(
                            Icons.edit_outlined,
                            size: iconSize,
                            color: cs.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
