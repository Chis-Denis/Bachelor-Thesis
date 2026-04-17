import 'package:flutter/foundation.dart';

import '../../../exceptions/app_exception.dart';
import '../entities/meal.dart';
import '../entities/meal_type.dart';
import 'meal_repository.dart';

class MealsController extends ChangeNotifier {
  final MealRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;

  MealsController(this._repository) {
    _repository.mealsListenable.addListener(_onMealsChanged);
  }

  List<Meal> get meals => _repository.meals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.load();
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> add({
    required String name,
    required MealType type,
    required double quantity,
    required String unit,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required double fiber,
    required double sugar,
    DateTime? date,
    String? notes,
  }) {
    return _run(() => _repository.add(
          name: name,
          type: type,
          quantity: quantity,
          unit: unit,
          calories: calories,
          protein: protein,
          carbs: carbs,
          fat: fat,
          fiber: fiber,
          sugar: sugar,
          date: date,
          notes: notes,
        ));
  }

  Future<bool> update(Meal meal) => _run(() => _repository.update(meal));

  Future<bool> remove(int id) => _run(() => _repository.remove(id));

  Future<Meal?> findById(int id) => _repository.findById(id);

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    try {
      await action();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
      notifyListeners();
      return false;
    }
  }

  void _onMealsChanged() => notifyListeners();

  @override
  void dispose() {
    _repository.mealsListenable.removeListener(_onMealsChanged);
    super.dispose();
  }
}
