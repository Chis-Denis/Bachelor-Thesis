import '../shared/observable_value.dart';
import 'meal_dto.dart';

class MealsStore {
  final ObservableValue<List<MealDto>> _meals =
      ObservableValue<List<MealDto>>(const []);

  ObservableValue<List<MealDto>> get meals => _meals;

  List<MealDto> get current => _meals.value;

  void set(List<MealDto> meals) => _meals.value = meals;

  void clear() => _meals.value = const [];

  void dispose() => _meals.dispose();
}
