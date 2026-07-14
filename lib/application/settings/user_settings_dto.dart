import '../../domain/settings/food_unit.dart';
import '../../domain/settings/user_settings.dart';

class UserSettingsDto {
  final FoodUnit defaultUnit;

  const UserSettingsDto({required this.defaultUnit});

  factory UserSettingsDto.from(UserSettings settings) =>
      UserSettingsDto(defaultUnit: settings.defaultUnit);

  static const UserSettingsDto defaults =
      UserSettingsDto(defaultUnit: FoodUnit.grams);
}
