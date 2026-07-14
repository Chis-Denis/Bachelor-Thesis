import '../shared/money.dart';

class RestaurantDraft {
  final String name;
  final String cuisine;
  final Money deliveryFee;
  final int estimatedMinutes;

  const RestaurantDraft({
    required this.name,
    required this.cuisine,
    required this.deliveryFee,
    required this.estimatedMinutes,
  });
}
