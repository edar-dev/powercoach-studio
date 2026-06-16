import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/sync/sync_replay_hook.dart';

void main() {
  test('NoOpSyncReplayHook completes without error', () async {
    await NoOpSyncReplayHook.instance.requestReplay();
  });
}
