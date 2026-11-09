import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/customers/data/models/customer.dart';
import 'package:powercoach_studio/features/customers/presentation/customer_list_filter.dart';
import 'package:powercoach_studio/features/customers/presentation/widgets/customer_list_populated_body.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

Customer _customer(String name, {bool isArchived = false}) {
  final now = DateTime(2026, 1, 1);
  return Customer(
    id: 'c-$name',
    userId: 'u1',
    name: name,
    isArchived: isArchived,
    createdAt: now,
    updatedAt: now,
  );
}

Widget _wrap({
  required String searchQuery,
  CustomerListStatusFilter statusFilter = CustomerListStatusFilter.all,
  List<Customer>? customers,
}) {
  return MaterialApp(
    theme: StitchM3Theme.dark,
    locale: const Locale('it'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return CustomerListPopulatedBody(
            theme: theme,
            colorScheme: theme.colorScheme,
            customers: customers ?? [_customer('Mario Rossi')],
            searchQuery: searchQuery,
            statusFilter: statusFilter,
            sort: CustomerListSort.recent,
          );
        },
      ),
    ),
  );
}

void main() {
  testWidgets('typed search with zero hits shows Nessun risultato', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(searchQuery: 'zzz-no-match'));
    await tester.pumpAndSettle();

    expect(find.text('Nessun risultato'), findsOneWidget);
    expect(find.text('Nessun cliente corrisponde ai filtri.'), findsNothing);
  });

  testWidgets('status filter alone keeps customersSearchEmpty', (tester) async {
    await tester.pumpWidget(
      _wrap(
        searchQuery: '',
        statusFilter: CustomerListStatusFilter.expired,
        customers: [_customer('Mario Rossi')], // not archived → empty under Scaduti
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nessun cliente corrisponde ai filtri.'), findsOneWidget);
    expect(find.text('Nessun risultato'), findsNothing);
  });

  testWidgets('empty roster without filters shows Inizia a cercare', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        searchQuery: '',
        customers: const [],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Inizia a cercare'), findsOneWidget);
    expect(find.text('Nessun risultato'), findsNothing);
  });
}
