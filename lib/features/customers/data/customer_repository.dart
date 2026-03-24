import '../../../core/network/gymblog_api_client.dart';
import '../../../core/sync/offline_models.dart';
import '../../../core/sync/offline_repository_support.dart';
import 'models/customer.dart';

class CustomerRepository {
  CustomerRepository()
      : _api = GymBlogApiClient(),
        _offline = OfflineRepositorySupport();

  final GymBlogApiClient _api;
  final OfflineRepositorySupport _offline;

  Future<List<Customer>> getAll({bool skipCache = false}) async {
    try {
      final list = await _api.getList('/api/customers', skipCache: skipCache);
      final customers = list.whereType<Map<String, dynamic>>().map(Customer.fromJson).toList();
      for (final customer in customers) {
        await _offline.saveLocalEntity(
          type: OfflineEntityType.customer,
          id: customer.id,
          scopeId: customer.userId,
          payload: _toJson(customer),
        );
      }
      return customers;
    } catch (_) {
      final local = await _offline.readLocalEntities(OfflineEntityType.customer);
      return local.map(Customer.fromJson).toList();
    }
  }

  Future<Customer?> getById(String customerId) async {
    try {
      final data = await _api.get('/api/customers/$customerId');
      final customer = Customer.fromJson(data);
      await _offline.saveLocalEntity(
        type: OfflineEntityType.customer,
        id: customer.id,
        scopeId: customer.userId,
        payload: _toJson(customer),
      );
      return customer;
    } on GymBlogApiException catch (e) {
      if (e.statusCode == 404) return null;
      final local = await _offline.readLocalEntityById(OfflineEntityType.customer, customerId);
      if (local != null) return Customer.fromJson(local);
      rethrow;
    }
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
    );
    await _offline.saveLocalEntity(
      type: OfflineEntityType.customer,
      id: tempId,
      scopeId: customer.userId,
      payload: _toJson(local),
      localOnly: true,
    );
    await _offline.enqueue(
      entityType: OfflineEntityType.customer,
      entityId: tempId,
      scopeId: customer.userId,
      opType: OfflineOperationType.create,
      path: '/api/customers',
      payload: customer.toCreateBody(),
    );
    return local;
  }

  Future<Customer> update(Customer customer) async {
    final current = await _offline.readLocalEntityById(OfflineEntityType.customer, customer.id);
    final payload = _toJson(customer);
    await _offline.saveLocalEntity(
      type: OfflineEntityType.customer,
      id: customer.id,
      scopeId: customer.userId,
      payload: payload,
      localOnly: true,
    );
    await _offline.enqueue(
      entityType: OfflineEntityType.customer,
      entityId: customer.id,
      scopeId: customer.userId,
      opType: OfflineOperationType.update,
      path: '/api/customers/${customer.id}',
      payload: customer.toUpdateBody(),
      baseUpdatedAt: DateTime.tryParse(current?['updatedAt']?.toString() ?? ''),
    );
    return customer;
  }

  Future<void> delete(String customerId) async {
    await _offline.markDeleted(OfflineEntityType.customer, customerId);
    await _offline.enqueue(
      entityType: OfflineEntityType.customer,
      entityId: customerId,
      scopeId: '',
      opType: OfflineOperationType.delete,
      path: '/api/customers/$customerId',
      payload: <String, dynamic>{},
    );
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
      };
}
