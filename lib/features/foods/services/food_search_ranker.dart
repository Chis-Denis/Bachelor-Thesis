import '../entities/food.dart';

const List<String> _derivativeWords = [
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

double scoreFood(Food food, String query) {
  final name = food.name.toLowerCase().trim();
  final q = query.toLowerCase().trim();
  if (q.isEmpty || name.isEmpty) return 0;

  double score = 0;

  if (name == q) {
    score += 100;
  } else if (_startsWithWord(name, q)) {
    score += 70;
  } else if (name.startsWith(q)) {
    score += 45;
  } else if (_containsWholeWord(name, q)) {
    score += 35;
  } else if (name.contains(q)) {
    score += 15;
  }

  final clampedLength = name.length > 80 ? 80 : name.length;
  score -= (clampedLength / 80.0) * 10.0;

  for (final word in _derivativeWords) {
    if (_containsWholeWord(q, word)) continue;
    if (_containsWholeWord(name, word)) {
      score -= 30;
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
  final re = RegExp('\\b${RegExp.escape(word)}\\b');
  return re.hasMatch(text);
}

bool _isWordChar(int code) {
  return (code >= 0x30 && code <= 0x39) ||
      (code >= 0x41 && code <= 0x5A) ||
      (code >= 0x61 && code <= 0x7A) ||
      code == 0x5F;
}
