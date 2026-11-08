import 'package:flutter/material.dart';

/// Pinned day/section label for [CustomScrollView] / [SliverPersistentHeader].
class PinnedSectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  PinnedSectionHeaderDelegate({
    required this.child,
    this.minExtentHeight = 36,
    this.maxExtentHeight = 36,
    this.backgroundColor,
  });

  final Widget child;
  final double minExtentHeight;
  final double maxExtentHeight;
  final Color? backgroundColor;

  @override
  double get minExtent => minExtentHeight;

  @override
  double get maxExtent => maxExtentHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final bg = backgroundColor ?? Theme.of(context).colorScheme.surface;
    return ColoredBox(
      color: bg,
      child: Align(
        alignment: Alignment.centerLeft,
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant PinnedSectionHeaderDelegate oldDelegate) {
    return child != oldDelegate.child ||
        minExtentHeight != oldDelegate.minExtentHeight ||
        maxExtentHeight != oldDelegate.maxExtentHeight ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}

/// Convenience sliver wrapping [PinnedSectionHeaderDelegate].
class PinnedSectionHeader extends StatelessWidget {
  const PinnedSectionHeader({
    super.key,
    required this.child,
    this.height = 36,
    this.backgroundColor,
    this.pinned = true,
  });

  final Widget child;
  final double height;
  final Color? backgroundColor;
  final bool pinned;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: pinned,
      delegate: PinnedSectionHeaderDelegate(
        child: child,
        minExtentHeight: height,
        maxExtentHeight: height,
        backgroundColor: backgroundColor,
      ),
    );
  }
}
