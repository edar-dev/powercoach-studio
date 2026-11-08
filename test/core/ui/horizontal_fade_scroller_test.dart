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
}
