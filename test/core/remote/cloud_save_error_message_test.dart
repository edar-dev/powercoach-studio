import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/remote/cloud_save_error_message.dart';
import 'package:powercoach_studio/core/remote/coach_entities_exceptions.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  test('online-required offline → network message', () {
    final message = cloudSaveErrorMessage(
      CoachEntitiesOnlineRequiredException(
        CoachEntitiesOnlineRequiredReason.offline,
      ),
      l10n,
    );
    expect(message, l10n.cloudSaveRequiresNetwork);
  });

  test('online-required notAuthenticated → login message', () {
    final message = cloudSaveErrorMessage(
      CoachEntitiesOnlineRequiredException(
        CoachEntitiesOnlineRequiredReason.notAuthenticated,
      ),
      l10n,
    );
    expect(message, l10n.cloudSaveRequiresLogin);
  });

  test('remote generic → failed', () {
    final message = cloudSaveErrorMessage(
      CoachEntitiesRemoteException('Upsert failed'),
      l10n,
    );
    expect(message, l10n.cloudSaveFailed);
  });

  test('remote "No authenticated user" → login', () {
    final message = cloudSaveErrorMessage(
      CoachEntitiesRemoteException('No authenticated user'),
      l10n,
    );
    expect(message, l10n.cloudSaveRequiresLogin);
    expect(
      tryCloudSaveErrorMessage(
        CoachEntitiesRemoteException('no authenticated user present'),
        l10n,
      ),
      l10n.cloudSaveRequiresLogin,
    );
  });

  test('network string heuristic → network', () {
    final message = cloudSaveErrorMessage(
      Exception('SocketException: Failed host lookup'),
      l10n,
    );
    expect(message, l10n.cloudSaveRequiresNetwork);
    expect(
      tryCloudSaveErrorMessage(
        Exception('ClientException: Connection refused'),
        l10n,
      ),
      l10n.cloudSaveRequiresNetwork,
    );
    expect(isCloudSaveError(Exception('network unreachable')), isTrue);
    expect(isCloudSaveError(Exception('something else')), isFalse);
  });
}
