enum FoodAllergy {
  peanuts,
  treeNuts,
  dairy,
  eggs,
  wheat,
  shellfish,
  fish,
  soy,
  sesame;

  String get label => switch (this) {
        FoodAllergy.peanuts => 'Peanuts',
        FoodAllergy.treeNuts => 'Tree nuts',
        FoodAllergy.dairy => 'Dairy',
        FoodAllergy.eggs => 'Eggs',
        FoodAllergy.wheat => 'Wheat',
        FoodAllergy.shellfish => 'Shellfish',
        FoodAllergy.fish => 'Fish',
        FoodAllergy.soy => 'Soy',
        FoodAllergy.sesame => 'Sesame',
      };
}
