import '../../../core/auth/supabase_bootstrap.dart';
import '../../../core/sync/offline_models.dart';
import '../../../core/sync/offline_repository_support.dart';
import '../domain/models/client_note_message.dart';

/// Offline-first customer note thread (one [OfflineEntityType.customerNote] per message).
class CustomerNotesRepository {
  CustomerNotesRepository({OfflineRepositorySupport? offline})
      : _offline = offline ?? OfflineRepositorySupport();

  final OfflineRepositorySupport _offline;

  Future<List<ClientNoteMessage>> listNotes(
    String customerId, {
    int limit = 50,
  }) async {
    final rows = await _offline.readLocalEntities(
      OfflineEntityType.customerNote,
      scopeId: customerId,
      limit: limit,
    );
    final notes = rows.map(ClientNoteMessage.fromJson).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return notes;
  }

  Future<int> unreadCount(String customerId) async {
    final notes = await listNotes(customerId);
    return notes.where((note) => note.isUnread).length;
  }

  Future<ClientNoteMessage> addNote(String customerId, String body) async {
    final trimmed = ClientNoteMessage.validateBody(body);
    final authorUserId = SupabaseBootstrap.currentUser?.id ?? '';
    final id = _offline.newTempId('note');
    final now = DateTime.now();
    final payload = ClientNoteMessage(
      id: id,
      customerId: customerId,
      authorUserId: authorUserId,
      body: trimmed,
      createdAt: now,
    ).toJson();
    await _offline.saveLocalEntity(
      type: OfflineEntityType.customerNote,
      id: id,
      scopeId: customerId,
      payload: payload,
      localOnly: false,
    );
    return ClientNoteMessage.fromJson(payload);
  }

  Future<void> markThreadRead(String customerId) async {
    final notes = await listNotes(customerId, limit: 200);
    final now = DateTime.now();
    for (final note in notes) {
      if (!note.isUnread) {
        continue;
      }
      final payload = note.copyWith(readAt: now).toJson();
      await _offline.saveLocalEntity(
        type: OfflineEntityType.customerNote,
        id: note.id,
        scopeId: customerId,
        payload: payload,
        localOnly: false,
      );
    }
  }
}
