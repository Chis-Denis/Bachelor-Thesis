class KeywordMatcher {
  KeywordMatcher._();

  static const List<String> _pluralSuffixes = ['s', 'es'];

  static bool matchesAny(String text, Iterable<String> keywords) {
    final normalised = _normalise(text);
    final tokens = normalised.split(' ').where((t) => t.isNotEmpty).toSet();
    for (final raw in keywords) {
      final keyword = raw.toLowerCase().trim();
      if (keyword.isEmpty) continue;
      if (keyword.contains(' ')) {
        if (normalised.contains(keyword)) return true;
      } else if (_tokenMatches(tokens, keyword)) {
        return true;
      }
    }
    return false;
  }

  static bool _tokenMatches(Set<String> tokens, String keyword) {
    if (tokens.contains(keyword)) return true;
    for (final token in tokens) {
      if (token.length <= keyword.length) continue;
      if (!token.startsWith(keyword)) continue;
      final suffix = token.substring(keyword.length);
      if (_pluralSuffixes.contains(suffix)) return true;
    }
    return false;
  }

  static String _normalise(String text) {
    final buffer = StringBuffer();
    for (final rune in text.toLowerCase().runes) {
      buffer.write(_isLetterOrDigit(rune) ? String.fromCharCode(rune) : ' ');
    }
    return buffer.toString();
  }

  static bool _isLetterOrDigit(int rune) {
    const int zero = 48, nine = 57, a = 97, z = 122, lastAscii = 127;
    final isDigit = rune >= zero && rune <= nine;
    final isAsciiLetter = rune >= a && rune <= z;
    final isUnicodeLetter = rune > lastAscii;
    return isDigit || isAsciiLetter || isUnicodeLetter;
  }
}
