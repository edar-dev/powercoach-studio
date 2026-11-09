import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/widgets/app_avatar.dart';

void main() {
  testWidgets('AppAvatar keeps fixed size with initials', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        home: const Scaffold(
          body: Center(
            child: AppAvatar(
              size: 48,
              initials: 'ab',
            ),
          ),
        ),
      ),
    );

    final sized = tester.getSize(find.byType(AppAvatar));
    expect(sized, const Size(48, 48));
    expect(find.text('AB'), findsOneWidget);
  });

  testWidgets('AppAvatar falls back to initials when imageUrl empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        home: const Scaffold(
          body: Center(
            child: AppAvatar(
              size: 36,
              initials: 'xy',
              imageUrl: '   ',
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(AppAvatar)), const Size(36, 36));
    expect(find.text('XY'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });
}
