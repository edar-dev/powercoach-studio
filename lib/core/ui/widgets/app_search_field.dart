import 'package:flutter/material.dart';

import 'keyboard_dismiss.dart';

/// Shared search [TextField] helpers (clear + search action + dismiss).
///
/// Prefer decorating existing toolbars with these helpers rather than forcing
/// a single visual style across MarketingDark / StitchMobile surfaces.
class AppSearchField {
  AppSearchField._();

  /// Clear suffix when [visible]; otherwise null.
  static Widget? clearIconButton({
    required bool visible,
    required VoidCallback onClear,
    String? tooltip,
    Color? iconColor,
    double iconSize = 18,
  }) {
    if (!visible) return null;
    return IconButton(
      tooltip: tooltip,
      icon: Icon(Icons.clear, size: iconSize, color: iconColor),
      onPressed: onClear,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      padding: EdgeInsets.zero,
    );
  }

  /// Standard search submit: unfocus keyboard.
  static void onSubmitted(String _) => KeyboardDismiss.unfocus();
}

/// Thin wrapper applying search conventions to a [TextField].
///
/// Keeps decoration ownership with the caller via [decoration] while enforcing
/// [TextInputAction.search], clear suffix, and keyboard dismiss on submit.
class AppSearchTextField extends StatefulWidget {
  const AppSearchTextField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.decoration,
    this.style,
    this.cursorColor,
    this.clearIconColor,
    this.clearTooltip,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final InputDecoration decoration;
  final TextStyle? style;
  final Color? cursorColor;
  final Color? clearIconColor;
  final String? clearTooltip;

  @override
  State<AppSearchTextField> createState() => _AppSearchTextFieldState();
}

class _AppSearchTextFieldState extends State<AppSearchTextField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerTick);
  }

  @override
  void didUpdateWidget(covariant AppSearchTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerTick);
      widget.controller.addListener(_onControllerTick);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerTick);
    super.dispose();
  }

  void _onControllerTick() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.isNotEmpty;
    final clear = AppSearchField.clearIconButton(
      visible: hasText,
      onClear: () {
        widget.controller.clear();
        widget.onChanged('');
      },
      tooltip: widget.clearTooltip ??
          MaterialLocalizations.of(context).deleteButtonTooltip,
      iconColor: widget.clearIconColor,
    );

    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      style: widget.style,
      cursorColor: widget.cursorColor,
      textInputAction: TextInputAction.search,
      onSubmitted: AppSearchField.onSubmitted,
      decoration: widget.decoration.copyWith(
        suffixIcon: clear ?? widget.decoration.suffixIcon,
      ),
    );
  }
}
