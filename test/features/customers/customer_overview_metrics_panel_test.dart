import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/customers/domain/customer_overview_metrics.dart';
import 'package:powercoach_studio/features/customers/presentation/widgets/customer_overview_metrics_panel.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  testWidgets('CustomerOverviewMetricsPanel shows add measurement CTA when empty', (
    tester,
  ) async {
    var addTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CustomerOverviewMetricsPanel(
            snapshot: const CustomerOverviewSnapshot(
              weightKg: 80,
              weightFromProfile: true,
              muscleMassKg: null,
              muscleMassDelta: null,
              bodyFatPercent: null,
              bodyFatDelta: null,
              sbdTotal: null,
              sbdDelta: null,
              secondaryLabel: 'Muscle Mass',
              secondaryValue: null,
              secondaryUnit: 'kg',
              sparklinePoints: [],
              sparklineMetric: null,
              lastMeasurementDate: null,
              hasMeasurements: false,
            ),
            loading: false,
            onAddMeasurement: () => addTapped = true,
            onViewHistory: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Key biometric parameters'.toUpperCase()), findsOneWidget);
    expect(find.text('Add measurement'), findsOneWidget);
    await tester.tap(find.text('Add measurement'));
    expect(addTapped, isTrue);
  });

  testWidgets('CustomerOverviewMetricsPanel shows KPI values and register link', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CustomerOverviewMetricsPanel(
            snapshot: const CustomerOverviewSnapshot(
              weightKg: 82,
              weightFromProfile: true,
              muscleMassKg: 39,
              muscleMassDelta: 1,
              bodyFatPercent: 14.5,
              bodyFatDelta: -0.5,
              sbdTotal: 415,
              sbdDelta: 12.5,
              secondaryLabel: 'Muscle Mass',
              secondaryValue: 39,
              secondaryUnit: 'kg',
              sparklinePoints: [],
              sparklineMetric: null,
              lastMeasurementDate: null,
              hasMeasurements: true,
            ),
            loading: false,
            onAddMeasurement: () {},
            onViewHistory: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('82'), findsOneWidget);
    expect(find.text('39'), findsOneWidget);
    expect(find.text('14.5'), findsOneWidget);
    expect(find.text('415'), findsOneWidget);
    expect(find.text('Record new measurement'), findsOneWidget);
  });
}
