import '../constants/app_info.dart';
import 'release_note_entry.dart';

/// Static release notes catalog, newest version first.
final kReleaseNotesCatalog = <ReleaseNoteEntry>[
  ReleaseNoteEntry(
    version: '1.0.7',
    releaseDate: DateTime.utc(2026, 7, 1),
    highlightKeys: [
      'v107_1',
      'v107_2',
      'v107_3',
      'v107_4',
      'v107_5',
    ],
  ),
  ReleaseNoteEntry(
    version: '1.0.6',
    releaseDate: DateTime.utc(2026, 6, 1),
    highlightKeys: [
      'v106_1',
      'v106_2',
      'v106_3',
      'v106_4',
    ],
  ),
  ReleaseNoteEntry(
    version: '1.0.5',
    releaseDate: DateTime.utc(2026, 5, 1),
    highlightKeys: [
      'v105_1',
      'v105_2',
      'v105_3',
      'v105_4',
      'v105_5',
    ],
  ),
  ReleaseNoteEntry(
    version: '1.0.4',
    releaseDate: DateTime.utc(2026, 4, 1),
    highlightKeys: [
      'v104_1',
      'v104_2',
      'v104_3',
      'v104_4',
      'v104_5',
    ],
  ),
  ReleaseNoteEntry(
    version: '1.0.3',
    releaseDate: DateTime.utc(2026, 3, 1),
    highlightKeys: [
      'v103_1',
      'v103_2',
      'v103_3',
      'v103_4',
    ],
  ),
  ReleaseNoteEntry(
    version: '1.0.2',
    releaseDate: DateTime.utc(2026, 2, 1),
    highlightKeys: [
      'v102_1',
      'v102_2',
      'v102_3',
      'v102_4',
    ],
  ),
  ReleaseNoteEntry(
    version: '1.0.1',
    releaseDate: DateTime.utc(2026, 1, 1),
    highlightKeys: [
      'v101_1',
      'v101_2',
      'v101_3',
      'v101_4',
      'v101_5',
      'v101_6',
      'v101_7',
    ],
  ),
];

String installedAppVersionLabel() => kAppVersionLabel;

ReleaseNoteEntry? entryForInstalledVersion() {
  for (final entry in kReleaseNotesCatalog) {
    if (entry.version == kAppVersionLabel) {
      return entry;
    }
  }
  return null;
}
