import 'package:flutter/material.dart';

/// Defers building [builder] until this tab is first selected, then keeps state.
class WorkoutLazyTab extends StatefulWidget {
  const WorkoutLazyTab({
    super.key,
    required this.tabController,
    required this.tabIndex,
    required this.builder,
  });

  final TabController tabController;
  final int tabIndex;
  final WidgetBuilder builder;

  @override
  State<WorkoutLazyTab> createState() => _WorkoutLazyTabState();
}

class _WorkoutLazyTabState extends State<WorkoutLazyTab>
    with AutomaticKeepAliveClientMixin {
  bool _hasBeenVisible = false;

  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(_onTabChanged);
    _onTabChanged();
  }

  @override
  void didUpdateWidget(covariant WorkoutLazyTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabController != widget.tabController) {
      oldWidget.tabController.removeListener(_onTabChanged);
      widget.tabController.addListener(_onTabChanged);
      _onTabChanged();
    }
  }

  void _onTabChanged() {
    if (_hasBeenVisible || widget.tabController.index != widget.tabIndex) {
      return;
    }
    setState(() => _hasBeenVisible = true);
  }

  @override
  bool get wantKeepAlive => _hasBeenVisible;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_hasBeenVisible) {
      return const SizedBox.shrink();
    }
    return widget.builder(context);
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_onTabChanged);
    super.dispose();
  }
}
