import '../../preferences/food_allergy.dart';
import '../eligible_menu_item.dart';
import 'allergy_keywords.dart';
import 'keyword_matcher.dart';

class AllergyFilter {
  const AllergyFilter();

  List<EligibleMenuItem> apply(
    List<EligibleMenuItem> items,
    Set<FoodAllergy> allergies,
  ) {
    if (allergies.isEmpty) return items;
    return items.where((item) => isSafe(item, allergies)).toList();
  }

  bool isSafe(EligibleMenuItem item, Set<FoodAllergy> allergies) {
    for (final allergy in allergies) {
      final keywords = allergyKeywords[allergy];
      if (keywords == null) continue;
      if (KeywordMatcher.matchesAny(item.searchableText, keywords)) {
        return false;
      }
    }
    return true;
  }
}
