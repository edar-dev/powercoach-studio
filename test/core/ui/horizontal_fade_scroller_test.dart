import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/widgets/horizontal_fade_scroller.dart';

void main() {
  testWidgets('HorizontalFadeScroller smoke mounts row child', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        home: Scaffold(
          body: HorizontalFadeScroller(
            height: 40,
            child: Row(
              children: List.generate(
                12,
                (i) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(label: Text('Chip $i')),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(HorizontalFadeScroller), findsOneWidget);
    expect(find.text('Chip 0'), findsOneWidget);
  });

  testWidgets(
    'HorizontalFadeScroller horizontal drag does not throw on narrow phone',
    (tester) async {
      const phone = Size(360, 800);
      tester.view.physicalSize = phone;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: StitchM3Theme.dark,
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(size: phone),
              child: ListView(
                children: [
                  HorizontalFadeScroller(
                    height: 48,
                    child: Row(
                      children: List.generate(
                        16,
                        (i) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(label: Text('Chip $i')),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 400, child: Text('below')),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(HorizontalFadeScroller), const Offset(-120, 0));
      await tester.pumpAndSettle();

      expect(find.text('Chip 0'), findsOneWidget);
      expect(find.text('below'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
