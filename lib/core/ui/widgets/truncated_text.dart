import 'package:flutter/material.dart';

/// Single-line (by default) ellipsis text with an optional long-press [Tooltip].
class TruncatedText extends StatelessWidget {
  const TruncatedText(
    this.text, {
    super.key,
    this.style,
    this.maxLines = 1,
    this.tooltip,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final int maxLines;
  final String? tooltip;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final label = text;
    final child = Text(
      label,
      style: style,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
    );
    final tip = (tooltip ?? label).trim();
    if (tip.isEmpty) return child;
    return Tooltip(message: tip, child: child);
  }
}
