class Restaurant {
  final int id;
  final String name;
  final String cuisine;
  final double deliveryFee;
  final double rating;
  final int estimatedMinutes;

  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.deliveryFee,
    required this.rating,
    required this.estimatedMinutes,
  });
}
