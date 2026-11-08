import 'package:flutter/material.dart';

/// Reusable list-tile skeleton placeholders (no shimmer package).
///
/// Row shape: leading circle + two text bars. Uses an opacity pulse against
/// [ColorScheme.surfaceContainerHighest].
class ListSkeleton extends StatefulWidget {
  const ListSkeleton({
    super.key,
    this.rowCount = 6,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 16),
    this.physics = const AlwaysScrollableScrollPhysics(),
  });

  final int rowCount;
  final EdgeInsetsGeometry padding;
  final ScrollPhysics? physics;

  @override
  State<ListSkeleton> createState() => _ListSkeletonState();
}

class _ListSkeletonState extends State<ListSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.45, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barColor = Theme.of(context).colorScheme.surfaceContainerHighest;

    return FadeTransition(
      opacity: _opacity,
      child: ListView.separated(
        physics: widget.physics,
        padding: widget.padding,
        itemCount: widget.rowCount,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, _) => _ListSkeletonRow(color: barColor),
      ),
    );
  }
}

/// Denser card-shaped skeleton useful for diary / dashboard cards.
class CardListSkeleton extends StatefulWidget {
  const CardListSkeleton({
    super.key,
    this.rowCount = 4,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 16),
    this.physics = const AlwaysScrollableScrollPhysics(),
  });

  final int rowCount;
  final EdgeInsetsGeometry padding;
  final ScrollPhysics? physics;

  @override
  State<CardListSkeleton> createState() => _CardListSkeletonState();
}

class _CardListSkeletonState extends State<CardListSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.45, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final barColor = cs.surfaceContainerHighest;

    return FadeTransition(
      opacity: _opacity,
      child: ListView.separated(
        physics: widget.physics,
        padding: widget.padding,
        itemCount: widget.rowCount,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, _) => Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _SkeletonBox(width: 64, height: 18, color: barColor, radius: 999),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SkeletonBox(height: 12, color: barColor),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SkeletonBox(height: 14, color: barColor),
              const SizedBox(height: 8),
              _SkeletonBox(width: 140, height: 12, color: barColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListSkeletonRow extends StatelessWidget {
  const _ListSkeletonRow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(height: 12, color: color),
                const SizedBox(height: 8),
                _SkeletonBox(width: 160, height: 10, color: color),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.height,
    required this.color,
    this.width,
    this.radius = 6,
  });

  final double? width;
  final double height;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
