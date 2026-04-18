import '../../../core/sync/offline_models.dart';
import '../../../core/sync/offline_repository_support.dart';
import 'models/customer.dart';

class CustomerRepository {
  CustomerRepository({OfflineRepositorySupport? offline})
      : _offline = offline ?? OfflineRepositorySupport();

  final OfflineRepositorySupport _offline;

  Future<List<Customer>> getAll({bool skipCache = false}) async {
    final local = await _offline.readLocalEntities(OfflineEntityType.customer);
    return local.map(Customer.fromJson).toList();
  }

  Future<Customer?> getById(String customerId) async {
    final local = await _offline.readLocalEntityById(
      OfflineEntityType.customer,
      customerId,
    );
    if (local == null) return null;
    return Customer.fromJson(local);
  }

  Future<Customer> create(Customer customer) async {
    final tempId = _offline.newTempId('customer');
    final now = DateTime.now();
    final local = Customer(
      id: tempId,
      userId: customer.userId,
      name: customer.name,
      email: customer.email,
      phone: customer.phone,
      dateOfBirth: customer.dateOfBirth,
      heightCm: customer.heightCm,
      weightKg: customer.weightKg,
      notes: customer.notes,
      goals: customer.goals,
      pdfHeader: customer.pdfHeader,
      useCustomPdfHeader: customer.useCustomPdfHeader,
      isFavorite: customer.isFavorite,
      isArchived: customer.isArchived,
      lastPlanUpdateDate: customer.lastPlanUpdateDate,
      createdAt: now,
      updatedAt: now,
      rowVersion: 1,
    );
    await _offline.saveLocalEntity(
      type: OfflineEntityType.customer,
      id: tempId,
      scopeId: customer.userId,
      payload: _toJson(local),
      localOnly: false,
    );
    return local;
  }

  Future<Customer> update(Customer customer) async {
    final payload = _toJson(customer);
    await _offline.saveLocalEntity(
      type: OfflineEntityType.customer,
      id: customer.id,
      scopeId: customer.userId,
      payload: payload,
      localOnly: false,
    );
    return customer;
  }

  Future<void> delete(String customerId) async {
    await _offline.markDeleted(OfflineEntityType.customer, customerId);
  }

  Map<String, dynamic> _toJson(Customer c) => {
        'id': c.id,
        'userId': c.userId,
        'name': c.name,
        'email': c.email,
        'phone': c.phone,
        'dateOfBirth': c.dateOfBirth,
        'heightCm': c.heightCm,
        'weightKg': c.weightKg,
        'notes': c.notes,
        'goals': c.goals,
        'pdfHeader': c.pdfHeader,
        'useCustomPdfHeader': c.useCustomPdfHeader,
        'isFavorite': c.isFavorite,
        'isArchived': c.isArchived,
        'lastPlanUpdateDate': c.lastPlanUpdateDate,
        'createdAt': c.createdAt.toIso8601String(),
        'updatedAt': c.updatedAt.toIso8601String(),
        'rowVersion': c.rowVersion,
      };
}
