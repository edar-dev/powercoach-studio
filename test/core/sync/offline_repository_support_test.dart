import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/sync/offline_repository_support.dart';

void main() {
  group('OfflineRepositorySupport.newTempId', () {
    test('generates unique ids under rapid bulk allocation', () {
      final support = OfflineRepositorySupport();
      final ids = <String>{};
      const n = 500;
      for (var i = 0; i < n; i++) {
        ids.add(support.newTempId('cex'));
      }
      expect(ids.length, n);
      expect(ids.every((id) => id.startsWith('local_cex_')), isTrue);
    });
  });
}
