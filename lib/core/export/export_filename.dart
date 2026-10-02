const int _kMaxFilenameStemLength = 180;

final RegExp _unsafePathChars = RegExp(r'[/\\:*?"<>|]');
final RegExp _nonSlugChars = RegExp(r'[^\w\s-]', unicode: true);

/// Slug safe for filenames (no path separators, collapsed whitespace).
String sanitizeExportSlug(String input, {String fallback = 'export'}) {
  var slug = input.trim();
  slug = slug.replaceAll(_unsafePathChars, '');
  slug = slug.replaceAll(_nonSlugChars, '');
  slug = slug.replaceAll(RegExp(r'\s+'), '_');
  slug = slug.replaceAll(RegExp(r'_+'), '_');
  slug = slug.replaceAll(RegExp(r'^[_\-.]+|[_\-.]+$'), '');
  if (slug.isEmpty) return fallback;
  return slug;
}

/// `{ClientOrCoach}_{DocumentSlug}_{yyyy-MM-dd}.pdf`
String buildSmartPdfFilename({
  required String documentSlug,
  String? clientOrCoachName,
  DateTime? generatedOn,
  String fallbackDocumentSlug = 'export',
}) {
  final date = generatedOn ?? DateTime.now();
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  final datePart = '$y-$m-$d';

  final docSlug = sanitizeExportSlug(
    documentSlug,
    fallback: fallbackDocumentSlug,
  );
  final nameSlug = clientOrCoachName == null
      ? null
      : sanitizeExportSlug(clientOrCoachName.trim(), fallback: 'coach');
  final parts = <String>[
    if (nameSlug != null && nameSlug.isNotEmpty) nameSlug,
    docSlug,
    datePart,
  ];
  var stem = parts.join('_');
  if (stem.length > _kMaxFilenameStemLength) {
    stem = stem.substring(0, _kMaxFilenameStemLength);
  }
  return '$stem.pdf';
}
