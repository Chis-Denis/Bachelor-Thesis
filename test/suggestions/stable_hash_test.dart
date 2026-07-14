import 'package:flutter_test/flutter_test.dart';

import 'package:calorietrack_flutter/domain/suggestions/stable_hash.dart';

void main() {
  group('StableHash.fnv1a', () {
    test('is deterministic for the same input', () {
      expect(StableHash.fnv1a('1|gainMuscle|600|100'),
          StableHash.fnv1a('1|gainMuscle|600|100'));
    });

    test('changes when the input changes', () {
      expect(StableHash.fnv1a('1|gainMuscle|600|100'),
          isNot(StableHash.fnv1a('1|gainMuscle|600|99')));
    });

    test('always returns a non-negative 31-bit integer', () {
      for (final input in ['', 'a', 'the quick brown fox', '1|2|3|4|5']) {
        final h = StableHash.fnv1a(input);
        expect(h, greaterThanOrEqualTo(0));
        expect(h, lessThanOrEqualTo(0x7fffffff));
      }
    });

    test('matches the known FNV-1a basis for the empty string', () {
      expect(StableHash.fnv1a(''), 0x011c9dc5);
    });
  });
}
