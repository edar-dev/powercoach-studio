import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/monitoring/sentry_release.dart';

void main() {
  test('release uses powercoach-studio@ prefix with dart-define defaults', () {
    expect(SentryReleaseInfo.release, 'powercoach-studio@1.0.0');
    expect(SentryReleaseInfo.dist, '0');
  });
}
