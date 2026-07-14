import 'food.dart';

class FoodRankingService {
  const FoodRankingService();

  static const double _exactMatchScore = 100;
  static const double _leadingWordScore = 70;
  static const double _prefixScore = 45;
  static const double _wholeWordScore = 35;
  static const double _containsScore = 15;
  static const double _maxPenalisedLength = 80;
  static const double _lengthPenalty = 10;
  static const double _derivativePenalty = 30;

  static const List<String> _derivativeWords = [
    'oil',
    'bread',
    'toast',
    'toasted',
    'muffin',
    'muffins',
    'bagel',
    'bagels',
    'cereal',
    'flour',
    'chip',
    'chips',
    'cookie',
    'cookies',
    'cracker',
    'crackers',
    'syrup',
    'concentrate',
    'dried',
    'powder',
    'paste',
    'juice',
    'pie',
    'cake',
    'candy',
    'sauce',
    'mix',
    'dessert',
    'pastry',
    'pastries',
    'spread',
    'beverage',
  ];

  List<Food> rank(List<Food> foods, String query) {
    final scored = [
      for (final food in foods) (food: food, score: score(food, query)),
    ];
    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      final byType =
          a.food.dataType.sortOrder.compareTo(b.food.dataType.sortOrder);
      if (byType != 0) return byType;
      return a.food.name.toLowerCase().compareTo(b.food.name.toLowerCase());
    });
    return [for (final entry in scored) entry.food];
  }

  double score(Food food, String query) {
    final name = food.name.toLowerCase().trim();
    final term = query.toLowerCase().trim();
    if (term.isEmpty || name.isEmpty) return 0;

    var score = 0.0;
    if (name == term) {
      score += _exactMatchScore;
    } else if (_startsWithWord(name, term)) {
      score += _leadingWordScore;
    } else if (name.startsWith(term)) {
      score += _prefixScore;
    } else if (_containsWholeWord(name, term)) {
      score += _wholeWordScore;
    } else if (name.contains(term)) {
      score += _containsScore;
    }

    final clampedLength =
        name.length > _maxPenalisedLength ? _maxPenalisedLength : name.length;
    score -= (clampedLength / _maxPenalisedLength) * _lengthPenalty;

    for (final word in _derivativeWords) {
      if (_containsWholeWord(term, word)) continue;
      if (_containsWholeWord(name, word)) {
        score -= _derivativePenalty;
        break;
      }
    }
    return score;
  }

  bool _startsWithWord(String name, String word) {
    if (!name.startsWith(word)) return false;
    if (name.length == word.length) return true;
    return !_isWordChar(name.codeUnitAt(word.length));
  }

  bool _containsWholeWord(String text, String word) {
    if (word.isEmpty) return false;
    return RegExp('\\b${RegExp.escape(word)}\\b').hasMatch(text);
  }

  bool _isWordChar(int code) {
    return (code >= 0x30 && code <= 0x39) ||
        (code >= 0x41 && code <= 0x5A) ||
        (code >= 0x61 && code <= 0x7A) ||
        code == 0x5F;
  }
}
