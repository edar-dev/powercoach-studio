import 'package:flutter/material.dart';

/// Taps empty/chrome areas to unfocus the current text field.
///
/// Prefer [HitTestBehavior.translucent] so child buttons still receive taps.
class KeyboardDismiss extends StatelessWidget {
  const KeyboardDismiss({
    super.key,
    required this.child,
    this.behavior = HitTestBehavior.translucent,
  });

  final Widget child;
  final HitTestBehavior behavior;

  static void unfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: behavior,
      onTap: unfocus,
      child: child,
    );
  }
}
