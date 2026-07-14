import '../../preferences/food_allergy.dart';
import 'food_keyword_groups.dart';

final Map<FoodAllergy, Set<String>> allergyKeywords = {
  FoodAllergy.peanuts: const {
    'peanut',
    'groundnut',
    'satay',
  },
  FoodAllergy.treeNuts: const {
    'almond',
    'walnut',
    'cashew',
    'pistachio',
    'hazelnut',
    'pecan',
    'macadamia',
    'pine nut',
    'praline',
    'marzipan',
    'nutella',
  },
  FoodAllergy.dairy: FoodKeywordGroups.dairy,
  FoodAllergy.eggs: const {
    'egg',
    'omelette',
    'frittata',
    'mayonnaise',
    'hollandaise',
    'meringue',
    'custard',
    'carbonara',
    'benedict',
  },
  FoodAllergy.wheat: FoodKeywordGroups.gluten,
  FoodAllergy.shellfish: FoodKeywordGroups.shellfish,
  FoodAllergy.fish: FoodKeywordGroups.fish,
  FoodAllergy.soy: const {
    'soy',
    'tofu',
    'edamame',
    'tempeh',
    'miso',
    'tamari',
    'teriyaki',
    'soybean',
  },
  FoodAllergy.sesame: const {
    'sesame',
    'tahini',
    'hummus',
    'halva',
  },
};
