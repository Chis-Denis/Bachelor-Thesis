import '../database/database.dart';
import '../features/auth/services/auth_controller.dart';
import '../features/auth/services/auth_repository.dart';
import '../features/foods/services/food_repository.dart';
import '../features/foods/services/usda_nutrition_service.dart';
import '../features/meals/services/meal_repository.dart';
import '../features/meals/services/meals_controller.dart';
import '../features/orders/services/cart_controller.dart';
import '../features/orders/services/order_repository.dart';
import '../features/restaurants/services/restaurant_repository.dart';
import '../features/restaurants/services/restaurant_seeder.dart';
import '../utils/password_hasher.dart';
import 'config.dart';

late final AuthController authController;
late final MealsController mealsController;
late final FoodRepository foodRepository;
late final RestaurantRepository restaurantRepository;
late final OrderRepository orderRepository;
late final CartController cartController;

Future<void> setupDependencies() async {
  final database = AppDatabase();
  await database.open();

  final restaurantSeeder = RestaurantSeeder(database);
  await restaurantSeeder.ensureSeeded();

  final authRepository = AuthRepository(database, const PasswordHasher());
  final usdaService = UsdaNutritionService(
    apiKey: AppConfig.usdaApiKey,
    baseUrl: AppConfig.usdaBaseUrl,
  );
  foodRepository = FoodRepository(database, authRepository, usdaService);
  restaurantRepository = RestaurantRepository(database);
  orderRepository = OrderRepository(database, authRepository);
  cartController = CartController();
  final mealRepository =
      MealRepository(database, authRepository, foodRepository);

  authController = AuthController(authRepository);
  mealsController = MealsController(mealRepository);
}
