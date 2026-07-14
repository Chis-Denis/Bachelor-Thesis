import '../../preferences/dietary_restriction.dart';
import 'food_keyword_groups.dart';

final Map<DietaryRestriction, Set<String>> dietaryRestrictionKeywords = {
  DietaryRestriction.vegetarian: {
    ...FoodKeywordGroups.meat,
    ...FoodKeywordGroups.shellfish,
    ...FoodKeywordGroups.fish,
  },
  DietaryRestriction.vegan: {
    ...FoodKeywordGroups.meat,
    ...FoodKeywordGroups.shellfish,
    ...FoodKeywordGroups.fish,
    ...FoodKeywordGroups.dairy,
    'egg',
    'honey',
    'mayonnaise',
    'hollandaise',
  },
  DietaryRestriction.glutenFree: {...FoodKeywordGroups.gluten},
  DietaryRestriction.dairyFree: {...FoodKeywordGroups.dairy},
  DietaryRestriction.paleo: {
    ...FoodKeywordGroups.grains,
    ...FoodKeywordGroups.legumes,
    ...FoodKeywordGroups.dairy,
  },
  DietaryRestriction.halal: {
    ...FoodKeywordGroups.pork,
    ...FoodKeywordGroups.alcohol,
  },
  DietaryRestriction.kosher: {
    ...FoodKeywordGroups.pork,
    ...FoodKeywordGroups.shellfish,
  },
};
