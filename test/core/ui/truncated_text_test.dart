import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/ui/widgets/truncated_text.dart';

void main() {
  testWidgets('TruncatedText ellipsizes and wraps Tooltip', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 80,
            child: TruncatedText(
              'Very long exercise name that should truncate',
              tooltip: 'Very long exercise name that should truncate',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final text = tester.widget<Text>(find.byType(Text));
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
    expect(find.byType(Tooltip), findsOneWidget);
  });
}
