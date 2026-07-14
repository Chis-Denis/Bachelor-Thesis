import '../../constants/restriction_constants.dart';
import '../../preferences/dietary_restriction.dart';
import '../eligible_menu_item.dart';
import 'dietary_restriction_keywords.dart';
import 'keyword_matcher.dart';

class DietaryRestrictionFilter {
  const DietaryRestrictionFilter();

  List<EligibleMenuItem> apply(
    List<EligibleMenuItem> items,
    Set<DietaryRestriction> restrictions,
  ) {
    if (restrictions.isEmpty) return items;
    return items.where((item) => isAllowed(item, restrictions)).toList();
  }

  bool isAllowed(EligibleMenuItem item, Set<DietaryRestriction> restrictions) {
    for (final restriction in restrictions) {
      if (_violates(item, restriction)) return false;
    }
    return true;
  }

  bool _violates(EligibleMenuItem item, DietaryRestriction restriction) {
    switch (restriction) {
      case DietaryRestriction.keto:
        return item.carbs > RestrictionConstants.ketoMaxCarbsPerItem;
      case DietaryRestriction.lowCarb:
        return item.carbs > RestrictionConstants.lowCarbMaxCarbsPerItem;
      default:
        final keywords = dietaryRestrictionKeywords[restriction];
        if (keywords == null) return false;
        return KeywordMatcher.matchesAny(item.searchableText, keywords);
    }
  }
}
