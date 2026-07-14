import '../application/auth/add_funds.dart';
import '../application/auth/change_password.dart';
import '../application/auth/login_user.dart';
import '../application/auth/logout_user.dart';
import '../application/auth/register_user.dart';
import '../application/auth/session_store.dart';
import '../application/foods/search_foods.dart';
import '../application/meals/add_meal.dart';
import '../application/meals/delete_meal.dart';
import '../application/meals/get_meal.dart';
import '../application/meals/load_meals.dart';
import '../application/meals/meals_store.dart';
import '../application/meals/update_meal.dart';
import '../application/ordering/cart_service.dart';
import '../application/ordering/list_orders.dart';
import '../application/ordering/place_order.dart';
import '../application/preferences/get_meal_preferences.dart';
import '../application/preferences/save_meal_preferences.dart';
import '../application/issues/check_issue_photo.dart';
import '../application/issues/list_my_restaurant_issues.dart';
import '../application/issues/report_issue.dart';
import '../application/restaurants/add_menu_item.dart';
import '../application/restaurants/delete_menu_item.dart';
import '../application/restaurants/discover_restaurants.dart';
import '../application/restaurants/get_my_restaurant.dart';
import '../application/restaurants/get_restaurant.dart';
import '../application/restaurants/get_restaurant_menu.dart';
import '../application/restaurants/save_my_restaurant.dart';
import '../application/restaurants/set_up_business_demo.dart';
import '../application/restaurants/update_menu_item.dart';
import '../application/settings/get_user_settings.dart';
import '../application/settings/save_user_settings.dart';
import '../application/suggestions/suggest_meals.dart';
import '../application/suggestions/suggestion_context_builder.dart';
import '../config/app_config.dart';
import '../config/env_app_config.dart';
import '../domain/foods/food_ranking_service.dart';
import '../domain/foods/nutrition_plausibility.dart';
import '../domain/issues/forensic_evaluator.dart';
import '../domain/restaurants/restaurant_search_service.dart';
import '../infrastructure/forensics/asset_complaint_image_store.dart';
import '../infrastructure/forensics/image_metadata_parser.dart';
import '../infrastructure/forensics/image_picker_photo_capture.dart';
import '../infrastructure/persistence/app_database.dart';
import '../infrastructure/persistence/sqflite_unit_of_work.dart';
import '../infrastructure/remote/openai_client.dart';
import '../infrastructure/remote/openai_forensic_narrator.dart';
import '../infrastructure/remote/openai_meal_suggestion_repository.dart';
import '../infrastructure/remote/usda_client.dart';
import '../infrastructure/repositories/sqflite_auth_repository.dart';
import '../infrastructure/repositories/sqflite_food_repository.dart';
import '../infrastructure/repositories/sqflite_issue_repository.dart';
import '../infrastructure/repositories/sqflite_meal_repository.dart';
import '../infrastructure/repositories/sqflite_order_repository.dart';
import '../infrastructure/repositories/sqflite_preferences_repository.dart';
import '../infrastructure/repositories/sqflite_restaurant_repository.dart';
import '../infrastructure/repositories/sqflite_settings_repository.dart';
import '../infrastructure/security/pbkdf2_password_hasher.dart';
import '../infrastructure/seed/restaurant_seeder.dart';
import '../presentation/common/app_dependencies.dart';

class CompositionRoot {
  CompositionRoot._();

