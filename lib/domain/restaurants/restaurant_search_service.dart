import 'menu_item.dart';
import 'restaurant_match.dart';

class RestaurantSearchService {
  const RestaurantSearchService();

  static const int maxMatchedItemsPerRestaurant = 3;

  static const int _exactScore = 100;
  static const int _prefixScore = 70;
  static const int _containsScore = 40;
  static const int _itemPresenceBase = 10;
  static const int _itemPresencePerItem = 5;
  static const int _bestItemExactBonus = 30;
  static const int _bestItemPrefixBonus = 20;

  List<RestaurantMatch> rank(List<RestaurantMatch> matches, String query) {
    final term = query.toLowerCase().trim();

    final ranked = matches.map((match) {
      final sortedItems = [...match.matchedItems]
        ..sort((a, b) => _itemScore(b, term).compareTo(_itemScore(a, term)));
      return match.withItems(
        sortedItems.take(maxMatchedItemsPerRestaurant).toList(growable: false),
      );
    }).toList();

    ranked.sort((a, b) {
      final byScore = _restaurantScore(b, term).compareTo(
        _restaurantScore(a, term),
      );
      if (byScore != 0) return byScore;
      final byRating = b.restaurant.rating.compareTo(a.restaurant.rating);
      if (byRating != 0) return byRating;
      return a.restaurant.name
          .toLowerCase()
          .compareTo(b.restaurant.name.toLowerCase());
    });

    return List.unmodifiable(ranked);
  }

  int _restaurantScore(RestaurantMatch match, String term) {
    final name = match.restaurant.name.toLowerCase();
    var score = 0;
    if (name == term) {
      score += _exactScore;
    } else if (name.startsWith(term)) {
      score += _prefixScore;
    } else if (name.contains(term)) {
      score += _containsScore;
    }

    if (match.matchedItems.isNotEmpty) {
      score +=
          _itemPresenceBase + match.matchedItems.length * _itemPresencePerItem;
      final bestItem = match.matchedItems.first.name.toLowerCase();
      if (bestItem == term) {
        score += _bestItemExactBonus;
      } else if (bestItem.startsWith(term)) {
        score += _bestItemPrefixBonus;
      }
    }
    return score;
  }

  int _itemScore(MenuItem item, String term) {
    final name = item.name.toLowerCase();
    if (name == term) return _exactScore;
    if (name.startsWith(term)) return _prefixScore;
    if (name.contains(term)) return _containsScore;
    return 0;
  }
}
