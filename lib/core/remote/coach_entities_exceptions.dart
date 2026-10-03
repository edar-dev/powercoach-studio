/// Thrown when a cloud write is attempted without a session or while offline.
class CoachEntitiesOnlineRequiredException implements Exception {
  CoachEntitiesOnlineRequiredException(this.reason, {this.message});

  final CoachEntitiesOnlineRequiredReason reason;
  final String? message;

  @override
  String toString() {
    final detail = message;
    if (detail != null && detail.isNotEmpty) {
      return 'CoachEntitiesOnlineRequiredException(${reason.name}): $detail';
    }
    return 'CoachEntitiesOnlineRequiredException(${reason.name})';
  }
}

enum CoachEntitiesOnlineRequiredReason {
  notAuthenticated,
  offline,
}

/// Thrown when Supabase `coach_entities` access fails or preconditions are unmet.
class CoachEntitiesRemoteException implements Exception {
  CoachEntitiesRemoteException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() {
    if (cause == null) return 'CoachEntitiesRemoteException: $message';
    return 'CoachEntitiesRemoteException: $message ($cause)';
  }
}
