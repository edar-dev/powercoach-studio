/// Shared exercise search: normalize → whitespace token AND → light ranking.
///
/// Used by autocomplete (`filterExercisesByQuery`) and the library tree
/// (`filterExerciseTreeByQuery`) so both surfaces stay in sync.
library;

/// Latin letters with common diacritics → ASCII fold (IT/EN gym names).
const Map<String, String> _diacriticFold = {
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ä': 'a',
  'ã': 'a',
  'å': 'a',
  'è': 'e',
  'é': 'e',
  'ê': 'e',
  'ë': 'e',
  'ì': 'i',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ò': 'o',
  'ó': 'o',
  'ô': 'o',
  'ö': 'o',
  'õ': 'o',
  'ù': 'u',
  'ú': 'u',
  'û': 'u',
  'ü': 'u',
  'ý': 'y',
  'ÿ': 'y',
  'ñ': 'n',
  'ç': 'c',
  'ß': 'ss',
};

/// Cheap bidirectional gym synonyms (token → alternatives also accepted).
///
/// Phrase gaps like `panca stretta` vs `Panca piana presa stretta` are handled
/// by token AND (both tokens appear). Synonyms cover IT/EN and short forms.
const Map<String, List<String>> _tokenSynonyms = {
  'panca': ['bench'],
  'bench': ['panca'],
  'stacco': ['deadlift'],
  'deadlift': ['stacco'],
  'presa': ['grip'],
  'grip': ['presa'],
  'cg': ['stretta', 'grip', 'presa'],
  'bp': ['bench', 'panca'],
  'dl': ['deadlift', 'stacco'],
};

final RegExp _nonAlnum = RegExp(r'[^a-z0-9]+');
final RegExp _whitespace = RegExp(r'\s+');

/// Lowercases, folds diacritics, and turns punctuation into spaces.
String normalizeExerciseSearchText(String input) {
  final lower = input.trim().toLowerCase();
  if (lower.isEmpty) return '';

  final folded = StringBuffer();
  for (final unit in lower.runes) {
    final ch = String.fromCharCode(unit);
    folded.write(_diacriticFold[ch] ?? ch);
  }

  return folded
      .toString()
      .replaceAll(_nonAlnum, ' ')
      .replaceAll(_whitespace, ' ')
      .trim();
}

/// Whitespace tokens after [normalizeExerciseSearchText].
List<String> tokenizeExerciseSearchQuery(String query) {
  final normalized = normalizeExerciseSearchText(query);
  if (normalized.isEmpty) return const [];
  return normalized.split(' ').where((t) => t.isNotEmpty).toList();
}

List<String> _alternativesForToken(String token) {
  final syns = _tokenSynonyms[token];
  if (syns == null || syns.isEmpty) return [token];
  return [token, ...syns];
}

bool _haystackHasToken(String normalizedHaystack, String token) {
  for (final alt in _alternativesForToken(token)) {
    if (normalizedHaystack.contains(alt)) return true;
  }
  return false;
}

/// Whether every query token appears somewhere in [haystack] (token AND).
///
/// Matching is case/diacritic/punctuation-insensitive. A token matches if it
/// or a cheap synonym is a substring of the normalized haystack.
bool exerciseTextMatchesQuery(String haystack, String query) {
  final tokens = tokenizeExerciseSearchQuery(query);
  if (tokens.isEmpty) return true;

  final normalizedHaystack = normalizeExerciseSearchText(haystack);
  if (normalizedHaystack.isEmpty) return false;

  return tokens.every((token) => _haystackHasToken(normalizedHaystack, token));
}

int? _bestIndexOfAlts(
  String haystack,
  List<String> alts, {
  int start = 0,
}) {
  int? best;
  for (final alt in alts) {
    final idx = haystack.indexOf(alt, start);
    if (idx >= 0 && (best == null || idx < best)) {
      best = idx;
    }
  }
  return best;
}

/// Relevance score for a match (higher is better). Returns `-1` when no match.
///
/// Scoring priorities:
/// 1. Prefix hits (token starts a haystack word)
/// 2. Tokens appearing in query order
/// 3. Earlier first-hit position
int scoreExerciseQueryMatch(String haystack, String query) {
  final tokens = tokenizeExerciseSearchQuery(query);
  if (tokens.isEmpty) return 0;

  final normalizedHaystack = normalizeExerciseSearchText(haystack);
  if (normalizedHaystack.isEmpty) return -1;

  final words = normalizedHaystack.split(' ');
  var prefixHits = 0;
  var orderedHits = 0;
  var searchFrom = 0;
  var firstHit = normalizedHaystack.length;

  for (final token in tokens) {
    final alts = _alternativesForToken(token);
    if (!_haystackHasToken(normalizedHaystack, token)) return -1;

    final isPrefix = words.any(
      (w) => alts.any(w.startsWith),
    );
    if (isPrefix) prefixHits++;

    final orderedIndex = _bestIndexOfAlts(
      normalizedHaystack,
      alts,
      start: searchFrom,
    );
    if (orderedIndex != null) {
      orderedHits++;
      // Advance past the matched alternative that starts earliest.
      var matchedLen = 0;
      for (final alt in alts) {
        if (normalizedHaystack.startsWith(alt, orderedIndex) &&
            alt.length > matchedLen) {
          matchedLen = alt.length;
        }
      }
      searchFrom = orderedIndex + matchedLen;
      if (orderedIndex < firstHit) firstHit = orderedIndex;
    } else {
      final anyIndex = _bestIndexOfAlts(normalizedHaystack, alts) ?? 0;
      if (anyIndex < firstHit) firstHit = anyIndex;
    }
  }

  final positionBonus = 1000 - firstHit.clamp(0, 999);
  return prefixHits * 100 + orderedHits * 10 + positionBonus;
}

/// Filters [options] with token AND and sorts matches by [scoreExerciseQueryMatch]
/// (stable among equal scores — original relative order preserved via index).
Iterable<T> filterAndRankByExerciseQuery<T>({
  required String query,
  required Iterable<T> options,
  required String Function(T item) searchableText,
}) {
  final tokens = tokenizeExerciseSearchQuery(query);
  if (tokens.isEmpty) return options;

  final scored = <({T item, int score, int index})>[];
  var index = 0;
  for (final item in options) {
    final text = searchableText(item);
    final score = scoreExerciseQueryMatch(text, query);
    if (score >= 0) {
      scored.add((item: item, score: score, index: index));
    }
    index++;
  }

  scored.sort((a, b) {
    final byScore = b.score.compareTo(a.score);
    if (byScore != 0) return byScore;
    return a.index.compareTo(b.index);
  });
  return scored.map((e) => e.item);
}
