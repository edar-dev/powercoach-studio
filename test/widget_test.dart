// Basic Flutter widget test for PowerCoach Studio landing.

import 'package:flutter_test/flutter_test.dart';

import 'package:powercoach_studio/app.dart';

void main() {
  testWidgets('Landing screen shows title and CTA', (WidgetTester tester) async {
    await tester.pumpWidget(const PowerCoachStudioApp());

    expect(find.text('Power'), findsOneWidget);
    expect(find.text('Coach Studio'), findsOneWidget);
  });
}
