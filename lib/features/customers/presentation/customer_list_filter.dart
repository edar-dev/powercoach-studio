import '../data/models/customer.dart';

const List<String> customerListFilterChips = [
  'All',
  'Weight Loss',
  'Muscle Gain',
  'Endurance',
  'Rehab',
];

List<Customer> filterCustomerList({
  required List<Customer> customers,
  required String searchQuery,
  required int filterChipIndex,
}) {
  var list = customers;
  final q = searchQuery.trim().toLowerCase();
  if (q.isNotEmpty) {
    list = list
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              (c.goals?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }
  if (filterChipIndex > 0 && filterChipIndex < customerListFilterChips.length) {
    final goal = customerListFilterChips[filterChipIndex].toLowerCase();
    list = list
        .where((c) => (c.goals?.toLowerCase().contains(goal) ?? false))
        .toList();
  }
  return list;
}
