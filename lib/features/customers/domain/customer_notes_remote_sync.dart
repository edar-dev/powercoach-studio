import 'models/client_note_message.dart';

/// Future remote sync for customer notes (e.g. Supabase Postgres + Realtime).
///
/// MVP keeps notes local-only via [CustomerNotesRepository]. When backend sync
/// ships, implement this interface and replay the offline outbox for
/// [OfflineEntityType.customerNote].
abstract class CustomerNotesRemoteSync {
  Future<void> pushNote(ClientNoteMessage note);

  Stream<ClientNoteMessage> watchRemote(String customerId);
}
