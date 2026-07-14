import '../shared/macros.dart';
import '../shared/money.dart';

class MenuItemDraft {
  final int restaurantId;
  final String name;
  final String description;
  final String category;
  final Money price;
  final Macros macros;

  const MenuItemDraft({
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.macros,
  });
}
