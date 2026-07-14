import '../../domain/restaurants/menu_item.dart';
import '../shared/macros_dto.dart';

class MenuItemDto {
  final int id;
  final int restaurantId;
  final String name;
  final String description;
  final String category;
  final double price;
  final MacrosDto macros;

  const MenuItemDto({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.macros,
  });

  factory MenuItemDto.fromDomain(MenuItem item) => MenuItemDto(
        id: item.id,
        restaurantId: item.restaurantId,
        name: item.name,
        description: item.description,
        category: item.category,
        price: item.price.amount,
        macros: MacrosDto.fromDomain(item.macros),
      );
}
