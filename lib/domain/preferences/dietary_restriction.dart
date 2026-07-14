enum DietaryRestriction {
  vegetarian,
  vegan,
  glutenFree,
  dairyFree,
  keto,
  paleo,
  halal,
  kosher,
  lowCarb;

  String get label => switch (this) {
        DietaryRestriction.vegetarian => 'Vegetarian',
        DietaryRestriction.vegan => 'Vegan',
        DietaryRestriction.glutenFree => 'Gluten-free',
        DietaryRestriction.dairyFree => 'Dairy-free',
        DietaryRestriction.keto => 'Keto',
        DietaryRestriction.paleo => 'Paleo',
        DietaryRestriction.halal => 'Halal',
        DietaryRestriction.kosher => 'Kosher',
        DietaryRestriction.lowCarb => 'Low-carb',
      };
}
