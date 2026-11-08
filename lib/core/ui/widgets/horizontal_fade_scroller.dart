import 'package:flutter/material.dart';

/// Single-row horizontal scroll with soft edge fades when content overflows.
///
/// [child] is typically a [Row] of chips / pills.
class HorizontalFadeScroller extends StatefulWidget {
  const HorizontalFadeScroller({
    super.key,
    required this.child,
    this.height,
    this.padding,
    this.fadeWidth = 24,
  });

  final Widget child;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double fadeWidth;

  @override
  State<HorizontalFadeScroller> createState() => _HorizontalFadeScrollerState();
}

class _HorizontalFadeScrollerState extends State<HorizontalFadeScroller> {
  final ScrollController _controller = ScrollController();
  bool _showLeft = false;
  bool _showRight = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateFades);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFades());
  }

  @override
  void dispose() {
    _controller.removeListener(_updateFades);
    _controller.dispose();
    super.dispose();
  }

  void _updateFades() {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    final showLeft = position.pixels > 1;
    final showRight = position.pixels < position.maxScrollExtent - 1;
    if (showLeft != _showLeft || showRight != _showRight) {
      setState(() {
        _showLeft = showLeft;
        _showRight = showRight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fadeColor = cs.surface;

    Widget scroller = SingleChildScrollView(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      padding: widget.padding,
      child: widget.child,
    );

    if (widget.height != null) {
      scroller = SizedBox(height: widget.height, child: scroller);
    }

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _updateFades());
        return false;
      },
      child: SizeChangedLayoutNotifier(
        child: Stack(
          children: [
            scroller,
            if (_showLeft)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: widget.fadeWidth,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          fadeColor,
                          fadeColor.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (_showRight)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: widget.fadeWidth,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          fadeColor.withValues(alpha: 0),
                          fadeColor,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
