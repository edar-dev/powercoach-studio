import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/presentation/workout_builder_mobility_tab_remap.dart';

/// Mirrors [_WorkoutBuilderMobilityScreenState._syncTabControllerLength]:
/// assign a replacement TabController, dispose the previous one next frame.
class _MobilityTabSyncHarness extends StatefulWidget {
  const _MobilityTabSyncHarness();

  @override
  State<_MobilityTabSyncHarness> createState() => _MobilityTabSyncHarnessState();
}

class _MobilityTabSyncHarnessState extends State<_MobilityTabSyncHarness>
    with TickerProviderStateMixin {
  late TabController controller;
  bool showsMobility = false;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
  }

  void setShowsMobility(bool value) {
    setState(() {
      final length = value ? 3 : 2;
      if (controller.length == length) {
        showsMobility = value;
        return;
      }
      final previousIndex = controller.index;
      final oldController = controller;
      final initialIndex = remapTabIndexAfterMobilityVisibilityChange(
        showingMobility: length == 3,
        previousIndex: previousIndex,
      ).clamp(0, length - 1);
      controller = TabController(
        length: length,
        vsync: this,
        initialIndex: initialIndex,
      );
      showsMobility = value;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        oldController.dispose();
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            controller: controller,
            tabs: [
              const Tab(text: 'Training'),
              if (showsMobility) const Tab(text: 'Mobility'),
              const Tab(text: 'Details'),
            ],
          ),
        ),
        body: TabBarView(
          controller: controller,
          children: [
            const Center(child: Text('training-body')),
            if (showsMobility) const Center(child: Text('mobility-body')),
            const Center(child: Text('details-body')),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => setShowsMobility(!showsMobility),
          child: const Icon(Icons.swap_horiz),
        ),
      ),
    );
  }
}

void main() {
  testWidgets(
    'toggling mobility tab length does not use a disposed TabController',
    (tester) async {
      final errors = <Object>[];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        errors.add(details.exception);
        oldHandler?.call(details);
      };
      addTearDown(() => FlutterError.onError = oldHandler);

      await tester.pumpWidget(const _MobilityTabSyncHarness());
      expect(find.text('Mobility'), findsNothing);
      expect(find.text('Training'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);

      // Enable mobility (2 → 3 tabs).
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump(); // rebuild with new controller
      await tester.pump(); // run post-frame dispose of old controller
      expect(find.text('Mobility'), findsOneWidget);

      // Open details, then hide mobility — should stay on details.
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();
      expect(find.text('details-body'), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump();
      expect(find.text('Mobility'), findsNothing);
      expect(find.text('details-body'), findsOneWidget);

      expect(
        errors.where(
          (e) =>
              e.toString().contains('disposed') ||
              e.toString().contains('multiple tickers'),
        ),
        isEmpty,
        reason: 'TabController sync must not dispose-while-attached or '
            'create a second ticker under SingleTickerProvider',
      );
    },
  );
}
