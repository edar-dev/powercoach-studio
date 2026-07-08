/// A single in-app release note version with localized highlight keys.
class ReleaseNoteEntry {
  const ReleaseNoteEntry({
    required this.version,
    required this.releaseDate,
    required this.highlightKeys,
  });

  final String version;
  final DateTime releaseDate;
  final List<String> highlightKeys;
}
