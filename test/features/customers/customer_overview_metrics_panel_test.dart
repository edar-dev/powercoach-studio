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
              secondaryLabel: 'Muscle Mass',
              secondaryValue: null,
              secondaryUnit: 'kg',
              secondaryTrend: null,
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

    expect(find.text('Add measurement'), findsOneWidget);
    await tester.tap(find.text('Add measurement'));
    expect(addTapped, isTrue);
  });
}
