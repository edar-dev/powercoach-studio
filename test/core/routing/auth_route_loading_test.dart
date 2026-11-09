import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/routing/auth_route_loading.dart';
import 'package:powercoach_studio/core/theme/marketing_dark_colors.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

void main() {
  testWidgets('AuthRouteLoading uses branded dark canvas (not blank login flash)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StitchM3Theme.dark,
        home: const AuthRouteLoading(),
      ),
    );

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, MarketingDarkColors.bgAlt);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
