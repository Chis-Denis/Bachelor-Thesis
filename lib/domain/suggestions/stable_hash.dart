class StableHash {
  StableHash._();

  static const int _offsetBasis = 0x811c9dc5;
  static const int _prime = 0x01000193;
  static const int _mask32 = 0xffffffff;
  static const int _mask31 = 0x7fffffff;

  static int fnv1a(String input) {
    var hash = _offsetBasis;
    for (final unit in input.codeUnits) {
      hash = (hash ^ unit) & _mask32;
      hash = (hash * _prime) & _mask32;
    }
    return hash & _mask31;
  }
}
