import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/billing/plan_limits.dart';
import 'package:powercoach_studio/core/billing/plan_usage.dart';
import 'package:powercoach_studio/features/customers/data/customer_repository.dart';
import 'package:powercoach_studio/features/customers/data/models/customer.dart';

class _FakeCustomerRepository extends CustomerRepository {
  _FakeCustomerRepository(this.customers);

  final List<Customer> customers;

  @override
  Future<List<Customer>> getAll() async => customers;
}

void main() {
  final now = DateTime(2026, 7, 16);

  Customer customer({
    required String id,
    bool archived = false,
  }) {
    return Customer(
      id: id,
      userId: 'user-1',
      name: 'Client $id',
      isArchived: archived,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('PlanUsage', () {
    test('counts only non-archived customers', () async {
      final usage = PlanUsage(
        customerRepository: _FakeCustomerRepository([
          customer(id: '1'),
          customer(id: '2', archived: true),
          customer(id: '3'),
        ]),
      );

      expect(await usage.countActiveCustomers(), 2);
    });

    test('detects near and at limit thresholds', () {
      final usage = PlanUsage(
        customerRepository: _FakeCustomerRepository([]),
      );

      expect(usage.isNearCustomerLimit(PlanLimits.maxActiveCustomers - 1), isTrue);
      expect(usage.isAtCustomerLimit(PlanLimits.maxActiveCustomers), isTrue);
      expect(usage.isNearCustomerLimit(1), isFalse);
    });
  });
}
