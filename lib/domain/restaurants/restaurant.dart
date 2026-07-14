import '../shared/money.dart';

class Restaurant {
  final int id;
  final String name;
  final String cuisine;
  final Money deliveryFee;
  final double rating;
  final int estimatedMinutes;
  final int? ownerUserId;

  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.deliveryFee,
    required this.rating,
    required this.estimatedMinutes,
    this.ownerUserId,
  });

  static const int defaultEstimatedMinutes = 30;
}
