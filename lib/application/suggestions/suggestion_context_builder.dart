import '../../domain/constants/suggestion_constants.dart';
import '../../domain/ordering/order.dart';
import '../../domain/ordering/order_repository.dart';
import '../../domain/preferences/meal_preferences.dart';
import '../../domain/preferences/preferences_repository.dart';
import '../../domain/restaurants/menu_item_with_context.dart';
import '../../domain/restaurants/restaurant_repository.dart';
import '../../domain/suggestions/eligible_menu_item.dart';
import '../../domain/suggestions/filtering/allergy_filter.dart';
import '../../domain/suggestions/filtering/budget_filter.dart';
import '../../domain/suggestions/filtering/dietary_restriction_filter.dart';
import '../../domain/suggestions/suggestion_request.dart';
import '../auth/session_store.dart';
import '../meals/meal_totals.dart';
import '../meals/meals_store.dart';

class SuggestionContextBuilder {
  final PreferencesRepository _preferences;
  final OrderRepository _orders;
  final RestaurantRepository _restaurants;
  final SessionStore _session;
  final MealsStore _meals;
  final AllergyFilter _allergyFilter;
  final DietaryRestrictionFilter _dietaryFilter;
  final BudgetFilter _budgetFilter;
  final DateTime Function() _now;

  SuggestionContextBuilder({
    required PreferencesRepository preferences,
    required OrderRepository orders,
    required RestaurantRepository restaurants,
    required SessionStore session,
    required MealsStore meals,
    AllergyFilter allergyFilter = const AllergyFilter(),
    DietaryRestrictionFilter dietaryFilter = const DietaryRestrictionFilter(),
    BudgetFilter budgetFilter = const BudgetFilter(),
    DateTime Function()? clock,
  })  : _preferences = preferences,
        _orders = orders,
        _restaurants = restaurants,
        _session = session,
        _meals = meals,
        _allergyFilter = allergyFilter,
        _dietaryFilter = dietaryFilter,
        _budgetFilter = budgetFilter,
        _now = clock ?? DateTime.now;

  Future<SuggestionRequest> build(int userId) async {
    final preferences = await _preferences.findByUserId(userId) ??
        MealPreferences.empty(userId);
    final walletBalance = _session.current?.balance ?? 0;
    final consumed = MealTotals.forDay(_meals.current, _now());

    final catalog = await _restaurants.catalog();
    final eligibleItems = _filter(catalog, preferences, walletBalance);

    final orders = await _orders.findByUser(userId);
    final history = _recentHistory(orders, catalog);

    return SuggestionRequest(
      userId: userId,
      allergies: preferences.allergies,
      dietaryRestrictions: preferences.dietaryRestrictions,
      healthGoal: preferences.healthGoal,
      dailyCalorieTarget: preferences.dailyCalorieTarget,
      mealsPerDay: preferences.mealsPerDay,
      walletBalance: walletBalance,
      caloriesConsumedToday: consumed.calories,
      proteinConsumedToday: consumed.protein,
      carbsConsumedToday: consumed.carbs,
      fatConsumedToday: consumed.fat,
      recentMenuItemNames: history.itemNames,
      recentCuisines: history.cuisines,
      eligibleItems: eligibleItems,
      recommendationCount: SuggestionConstants.defaultRecommendationCount,
    );
  }

  List<EligibleMenuItem> _filter(
    List<MenuItemWithContext> catalog,
    MealPreferences preferences,
    double walletBalance,
  ) {
    final candidates = catalog.map(_toEligible).toList();
    var eligible = _allergyFilter.apply(candidates, preferences.allergies);
    eligible = _dietaryFilter.apply(eligible, preferences.dietaryRestrictions);
    eligible = _budgetFilter.apply(eligible, walletBalance);
    eligible.sort((a, b) => a.menuItemId.compareTo(b.menuItemId));
    return eligible;
  }

  EligibleMenuItem _toEligible(MenuItemWithContext entry) {
    final item = entry.item;
    return EligibleMenuItem(
      menuItemId: item.id,
      restaurantId: item.restaurantId,
      restaurantName: entry.restaurantName,
      cuisine: entry.cuisine,
      name: item.name,
      category: item.category,
      description: item.description,
      price: item.price.amount,
      calories: item.macros.calories,
      protein: item.macros.protein,
      carbs: item.macros.carbs,
      fat: item.macros.fat,
      fiber: item.macros.fiber,
    );
  }

  _RecentHistory _recentHistory(
    List<Order> orders,
    List<MenuItemWithContext> catalog,
  ) {
    final cutoff = _now().subtract(
        const Duration(days: SuggestionConstants.recentItemsWindowDays));
    final cuisineByRestaurant = <int, String>{
      for (final entry in catalog) entry.item.restaurantId: entry.cuisine,
    };

    final itemNames = <String>[];
    final seenNames = <String>{};
    final cuisineCounts = <String, int>{};

    for (final order in orders) {
      if (!order.createdAt.isAfter(cutoff)) continue;
      for (final line in order.lines) {
        if (seenNames.add(line.name) &&
            itemNames.length < SuggestionConstants.maxRecentItemNames) {
          itemNames.add(line.name);
        }
      }
      final cuisine = cuisineByRestaurant[order.restaurantId];
      if (cuisine != null) {
        cuisineCounts[cuisine] = (cuisineCounts[cuisine] ?? 0) + 1;
      }
    }

    final cuisines = cuisineCounts.keys.toList()
      ..sort((a, b) {
        final byCount = cuisineCounts[b]!.compareTo(cuisineCounts[a]!);
        return byCount != 0 ? byCount : a.compareTo(b);
      });

    return _RecentHistory(itemNames: itemNames, cuisines: cuisines);
  }
}

class _RecentHistory {
  final List<String> itemNames;
  final List<String> cuisines;

  const _RecentHistory({required this.itemNames, required this.cuisines});
}
