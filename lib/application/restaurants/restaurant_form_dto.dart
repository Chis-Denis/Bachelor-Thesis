class RestaurantFormDto {
  final String name;
  final String cuisine;
  final double deliveryFee;
  final int estimatedMinutes;

  const RestaurantFormDto({
    required this.name,
    required this.cuisine,
    required this.deliveryFee,
    required this.estimatedMinutes,
  });
}
