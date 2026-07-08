import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/constants/app_info.dart';
import 'package:powercoach_studio/core/release_notes/release_notes_catalog.dart';

int _compareSemverDesc(String a, String b) {
  final aParts = a.split('.').map(int.parse).toList();
  final bParts = b.split('.').map(int.parse).toList();
  for (var i = 0; i < 3; i++) {
    final diff = aParts[i] - bParts[i];
    if (diff != 0) {
      return -diff;
    }
  }
  return 0;
}

void main() {
  test('catalog is ordered newest version first', () {
    for (var i = 0; i < kReleaseNotesCatalog.length - 1; i++) {
      final newer = kReleaseNotesCatalog[i].version;
      final older = kReleaseNotesCatalog[i + 1].version;
      expect(
        _compareSemverDesc(newer, older),
        lessThan(0),
        reason: '$newer should be newer than $older',
      );
    }
  });

  test('every entry has at least one highlight', () {
    for (final entry in kReleaseNotesCatalog) {
      expect(entry.highlightKeys, isNotEmpty, reason: entry.version);
    }
  });

  test('installed version has a catalog entry', () {
    expect(entryForInstalledVersion(), isNotNull);
    expect(kReleaseNotesCatalog.first.version, kAppVersionLabel);
  });
}
