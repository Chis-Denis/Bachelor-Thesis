import '../../../database/database.dart';

class RestaurantSeeder {
  final AppDatabase _database;

  RestaurantSeeder(this._database);

  Future<void> ensureSeeded() async {
    final db = await _database.open();
    final countRows = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM ${RestaurantsTable.name}',
    );
    final count = (countRows.first['c'] as num?)?.toInt() ?? 0;
    if (count > 0) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction((txn) async {
      for (final restaurant in _sampleData) {
        final restaurantId = await txn.insert(RestaurantsTable.name, {
          RestaurantsTable.restaurantName: restaurant.name,
          RestaurantsTable.cuisine: restaurant.cuisine,
          RestaurantsTable.deliveryFee: restaurant.deliveryFee,
          RestaurantsTable.rating: restaurant.rating,
          RestaurantsTable.estimatedMinutes: restaurant.estimatedMinutes,
          RestaurantsTable.createdAt: now,
        });
        for (final item in restaurant.items) {
          await txn.insert(MenuItemsTable.name, {
            MenuItemsTable.restaurantId: restaurantId,
            MenuItemsTable.itemName: item.name,
            MenuItemsTable.description: item.description,
            MenuItemsTable.category: item.category,
            MenuItemsTable.price: item.price,
            MenuItemsTable.calories: item.calories,
            MenuItemsTable.protein: item.protein,
            MenuItemsTable.carbs: item.carbs,
            MenuItemsTable.fat: item.fat,
            MenuItemsTable.fiber: item.fiber,
            MenuItemsTable.sugar: item.sugar,
          });
        }
      }
    });
  }
}

class _SeedRestaurant {
  final String name;
  final String cuisine;
  final double deliveryFee;
  final double rating;
  final int estimatedMinutes;
  final List<_SeedItem> items;

  const _SeedRestaurant({
    required this.name,
    required this.cuisine,
    required this.deliveryFee,
    required this.rating,
    required this.estimatedMinutes,
    required this.items,
  });
}

class _SeedItem {
  final String name;
  final String description;
  final String category;
  final double price;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;

  const _SeedItem({
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
  });
}

