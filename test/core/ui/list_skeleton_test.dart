import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/widgets/list_skeleton.dart';

void main() {
  testWidgets('ListSkeleton builds configurable rows', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        home: const Scaffold(body: ListSkeleton(rowCount: 4)),
      ),
    );
    await tester.pump();

    expect(find.byType(ListSkeleton), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('CardListSkeleton builds card placeholders', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        home: const Scaffold(body: CardListSkeleton(rowCount: 2)),
      ),
    );
    await tester.pump();

    expect(find.byType(CardListSkeleton), findsOneWidget);
  });
}
