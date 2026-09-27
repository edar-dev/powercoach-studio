import '../data/models/customer.dart';

/// Status filter chips matching Stitch customers empty/list toolbar.
enum CustomerListStatusFilter {
  all,
  active,
  paused,
  unassigned,
}

/// Row status pill for the populated list (honest mapping from Customer fields).
enum CustomerListRowStatus {
  active,
  paused,
  unassigned,
}

/// Sort options for the customers list toolbar.
enum CustomerListSort {
  /// `updatedAt` desc, then `createdAt` desc.
  recent,

  /// Name A→Z (case-insensitive).
  nameAsc,
}

const List<CustomerListStatusFilter> customerListStatusFilters =
    CustomerListStatusFilter.values;

bool customerHasAssignedPlan(Customer customer) {
  final raw = customer.lastPlanUpdateDate?.trim();
  return raw != null && raw.isNotEmpty;
}

CustomerListRowStatus customerListRowStatus(Customer customer) {
  if (customer.isArchived) return CustomerListRowStatus.paused;
  if (!customerHasAssignedPlan(customer)) {
    return CustomerListRowStatus.unassigned;
  }
  return CustomerListRowStatus.active;
}

/// Age in whole years from ISO/date-parseable [dateOfBirth], or null if unknown.
int? customerAgeYears(String? dateOfBirth, {DateTime? now}) {
  if (dateOfBirth == null || dateOfBirth.trim().isEmpty) return null;
  final dob = DateTime.tryParse(dateOfBirth.trim());
  if (dob == null) return null;
  final clock = now ?? DateTime.now();
  var age = clock.year - dob.year;
  final m = clock.month - dob.month;
  if (m < 0 || (m == 0 && clock.day < dob.day)) age--;
  if (age <= 0 || age >= 110) return null;
  return age;
}

/// Initials (1–2 chars) from a display name.
String customerInitials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final p = parts.first;
    return p.length >= 2
        ? p.substring(0, 2).toUpperCase()
        : p.toUpperCase();
  }
  return ('${parts.first[0]}${parts.last[0]}').toUpperCase();
}

List<Customer> filterCustomerList({
  required List<Customer> customers,
  required String searchQuery,
  required CustomerListStatusFilter statusFilter,
  CustomerListSort sort = CustomerListSort.recent,
}) {
  var list = customers;
  final q = searchQuery.trim().toLowerCase();
  if (q.isNotEmpty) {
    list = list
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              (c.goals?.toLowerCase().contains(q) ?? false) ||
              (c.email?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }
  switch (statusFilter) {
    case CustomerListStatusFilter.all:
      break;
    case CustomerListStatusFilter.active:
      list = list.where((c) => !c.isArchived).toList();
    case CustomerListStatusFilter.paused:
      list = list.where((c) => c.isArchived).toList();
    case CustomerListStatusFilter.unassigned:
      list = list.where((c) => !customerHasAssignedPlan(c)).toList();
  }

  list = List<Customer>.of(list);
  switch (sort) {
    case CustomerListSort.recent:
      list.sort((a, b) {
        final byUpdated = b.updatedAt.compareTo(a.updatedAt);
        if (byUpdated != 0) return byUpdated;
        return b.createdAt.compareTo(a.createdAt);
      });
    case CustomerListSort.nameAsc:
      list.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
  }
  return list;
}

int countForStatusFilter(List<Customer> customers, CustomerListStatusFilter f) {
  return filterCustomerList(
    customers: customers,
    searchQuery: '',
    statusFilter: f,
  ).length;
}