const List<_SeedRestaurant> _sampleData = [
  _SeedRestaurant(
    name: 'Pizza Luca',
    cuisine: 'Italian',
    deliveryFee: 8,
    rating: 4.6,
    estimatedMinutes: 35,
    items: [
      _SeedItem(
        name: 'Margherita Pizza',
        category: 'Pizza',
        description:
            'Hand-stretched dough with San Marzano tomato sauce, fior di '
            'latte mozzarella and fresh basil leaves.',
        price: 32,
        calories: 780,
        protein: 28,
        carbs: 96,
        fat: 28,
        fiber: 5,
        sugar: 8,
      ),
      _SeedItem(
        name: 'Pepperoni Pizza',
        category: 'Pizza',
        description:
            'Tomato base, mozzarella and spicy Italian pepperoni baked on a '
            'thin crust.',
        price: 38,
        calories: 920,
        protein: 36,
        carbs: 100,
        fat: 40,
        fiber: 5,
        sugar: 8,
      ),
      _SeedItem(
        name: 'Quattro Formaggi',
        category: 'Pizza',
        description:
            'A blend of mozzarella, gorgonzola, parmesan and smoked '
            'scamorza on a creamy white base.',
        price: 40,
        calories: 950,
        protein: 42,
        carbs: 90,
        fat: 48,
        fiber: 4,
        sugar: 6,
      ),
      _SeedItem(
        name: 'Spaghetti Carbonara',
        category: 'Pasta',
        description:
            'Classic Roman pasta with crispy pancetta, egg yolk, pecorino '
            'romano and freshly ground black pepper.',
        price: 34,
        calories: 680,
        protein: 26,
        carbs: 70,
        fat: 30,
        fiber: 3,
        sugar: 4,
      ),
      _SeedItem(
        name: 'Lasagna Bolognese',
        category: 'Pasta',
        description:
            'Layers of fresh pasta, slow-cooked beef ragu, bechamel sauce '
            'and aged parmigiano.',
        price: 36,
        calories: 720,
        protein: 32,
        carbs: 65,
        fat: 34,
        fiber: 4,
        sugar: 9,
      ),
      _SeedItem(
        name: 'Caesar Salad',
        category: 'Salads',
        description:
            'Crisp romaine lettuce tossed with Caesar dressing, shaved '
            'parmesan, anchovies and homemade croutons.',
        price: 28,
        calories: 420,
        protein: 18,
        carbs: 20,
        fat: 28,
        fiber: 3,
        sugar: 3,
      ),
      _SeedItem(
        name: 'Garlic Bread',
        category: 'Sides',
        description:
            'Toasted ciabatta brushed with garlic butter, olive oil and a '
            'sprinkle of parsley.',
        price: 14,
        calories: 310,
        protein: 8,
        carbs: 40,
        fat: 12,
        fiber: 2,
        sugar: 2,
      ),
      _SeedItem(
        name: 'Tiramisu',
        category: 'Desserts',
        description:
            'Layered dessert with espresso-soaked ladyfingers, mascarpone '
            'cream and a dusting of cocoa.',
        price: 18,
        calories: 380,
        protein: 6,
        carbs: 40,
        fat: 22,
        fiber: 1,
        sugar: 28,
      ),
    ],
  ),
  _SeedRestaurant(
    name: 'Taco Fiesta',
    cuisine: 'Mexican',
    deliveryFee: 10,
    rating: 4.4,
    estimatedMinutes: 30,
    items: [
      _SeedItem(
        name: 'Beef Burrito',
        category: 'Burritos & Wraps',
        description:
            'Large flour tortilla wrapped around seasoned beef, rice, black '
            'beans, cheese and pico de gallo.',
        price: 30,
        calories: 820,
        protein: 38,
        carbs: 84,
        fat: 32,
        fiber: 9,
        sugar: 5,
      ),
      _SeedItem(
        name: 'Chicken Quesadilla',
        category: 'Burritos & Wraps',
        description:
            'Grilled flour tortilla stuffed with shredded chicken, melted '
            'cheese and a hint of chipotle.',
        price: 28,
        calories: 720,
        protein: 42,
        carbs: 60,
        fat: 32,
        fiber: 4,
        sugar: 4,
      ),
      _SeedItem(
        name: 'Beef Tacos (3 pcs)',
        category: 'Tacos',
        description:
            'Three soft corn tortillas filled with seasoned ground beef, '
            'lettuce, cheese and salsa roja.',
        price: 26,
        calories: 640,
        protein: 32,
        carbs: 50,
        fat: 30,
        fiber: 6,
        sugar: 4,
      ),
      _SeedItem(
        name: 'Guacamole & Chips',
        category: 'Sides',
        description:
            'Freshly mashed avocado with lime, cilantro and tomato, served '
            'with crispy tortilla chips.',
        price: 18,
        calories: 450,
        protein: 6,
        carbs: 44,
        fat: 28,
        fiber: 10,
        sugar: 3,
      ),
      _SeedItem(
        name: 'Veggie Fajita',
        category: 'Mains',
        description:
            'Sizzling skillet of bell peppers, onions and mushrooms with '
            'warm tortillas and salsa.',
        price: 32,
        calories: 580,
        protein: 22,
        carbs: 70,
        fat: 22,
        fiber: 9,
        sugar: 10,
      ),
      _SeedItem(
        name: 'Chili con Carne',
        category: 'Mains',
        description:
            'Slow-simmered beef and kidney beans in a smoky tomato chili '
            'sauce, topped with sour cream.',
        price: 34,
        calories: 680,
        protein: 36,
        carbs: 42,
        fat: 32,
        fiber: 11,
        sugar: 8,
      ),
    ],
  ),
  _SeedRestaurant(
    name: 'Burger Station',
    cuisine: 'American',
    deliveryFee: 7,
    rating: 4.5,
    estimatedMinutes: 25,
    items: [
      _SeedItem(
        name: 'Classic Cheeseburger',
        category: 'Burgers',
        description:
            'Juicy beef patty with melted cheddar, lettuce, tomato, pickles '
            'and house sauce in a brioche bun.',
        price: 28,
        calories: 720,
        protein: 34,
        carbs: 56,
        fat: 36,
        fiber: 3,
        sugar: 8,
      ),
      _SeedItem(
        name: 'Double Bacon Burger',
        category: 'Burgers',
        description:
            'Two beef patties stacked with crispy bacon, double cheddar, '
            'caramelized onions and BBQ sauce.',
        price: 36,
        calories: 960,
        protein: 48,
        carbs: 58,
        fat: 52,
        fiber: 3,
        sugar: 10,
      ),
      _SeedItem(
        name: 'Chicken Burger',
        category: 'Burgers',
        description:
            'Grilled chicken breast with lettuce, tomato, mayo and pickled '
            'cucumbers in a sesame bun.',
        price: 26,
        calories: 640,
        protein: 38,
        carbs: 52,
        fat: 28,
        fiber: 3,
        sugar: 7,
      ),
      _SeedItem(
        name: 'Veggie Burger',
        category: 'Burgers',
        description:
            'House-made bean and quinoa patty with avocado, lettuce, tomato '
            'and chipotle mayo.',
        price: 24,
        calories: 520,
        protein: 22,
        carbs: 60,
        fat: 22,
        fiber: 8,
        sugar: 6,
      ),
      _SeedItem(
        name: 'Crispy Fries',
        category: 'Sides',
        description:
            'Hand-cut potato fries fried until golden and crispy, finished '
            'with sea salt.',
        price: 12,
        calories: 380,
        protein: 5,
        carbs: 48,
        fat: 18,
        fiber: 4,
        sugar: 1,
      ),
      _SeedItem(
        name: 'Onion Rings',
        category: 'Sides',
        description:
            'Sweet onion slices coated in seasoned beer batter and fried '
            'until crunchy.',
        price: 14,
        calories: 340,
        protein: 4,
        carbs: 40,
        fat: 18,
        fiber: 3,
        sugar: 5,
      ),
      _SeedItem(
        name: 'Chocolate Milkshake',
        category: 'Drinks',
        description:
            'Thick milkshake blended with cocoa, vanilla ice cream and a '
            'whipped cream topping.',
        price: 16,
        calories: 480,
        protein: 10,
        carbs: 70,
        fat: 18,
        fiber: 1,
        sugar: 56,
      ),
    ],
  ),
  _SeedRestaurant(
    name: 'Sakura Sushi',
    cuisine: 'Japanese',
    deliveryFee: 12,
    rating: 4.7,
    estimatedMinutes: 40,
    items: [
      _SeedItem(
        name: 'Salmon Nigiri (6 pcs)',
        category: 'Sushi',
        description:
            'Six pieces of hand-pressed sushi rice topped with fresh '
            'Atlantic salmon and a brush of soy.',
        price: 32,
        calories: 240,
        protein: 26,
        carbs: 24,
        fat: 6,
        fiber: 1,
        sugar: 2,
      ),
      _SeedItem(
        name: 'Tuna Maki (8 pcs)',
        category: 'Sushi',
        description:
            'Eight bite-sized rolls of tuna and sushi rice wrapped in nori '
            'seaweed.',
        price: 30,
        calories: 220,
        protein: 20,
        carbs: 30,
        fat: 3,
        fiber: 2,
        sugar: 3,
      ),
      _SeedItem(
        name: 'California Roll',
        category: 'Sushi',
        description:
            'Inside-out roll with crab, avocado and cucumber, coated in '
            'sesame seeds and tobiko.',
        price: 28,
        calories: 320,
        protein: 14,
        carbs: 40,
        fat: 10,
        fiber: 3,
        sugar: 4,
      ),
      _SeedItem(
        name: 'Chicken Teriyaki Bowl',
        category: 'Mains',
        description:
            'Grilled chicken thigh glazed with sweet teriyaki sauce, served '
            'over steamed rice with sesame and scallions.',
        price: 36,
        calories: 640,
        protein: 42,
        carbs: 70,
        fat: 18,
        fiber: 2,
        sugar: 14,
      ),
      _SeedItem(
        name: 'Miso Soup',
        category: 'Sides',
        description:
            'Traditional Japanese soup with white miso, soft tofu, wakame '
            'seaweed and chopped scallions.',
        price: 10,
        calories: 80,
        protein: 5,
        carbs: 6,
        fat: 3,
        fiber: 1,
        sugar: 1,
      ),
      _SeedItem(
        name: 'Edamame',
        category: 'Sides',
        description:
            'Steamed young soybeans tossed in flaky sea salt, served warm '
            'in the pod.',
        price: 12,
        calories: 160,
        protein: 14,
        carbs: 14,
        fat: 6,
        fiber: 8,
        sugar: 3,
      ),
      _SeedItem(
        name: 'Vegetable Tempura',
        category: 'Sides',
        description:
            'Assorted seasonal vegetables battered in light tempura and '
            'fried crispy, with tentsuyu dipping sauce.',
        price: 24,
        calories: 420,
        protein: 8,
        carbs: 44,
        fat: 22,
        fiber: 5,
        sugar: 5,
      ),
    ],
  ),
  _SeedRestaurant(
    name: 'Green Bowl',
    cuisine: 'Healthy',
    deliveryFee: 6,
    rating: 4.8,
    estimatedMinutes: 25,
    items: [
      _SeedItem(
        name: 'Chicken Caesar Salad',
        category: 'Salads',
        description:
            'Grilled chicken breast over romaine lettuce, parmesan shavings, '
            'croutons and Caesar dressing.',
        price: 28,
        calories: 420,
        protein: 38,
        carbs: 18,
        fat: 22,
        fiber: 3,
        sugar: 3,
      ),
      _SeedItem(
        name: 'Quinoa Power Bowl',
        category: 'Bowls',
        description:
            'Tri-color quinoa with roasted sweet potato, chickpeas, kale, '
            'avocado and tahini-lemon dressing.',
        price: 32,
        calories: 520,
        protein: 24,
        carbs: 70,
        fat: 16,
        fiber: 12,
        sugar: 8,
      ),
      _SeedItem(
        name: 'Mediterranean Wrap',
        category: 'Wraps & Toasts',
        description:
            'Whole-wheat wrap filled with hummus, grilled vegetables, feta '
            'and a drizzle of olive oil.',
        price: 26,
        calories: 480,
        protein: 22,
        carbs: 56,
        fat: 18,
        fiber: 8,
        sugar: 6,
      ),
      _SeedItem(
        name: 'Avocado Toast',
        category: 'Wraps & Toasts',
        description:
            'Sourdough toast topped with smashed avocado, cherry tomatoes, '
            'chili flakes and a poached egg.',
        price: 22,
        calories: 380,
        protein: 14,
        carbs: 38,
        fat: 18,
        fiber: 8,
        sugar: 4,
      ),
      _SeedItem(
        name: 'Greek Yogurt Parfait',
        category: 'Breakfast',
        description:
            'Thick Greek yogurt layered with house granola, fresh berries '
            'and a drizzle of honey.',
        price: 18,
        calories: 280,
        protein: 16,
        carbs: 34,
        fat: 8,
        fiber: 4,
        sugar: 22,
      ),
      _SeedItem(
        name: 'Fresh Fruit Smoothie',
        category: 'Drinks',
        description:
            'Blend of banana, strawberries, mango and orange juice with a '
            'touch of fresh ginger.',
        price: 16,
        calories: 220,
        protein: 6,
        carbs: 46,
        fat: 2,
        fiber: 5,
        sugar: 36,
      ),
      _SeedItem(
        name: 'Grilled Salmon Salad',
        category: 'Salads',
        description:
            'Grilled salmon fillet over mixed greens with cucumber, '
            'avocado, cherry tomatoes and lemon vinaigrette.',
        price: 38,
        calories: 480,
        protein: 36,
        carbs: 20,
        fat: 24,
        fiber: 6,
        sugar: 5,
      ),
    ],
  ),
  _SeedRestaurant(
    name: 'Kebab House',
    cuisine: 'Middle Eastern',
    deliveryFee: 8,
    rating: 4.3,
    estimatedMinutes: 30,
    items: [
      _SeedItem(
        name: 'Chicken Shawarma',
        category: 'Wraps',
        description:
            'Marinated chicken thighs slow-roasted on a vertical spit, '
            'wrapped in pita with garlic sauce and pickles.',
        price: 24,
        calories: 580,
        protein: 42,
        carbs: 50,
        fat: 22,
        fiber: 4,
        sugar: 5,
      ),
      _SeedItem(
        name: 'Lamb Kebab Plate',
        category: 'Plates',
        description:
            'Char-grilled lamb skewers served with basmati rice, grilled '
            'vegetables and tzatziki sauce.',
        price: 32,
        calories: 720,
        protein: 48,
        carbs: 52,
        fat: 32,
        fiber: 5,
        sugar: 6,
      ),
      _SeedItem(
        name: 'Falafel Wrap',
        category: 'Wraps',
        description:
            'Crispy chickpea falafel wrapped in pita with tahini, fresh '
            'salad and pickled turnips.',
        price: 22,
        calories: 480,
        protein: 18,
        carbs: 60,
        fat: 18,
        fiber: 9,
        sugar: 5,
      ),
      _SeedItem(
        name: 'Hummus with Pita',
        category: 'Sides',
        description:
            'Creamy chickpea hummus drizzled with olive oil and paprika, '
            'served with warm pita bread.',
        price: 16,
        calories: 360,
        protein: 12,
        carbs: 44,
        fat: 14,
        fiber: 8,
        sugar: 3,
      ),
      _SeedItem(
        name: 'Tabbouleh Salad',
        category: 'Sides',
        description:
            'Fresh parsley, mint, tomato, cucumber and bulgur wheat tossed '
            'in lemon juice and olive oil.',
        price: 18,
        calories: 220,
        protein: 6,
        carbs: 28,
        fat: 10,
        fiber: 6,
        sugar: 4,
      ),
      _SeedItem(
        name: 'Baklava',
        category: 'Desserts',
        description:
            'Layers of flaky filo pastry filled with chopped walnuts and '
            'pistachios, soaked in honey syrup.',
        price: 14,
        calories: 320,
        protein: 4,
        carbs: 38,
        fat: 18,
        fiber: 2,
        sugar: 24,
      ),
    ],
  ),
];
