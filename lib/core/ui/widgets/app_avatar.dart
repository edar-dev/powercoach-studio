import 'package:flutter/material.dart';

/// Fixed-size circular avatar with initials fallback.
///
/// Layout is always [size]×[size] so image load/error never shifts surrounding UI.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.size,
    required this.initials,
    this.imageUrl,
    this.backgroundColor,
    this.foregroundColor,
    this.border,
    this.gradient,
    this.fontSize,
    this.semanticLabel,
  });

  final double size;
  final String initials;
  final String? imageUrl;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BoxBorder? border;
  final Gradient? gradient;
  final double? fontSize;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bg = backgroundColor ?? cs.primaryContainer;
    final fg = foregroundColor ?? cs.onPrimaryContainer;
    final resolvedInitials = initials.trim().isEmpty
        ? '?'
        : initials.trim().toUpperCase();
    final textStyle = theme.textTheme.labelLarge?.copyWith(
      color: fg,
      fontWeight: FontWeight.w700,
      fontSize: fontSize ?? (size * 0.36).clamp(10, 28),
    );

    Widget initialsChild = ColoredBox(
      color: gradient == null ? bg : Colors.transparent,
      child: Center(
        child: Text(resolvedInitials, style: textStyle),
      ),
    );
    if (gradient != null) {
      initialsChild = DecoratedBox(
        decoration: BoxDecoration(gradient: gradient),
        child: Center(
          child: Text(resolvedInitials, style: textStyle),
        ),
      );
    }

    final url = imageUrl?.trim();
    final child = (url == null || url.isEmpty)
        ? initialsChild
        : Image.network(
            url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => initialsChild,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return initialsChild;
            },
          );

    return Semantics(
      label: semanticLabel ?? resolvedInitials,
      image: true,
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: border,
          ),
          child: ClipOval(child: child),
        ),
      ),
    );
  }
}
