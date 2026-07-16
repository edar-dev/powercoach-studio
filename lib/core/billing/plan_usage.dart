import '../../features/customers/data/customer_repository.dart';
import 'plan_limits.dart';

/// Local usage metrics for plan gating and subscription UI.
class PlanUsage {
  PlanUsage({CustomerRepository? customerRepository})
      : _customerRepository = customerRepository ?? CustomerRepository();

  final CustomerRepository _customerRepository;

  Future<int> countActiveCustomers() async {
    final customers = await _customerRepository.getAll();
    return customers.where((customer) => !customer.isArchived).length;
  }

  bool isNearCustomerLimit(int activeCount) =>
      activeCount >= PlanLimits.maxActiveCustomers - 1;

  bool isAtCustomerLimit(int activeCount) =>
      activeCount >= PlanLimits.maxActiveCustomers;
}
