import '../shared/macros_dto.dart';

class MenuItemFormDto {
  final String name;
  final String description;
  final String category;
  final double price;
  final MacrosDto macros;

  const MenuItemFormDto({
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.macros,
  });
}
