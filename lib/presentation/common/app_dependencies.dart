import '../../application/auth/add_funds.dart';
import '../../application/auth/change_password.dart';
import '../../application/auth/login_user.dart';
import '../../application/auth/logout_user.dart';
import '../../application/auth/register_user.dart';
import '../../application/auth/session_store.dart';
import '../../application/foods/search_foods.dart';
import '../../application/issues/check_issue_photo.dart';
import '../../application/issues/list_my_restaurant_issues.dart';
import '../../application/issues/report_issue.dart';
import '../../application/meals/add_meal.dart';
import '../../application/meals/delete_meal.dart';
import '../../application/meals/get_meal.dart';
import '../../application/meals/load_meals.dart';
import '../../application/meals/meals_store.dart';
import '../../application/meals/update_meal.dart';
import '../../application/ordering/cart_service.dart';
import '../../application/ordering/list_orders.dart';
import '../../application/ordering/place_order.dart';
import '../../application/preferences/get_meal_preferences.dart';
import '../../application/preferences/save_meal_preferences.dart';
import '../../application/restaurants/add_menu_item.dart';
import '../../application/restaurants/delete_menu_item.dart';
import '../../application/restaurants/discover_restaurants.dart';
import '../../application/restaurants/get_my_restaurant.dart';
import '../../application/restaurants/get_restaurant.dart';
import '../../application/restaurants/get_restaurant_menu.dart';
import '../../application/restaurants/save_my_restaurant.dart';
import '../../application/restaurants/set_up_business_demo.dart';
import '../../application/restaurants/update_menu_item.dart';
import '../../application/settings/get_user_settings.dart';
import '../../application/settings/save_user_settings.dart';
import '../../application/suggestions/suggest_meals.dart';
import '../../domain/issues/complaint_image_store.dart';
import '../../domain/issues/complaint_photo_capture.dart';

class AppDependencies {
  final SessionStore session;
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final LogoutUser logoutUser;
  final ChangePassword changePassword;
  final AddFunds addFunds;
  final MealsStore mealsStore;
  final LoadMeals loadMeals;
  final AddMeal addMeal;
  final UpdateMeal updateMeal;
  final DeleteMeal deleteMeal;
  final GetMeal getMeal;
  final SearchFoods searchFoods;
  final DiscoverRestaurants discoverRestaurants;
  final GetRestaurant getRestaurant;
  final GetRestaurantMenu getRestaurantMenu;
  final CartService cartService;
  final PlaceOrder placeOrder;
  final ListOrders listOrders;
  final GetMealPreferences getMealPreferences;
  final SaveMealPreferences saveMealPreferences;
  final GetUserSettings getUserSettings;
  final SaveUserSettings saveUserSettings;
  final SuggestMeals suggestMeals;
  final GetMyRestaurant getMyRestaurant;
  final SaveMyRestaurant saveMyRestaurant;
  final SetUpBusinessDemo setUpBusinessDemo;
  final AddMenuItem addMenuItem;
  final UpdateMenuItem updateMenuItem;
  final DeleteMenuItem deleteMenuItem;
  final ReportIssue reportIssue;
  final ListMyRestaurantIssues listMyRestaurantIssues;
  final CheckIssuePhoto checkIssuePhoto;
  final ComplaintImageStore complaintImageStore;
  final ComplaintPhotoCapture complaintPhotoCapture;

  const AppDependencies({
    required this.session,
    required this.loginUser,
    required this.registerUser,
    required this.logoutUser,
    required this.changePassword,
    required this.addFunds,
    required this.mealsStore,
    required this.loadMeals,
    required this.addMeal,
    required this.updateMeal,
    required this.deleteMeal,
    required this.getMeal,
    required this.searchFoods,
    required this.discoverRestaurants,
    required this.getRestaurant,
    required this.getRestaurantMenu,
    required this.cartService,
    required this.placeOrder,
    required this.listOrders,
    required this.getMealPreferences,
    required this.saveMealPreferences,
    required this.getUserSettings,
    required this.saveUserSettings,
    required this.suggestMeals,
    required this.getMyRestaurant,
    required this.saveMyRestaurant,
    required this.setUpBusinessDemo,
    required this.addMenuItem,
    required this.updateMenuItem,
    required this.deleteMenuItem,
    required this.reportIssue,
    required this.listMyRestaurantIssues,
    required this.checkIssuePhoto,
    required this.complaintImageStore,
    required this.complaintPhotoCapture,
  });
}
