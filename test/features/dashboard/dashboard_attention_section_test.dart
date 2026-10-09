import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/data_quality/data_quality.dart';
import 'package:powercoach_studio/core/routing/app_paths.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/dashboard/presentation/widgets/dashboard_attention_section.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

Widget _wrapSection({
  required List<DataQualityFinding> findings,
  required GoRouter router,
  Locale locale = const Locale('it'),
}) {
  return MaterialApp.router(
    theme: StitchM3Theme.dark,
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: router,
  );
}

GoRouter _routerWithSection(List<DataQualityFinding> findings) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(
        path: '/dashboard',
        builder: (context, state) {
          final l10n = AppLocalizations.of(context);
          final theme = Theme.of(context);
          return Scaffold(
            body: DashboardAttentionSection(
              theme: theme,
              colorScheme: theme.colorScheme,
              l10n: l10n,
              actionableFindings: findings,
            ),
          );
        },
      ),
      GoRoute(
        path: AppPaths.settings,
        builder: (context, state) =>
            const Scaffold(body: Text('settings-hub')),
      ),
      GoRoute(
        path: AppPaths.dataHealth,
        builder: (context, state) =>
            const Scaffold(body: Text('data-health-screen')),
      ),
    ],
  );
}

void main() {
  testWidgets('all-clear shows backup CTA and navigates to settings',
      (tester) async {
    final router = _routerWithSection(const []);
    await tester.pumpWidget(_wrapSection(findings: const [], router: router));
    await tester.pumpAndSettle();

    expect(
      find.text('Al momento non c\'è nulla che richieda attenzione.'),
      findsOneWidget,
    );
    expect(find.text('Apri backup'), findsOneWidget);
    expect(find.text('Apri salute dati'), findsNothing);

    await tester.tap(find.text('Apri backup'));
    await tester.pumpAndSettle();
    expect(find.text('settings-hub'), findsOneWidget);
  });

  testWidgets('actionable findings show count, preview, and open data health',
      (tester) async {
    final findings = [
      const DataQualityFinding(
        ruleId: DataQualityRuleIds.orphanReference,
        severity: DataQualitySeverity.error,
        message: 'Plan plan-1 references missing customer cust-x',
      ),
      const DataQualityFinding(
        ruleId: DataQualityRuleIds.orphanReference,
        severity: DataQualitySeverity.warning,
        message: 'Pinned exercise missing-ex is orphan',
      ),
      const DataQualityFinding(
        ruleId: DataQualityRuleIds.planDataDecode,
        severity: DataQualitySeverity.error,
        message: 'planData decode failed for plan-2',
      ),
      const DataQualityFinding(
        ruleId: DataQualityRuleIds.emptyId,
        severity: DataQualitySeverity.error,
        message: 'Entity has empty id',
      ),
    ];
    final router = _routerWithSection(findings);
    await tester.pumpWidget(_wrapSection(findings: findings, router: router));
    await tester.pumpAndSettle();

    expect(find.text('4 problemi dati da controllare'), findsOneWidget);
    expect(find.text('Apri salute dati'), findsOneWidget);
    expect(find.text('Apri backup'), findsNothing);
    expect(
      find.text('Plan plan-1 references missing customer cust-x'),
      findsOneWidget,
    );
    expect(find.text('+1 altri'), findsOneWidget);

    await tester.tap(find.text('Apri salute dati'));
    await tester.pumpAndSettle();
    expect(find.text('data-health-screen'), findsOneWidget);
    expect(router.state.uri.path, AppPaths.dataHealth);
  });

  testWidgets('EN locale uses English data-health Attention copy',
      (tester) async {
    final findings = [
      const DataQualityFinding(
        ruleId: DataQualityRuleIds.orphanReference,
        severity: DataQualitySeverity.warning,
        message: 'broken pin',
      ),
    ];
    final router = _routerWithSection(findings);
    await tester.pumpWidget(
      _wrapSection(
        findings: findings,
        router: router,
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 data issues need review'), findsOneWidget);
    expect(find.text('Open data health'), findsOneWidget);
  });
}
