class UsersTable {
  UsersTable._();

  static const String name = 'users';
  static const String id = 'id';
  static const String username = 'username';
  static const String passwordHash = 'password_hash';
  static const String salt = 'salt';
  static const String createdAt = 'created_at';
  static const String balance = 'balance';
  static const String isBusinessOwner = 'is_business_owner';
}

class FoodsTable {
  FoodsTable._();

  static const String name = 'foods';
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String fdcId = 'fdc_id';
  static const String foodName = 'food_name';
  static const String calories = 'calories';
  static const String protein = 'protein';
  static const String carbs = 'carbs';
  static const String fat = 'fat';
  static const String fiber = 'fiber';
  static const String sugar = 'sugar';
  static const String servingSize = 'serving_size';
  static const String servingUnit = 'serving_unit';
  static const String createdAt = 'created_at';
}

class RestaurantsTable {
  RestaurantsTable._();

  static const String name = 'restaurants';
  static const String id = 'id';
  static const String restaurantName = 'name';
  static const String cuisine = 'cuisine';
  static const String deliveryFee = 'delivery_fee';
  static const String rating = 'rating';
  static const String estimatedMinutes = 'estimated_minutes';
  static const String createdAt = 'created_at';
  static const String ownerUserId = 'owner_user_id';
}

class IssuesTable {
  IssuesTable._();

  static const String name = 'issues';
  static const String id = 'id';
  static const String restaurantId = 'restaurant_id';
  static const String orderId = 'order_id';
  static const String reporterUserId = 'reporter_user_id';
  static const String reporterUsername = 'reporter_username';
  static const String description = 'description';
  static const String imageRef = 'image_ref';
  static const String createdAt = 'created_at';
  static const String status = 'status';
  static const String verdict = 'verdict';
  static const String confidence = 'confidence';
  static const String evidenceJson = 'evidence_json';
  static const String aiSummary = 'ai_summary';
}

class MenuItemsTable {
  MenuItemsTable._();

  static const String name = 'menu_items';
  static const String id = 'id';
  static const String restaurantId = 'restaurant_id';
  static const String itemName = 'name';
  static const String description = 'description';
  static const String price = 'price';
  static const String calories = 'calories';
  static const String protein = 'protein';
  static const String carbs = 'carbs';
  static const String fat = 'fat';
  static const String fiber = 'fiber';
  static const String sugar = 'sugar';
  static const String category = 'category';
}

class OrdersTable {
  OrdersTable._();

  static const String name = 'orders';
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String restaurantId = 'restaurant_id';
  static const String restaurantName = 'restaurant_name';
  static const String subtotal = 'subtotal';
  static const String deliveryFee = 'delivery_fee';
  static const String total = 'total';
  static const String createdAt = 'created_at';
}

class OrderItemsTable {
  OrderItemsTable._();

  static const String name = 'order_items';
  static const String id = 'id';
  static const String orderId = 'order_id';
  static const String menuItemId = 'menu_item_id';
  static const String itemName = 'name';
  static const String description = 'description';
  static const String price = 'price';
  static const String quantity = 'quantity';
  static const String calories = 'calories';
  static const String protein = 'protein';
  static const String carbs = 'carbs';
  static const String fat = 'fat';
  static const String fiber = 'fiber';
  static const String sugar = 'sugar';
}

class MealPreferencesTable {
  MealPreferencesTable._();

  static const String name = 'meal_preferences';
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String dietaryRestrictions = 'dietary_restrictions';
  static const String allergies = 'allergies';
  static const String healthGoal = 'health_goal';
  static const String dailyCalorieTarget = 'daily_calorie_target';
  static const String mealsPerDay = 'meals_per_day';
}

class UserSettingsTable {
  UserSettingsTable._();

  static const String name = 'user_settings';
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String defaultUnit = 'default_unit';
}

class MealsTable {
  MealsTable._();

  static const String name = 'meals';
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String mealName = 'meal_name';
  static const String mealType = 'meal_type';
  static const String quantity = 'quantity';
  static const String unit = 'unit';
  static const String calories = 'calories';
  static const String protein = 'protein';
  static const String carbs = 'carbs';
  static const String fat = 'fat';
  static const String fiber = 'fiber';
  static const String sugar = 'sugar';
  static const String date = 'date';
  static const String notes = 'notes';
}
