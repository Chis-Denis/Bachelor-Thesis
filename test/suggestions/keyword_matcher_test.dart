import 'package:flutter_test/flutter_test.dart';

import 'package:calorietrack_flutter/domain/suggestions/filtering/keyword_matcher.dart';

void main() {
  group('KeywordMatcher', () {
    test('matches a whole word in the text', () {
      expect(KeywordMatcher.matchesAny('grilled chicken wrap', {'chicken'}),
          isTrue);
    });

    test('matches a regular plural of the keyword', () {
      expect(KeywordMatcher.matchesAny('peanut cookies', {'cookie'}), isTrue);
    });

    test('matches an -es plural of the keyword', () {
      expect(KeywordMatcher.matchesAny('roasted tomatoes', {'tomato'}), isTrue);
    });

    test('does not match a keyword that is only a substring of a word', () {
      expect(KeywordMatcher.matchesAny('thai basil noodles', {'ai'}), isFalse);
    });

    test('matches a multi-word keyword as a phrase', () {
      expect(KeywordMatcher.matchesAny('pine nut tart', {'pine nut'}), isTrue);
    });

    test('is case-insensitive and ignores punctuation', () {
      expect(
          KeywordMatcher.matchesAny('Peanut-Butter Cup', {'peanut'}), isTrue);
    });

    test('returns false when no keyword is present', () {
      expect(KeywordMatcher.matchesAny('garden salad', {'beef', 'chicken'}),
          isFalse);
    });

    test('returns false for an empty keyword set', () {
      expect(KeywordMatcher.matchesAny('anything at all', const <String>{}),
          isFalse);
    });
  });
}
