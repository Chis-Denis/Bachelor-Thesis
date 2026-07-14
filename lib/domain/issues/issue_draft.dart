class IssueDraft {
  final int restaurantId;
  final int? orderId;
  final String description;
  final String imageRef;

  const IssueDraft({
    required this.restaurantId,
    required this.orderId,
    required this.description,
    required this.imageRef,
  });
}
