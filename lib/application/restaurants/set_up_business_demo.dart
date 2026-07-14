import '../../domain/issues/issue_draft.dart';
import '../../domain/issues/issue_repository.dart';
import '../../domain/restaurants/menu_item_draft.dart';
import '../../domain/restaurants/restaurant_draft.dart';
import '../../domain/restaurants/restaurant_repository.dart';
import '../../domain/shared/macros.dart';
import '../../domain/shared/money.dart';

class SetUpBusinessDemo {
  final RestaurantRepository _restaurants;
  final IssueRepository _issues;

  const SetUpBusinessDemo(this._restaurants, this._issues);

  static const String _aiBurger = 'assets/demo_complaints/burgerAi.png';
  static const String _aiPizza = 'assets/demo_complaints/pizzaAi.png';
  static const String _genuineBurger = 'assets/demo_complaints/burger.jpg';

  Future<void> call({
    required int ownerUserId,
    required String ownerUsername,
  }) async {
    if (await _restaurants.findByOwner(ownerUserId) != null) return;

    final restaurantId = await _restaurants.createRestaurant(
      ownerUserId: ownerUserId,
      draft: RestaurantDraft(
        name: "$ownerUsername's Kitchen",
        cuisine: 'Comfort Food',
        deliveryFee: const Money(8),
        estimatedMinutes: 30,
      ),
    );

    for (final item in _menu(restaurantId)) {
      await _restaurants.addMenuItem(item);
    }

    for (final complaint in _complaints(restaurantId)) {
      await _issues.create(
        reporterUserId: ownerUserId,
        reporterUsername: complaint.reporter,
        draft: complaint.draft,
      );
    }
  }

  List<MenuItemDraft> _menu(int restaurantId) => [
        MenuItemDraft(
          restaurantId: restaurantId,
          name: 'Classic Cheeseburger',
          description: 'Beef patty, cheddar, lettuce, tomato and house sauce.',
          category: 'Burgers',
          price: const Money(28),
          macros: const Macros(
              calories: 720,
              protein: 34,
              carbs: 56,
              fat: 36,
              fiber: 3,
              sugar: 8),
        ),
        MenuItemDraft(
          restaurantId: restaurantId,
          name: 'Crispy Chicken Wrap',
          description: 'Fried chicken, slaw and chipotle mayo in a soft wrap.',
          category: 'Wraps',
          price: const Money(24),
          macros: const Macros(
              calories: 560,
              protein: 32,
              carbs: 48,
              fat: 22,
              fiber: 4,
              sugar: 6),
        ),
        MenuItemDraft(
          restaurantId: restaurantId,
          name: 'Loaded Fries',
          description: 'Fries with melted cheese, bacon bits and scallions.',
          category: 'Sides',
          price: const Money(16),
          macros: const Macros(
              calories: 480,
              protein: 10,
              carbs: 52,
              fat: 26,
              fiber: 5,
              sugar: 2),
        ),
        MenuItemDraft(
          restaurantId: restaurantId,
          name: 'Garden Salad',
          description: 'Mixed greens, cucumber, tomato and a lemon dressing.',
          category: 'Salads',
          price: const Money(20),
          macros: const Macros(
              calories: 220,
              protein: 8,
              carbs: 18,
              fat: 12,
              fiber: 6,
              sugar: 6),
        ),
        MenuItemDraft(
          restaurantId: restaurantId,
          name: 'Chocolate Brownie',
          description: 'Warm fudge brownie with a scoop of vanilla ice cream.',
          category: 'Desserts',
          price: const Money(14),
          macros: const Macros(
              calories: 380,
              protein: 5,
              carbs: 48,
              fat: 18,
              fiber: 2,
              sugar: 32),
        ),
        MenuItemDraft(
          restaurantId: restaurantId,
          name: 'Fresh Lemonade',
          description: 'House-made lemonade with mint.',
          category: 'Drinks',
          price: const Money(8),
          macros: const Macros(
              calories: 120,
              protein: 0,
              carbs: 30,
              fat: 0,
              fiber: 0,
              sugar: 28),
        ),
      ];

  List<_DemoComplaint> _complaints(int restaurantId) => [
        _DemoComplaint(
          reporter: 'Alex P.',
          draft: IssueDraft(
            restaurantId: restaurantId,
            orderId: null,
            description: 'My burger was nothing like this, I want a refund.',
            imageRef: _aiBurger,
          ),
        ),
        _DemoComplaint(
          reporter: 'Maria G.',
          draft: IssueDraft(
            restaurantId: restaurantId,
            orderId: null,
            description:
                'The pizza arrived burnt, see the photo — refund please.',
            imageRef: _aiPizza,
          ),
        ),
        _DemoComplaint(
          reporter: 'John D.',
          draft: IssueDraft(
            restaurantId: restaurantId,
            orderId: null,
            description: 'My burger arrived cold and soggy, see the photo.',
            imageRef: _genuineBurger,
          ),
        ),
      ];
}

class _DemoComplaint {
  final String reporter;
  final IssueDraft draft;

  const _DemoComplaint({required this.reporter, required this.draft});
}