  static Future<AppDependencies> create() async {
    final database = AppDatabase();
    await database.open();
    await RestaurantSeeder(database).ensureSeeded();

    final unitOfWork = SqfliteUnitOfWork(database);
    const hasher = Pbkdf2PasswordHasher();

    final authRepository = SqfliteAuthRepository(unitOfWork);
    final mealRepository = SqfliteMealRepository(unitOfWork);
    final foodRepository = SqfliteFoodRepository(unitOfWork);
    final restaurantRepository = SqfliteRestaurantRepository(unitOfWork);
    final orderRepository = SqfliteOrderRepository(unitOfWork);
    final preferencesRepository = SqflitePreferencesRepository(unitOfWork);
    final settingsRepository = SqfliteSettingsRepository(unitOfWork);
    final issueRepository = SqfliteIssueRepository(unitOfWork);
    const AppConfig config = EnvAppConfig();
    final remoteFoodSource = UsdaClient(
      apiKey: config.usdaApiKey,
      baseUrl: config.usdaBaseUrl,
    );
    final openAiClient = OpenAiClient(
      apiKey: config.openAiApiKey,
      baseUrl: config.openAiBaseUrl,
    );
    final mealSuggestionRepository =
        OpenAiMealSuggestionRepository(openAiClient);
    const complaintImageStore = AssetComplaintImageStore();
    final complaintPhotoCapture = ImagePickerPhotoCapture();

    final session = SessionStore();
    final mealsStore = MealsStore();
    final cartService = CartService();

    final loadMeals = LoadMeals(mealRepository, session, mealsStore);
    final suggestionContextBuilder = SuggestionContextBuilder(
      preferences: preferencesRepository,
      orders: orderRepository,
      restaurants: restaurantRepository,
      session: session,
      meals: mealsStore,
    );

    return AppDependencies(
      session: session,
      loginUser: LoginUser(authRepository, hasher, session),
      registerUser: RegisterUser(authRepository, hasher),
      logoutUser: LogoutUser(session, mealsStore, cartService),
      changePassword: ChangePassword(authRepository, hasher, session),
      addFunds: AddFunds(authRepository, session),
      mealsStore: mealsStore,
      loadMeals: loadMeals,
      addMeal: AddMeal(mealRepository, foodRepository, session, loadMeals),
      updateMeal:
          UpdateMeal(mealRepository, foodRepository, session, loadMeals),
      deleteMeal: DeleteMeal(mealRepository, session, loadMeals),
      getMeal: GetMeal(mealRepository, session),
      searchFoods: SearchFoods(
        foodRepository,
        remoteFoodSource,
        session,
        const FoodRankingService(),
        const NutritionPlausibility(),
      ),
      discoverRestaurants: DiscoverRestaurants(
        restaurantRepository,
        const RestaurantSearchService(),
      ),
      getRestaurant: GetRestaurant(restaurantRepository),
      getRestaurantMenu: GetRestaurantMenu(restaurantRepository),
      cartService: cartService,
      placeOrder: PlaceOrder(
        cartService,
        session,
        authRepository,
        orderRepository,
        mealRepository,
        foodRepository,
        unitOfWork,
        loadMeals,
      ),
      listOrders: ListOrders(orderRepository, session),
      getMealPreferences: GetMealPreferences(preferencesRepository),
      saveMealPreferences: SaveMealPreferences(preferencesRepository),
      getUserSettings: GetUserSettings(settingsRepository),
      saveUserSettings: SaveUserSettings(settingsRepository),
      suggestMeals: SuggestMeals(
        session,
        suggestionContextBuilder,
        mealSuggestionRepository,
      ),
      getMyRestaurant: GetMyRestaurant(restaurantRepository, session),
      saveMyRestaurant: SaveMyRestaurant(restaurantRepository, session),
      setUpBusinessDemo:
          SetUpBusinessDemo(restaurantRepository, issueRepository),
      addMenuItem: AddMenuItem(restaurantRepository),
      updateMenuItem: UpdateMenuItem(restaurantRepository),
      deleteMenuItem: DeleteMenuItem(restaurantRepository),
      reportIssue: ReportIssue(issueRepository, session),
      listMyRestaurantIssues: ListMyRestaurantIssues(
          issueRepository, restaurantRepository, session),
      checkIssuePhoto: CheckIssuePhoto(
        issueRepository,
        complaintImageStore,
        const ImageMetadataParser(),
        const ForensicEvaluator(),
        OpenAiForensicNarrator(openAiClient),
      ),
      complaintImageStore: complaintImageStore,
      complaintPhotoCapture: complaintPhotoCapture,
    );
  }
}
