import 'package:flutter_test/flutter_test.dart';

import 'package:powercoach_studio/features/customers/data/models/customer.dart';
import 'package:powercoach_studio/features/customers/presentation/customer_list_filter.dart';
import 'package:powercoach_studio/features/customers/presentation/customer_list_metrics.dart';
import 'package:powercoach_studio/features/dashboard/domain/dashboard_snapshot.dart';

Customer _c({
  required String name,
  bool archived = false,
  String? goals,
  String? email,
  String? dateOfBirth,
  String? lastPlanUpdateDate,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final now = DateTime(2024, 6, 15);
  return Customer(
    id: name,
    userId: 'u1',
    name: name,
    goals: goals,
    email: email,
    dateOfBirth: dateOfBirth,
    isArchived: archived,
    lastPlanUpdateDate: lastPlanUpdateDate,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
  );
}

void main() {
  group('filter + sort', () {
    final now = DateTime(2024, 6, 20);
    final customers = [
      _c(
        name: 'Anna',
        lastPlanUpdateDate: '2024-01-01', // stale / expiring
        updatedAt: DateTime(2024, 6, 10),
      ),
      _c(
        name: 'Bruno',
        archived: true,
        lastPlanUpdateDate: '2024-01-01',
        updatedAt: DateTime(2024, 6, 12),
      ),
      _c(
        name: 'Carla',
        updatedAt: DateTime(2024, 6, 14),
      ),
      _c(
        name: 'Dario',
        lastPlanUpdateDate: '2024-06-18', // fresh plan
        updatedAt: DateTime(2024, 6, 15),
      ),
    ];

    test('filters by status (Stitch: all/active/expiring/expired)', () {
      expect(
        filterCustomerList(
          customers: customers,
          searchQuery: '',
          statusFilter: CustomerListStatusFilter.all,
        ).length,
        4,
      );
      expect(
        filterCustomerList(
          customers: customers,
          searchQuery: '',
          statusFilter: CustomerListStatusFilter.active,
        ).map((c) => c.name),
        ['Dario', 'Carla', 'Anna'],
      );
      expect(
        filterCustomerList(
          customers: customers,
          searchQuery: '',
          statusFilter: CustomerListStatusFilter.expiring,
          now: now,
          stalePlanDays: kStalePlanDays,
        ).map((c) => c.name),
        ['Anna'],
      );
      expect(
        filterCustomerList(
          customers: customers,
          searchQuery: '',
          statusFilter: CustomerListStatusFilter.expired,
        ).map((c) => c.name),
        ['Bruno'],
      );
    });

    test('unassigned athletes remain under Tutti/Attivi', () {
      final active = filterCustomerList(
        customers: customers,
        searchQuery: '',
        statusFilter: CustomerListStatusFilter.active,
      );
      expect(active.any((c) => c.name == 'Carla'), isTrue);
      expect(customerListRowStatus(customers[2]), CustomerListRowStatus.unassigned);
    });

    test('search matches name', () {
      final result = filterCustomerList(
        customers: customers,
        searchQuery: 'ann',
        statusFilter: CustomerListStatusFilter.all,
      );
      expect(result.map((c) => c.name), ['Anna']);
    });

    test('sorts by recent updatedAt desc by default', () {
      final result = filterCustomerList(
        customers: customers,
        searchQuery: '',
        statusFilter: CustomerListStatusFilter.all,
      );
      expect(result.map((c) => c.name), ['Dario', 'Carla', 'Bruno', 'Anna']);
    });

    test('sorts by name ascending', () {
      final result = filterCustomerList(
        customers: customers,
        searchQuery: '',
        statusFilter: CustomerListStatusFilter.all,
        sort: CustomerListSort.nameAsc,
      );
      expect(result.map((c) => c.name), ['Anna', 'Bruno', 'Carla', 'Dario']);
    });
  });

  group('row status + helpers', () {
    test('maps archived / unassigned / active', () {
      expect(
        customerListRowStatus(_c(name: 'A', archived: true)),
        CustomerListRowStatus.paused,
      );
      expect(
        customerListRowStatus(_c(name: 'B')),
        CustomerListRowStatus.unassigned,
      );
      expect(
        customerListRowStatus(
          _c(name: 'C', lastPlanUpdateDate: '2024-01-01'),
        ),
        CustomerListRowStatus.active,
      );
    });

    test('initials and age', () {
      expect(customerInitials('Alessandro Bianchi'), 'AB');
      expect(customerInitials('Madonna'), 'MA');
      expect(
        customerAgeYears('1990-06-15', now: DateTime(2024, 6, 15)),
        34,
      );
      expect(
        customerAgeYears('1990-06-16', now: DateTime(2024, 6, 15)),
        33,
      );
      expect(customerAgeYears('not-a-date'), isNull);
    });
  });

  group('metrics', () {
    test('computes honest counts without fake check-ins', () {
      final now = DateTime(2024, 6, 20);
      final customers = [
        _c(name: 'ActivePlan', lastPlanUpdateDate: '2024-06-18'),
        _c(name: 'StalePlan', lastPlanUpdateDate: '2024-05-01'),
        _c(name: 'NoPlan'),
        _c(name: 'Paused', archived: true, lastPlanUpdateDate: '2024-01-01'),
      ];

      final m = computeCustomerListMetrics(
        customers,
        now: now,
        stalePlanDays: kStalePlanDays,
      );

      expect(m.totalAthletes, 4);
      expect(m.activeCount, 3);
      expect(m.plansInProgress, 2);
      expect(m.pausedCount, 1);
      expect(m.needsUpdateCount, 1);
    });
  });
}
