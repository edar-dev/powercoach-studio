import '../../l10n/app_localizations.dart';
import 'coach_entities_exceptions.dart';

/// Maps cloud-save failures to localized SnackBar copy.
String cloudSaveErrorMessage(Object error, AppLocalizations l10n) {
  if (error is CoachEntitiesOnlineRequiredException) {
    switch (error.reason) {
      case CoachEntitiesOnlineRequiredReason.notAuthenticated:
        return l10n.cloudSaveRequiresLogin;
      case CoachEntitiesOnlineRequiredReason.offline:
        return l10n.cloudSaveRequiresNetwork;
    }
  }
  if (error is CoachEntitiesRemoteException) {
    return l10n.cloudSaveFailed;
  }
  final msg = error.toString().toLowerCase();
  if (msg.contains('socketexception') ||
      msg.contains('clientexception') ||
      msg.contains('failed host lookup') ||
      msg.contains('network') ||
      msg.contains('connection')) {
    return l10n.cloudSaveRequiresNetwork;
  }
  return l10n.cloudSaveFailed;
}

/// Returns a cloud-specific message when [error] is a known cloud failure;
/// otherwise null so callers can fall back to feature-specific copy.
String? tryCloudSaveErrorMessage(Object error, AppLocalizations l10n) {
  if (error is CoachEntitiesOnlineRequiredException ||
      error is CoachEntitiesRemoteException) {
    return cloudSaveErrorMessage(error, l10n);
  }
  return null;
}
