import 'food_unit.dart';

class UserSettings {
  final int userId;
  final FoodUnit defaultUnit;

  const UserSettings({
    required this.userId,
    required this.defaultUnit,
  });

  static UserSettings defaults(int userId) => UserSettings(
        userId: userId,
        defaultUnit: FoodUnit.grams,
      );
}
