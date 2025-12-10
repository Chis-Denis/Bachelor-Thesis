import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/meal.dart';
import '../database/database_helper.dart';

/// Repository for managing meals with database persistence
class MealRepository {
  static final MealRepository _instance = MealRepository._internal();
  factory MealRepository() => _instance;
  MealRepository._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final List<Meal> _meals = [];
  bool _isInitialized = false;
  final _mealsController = StreamController<List<Meal>>.broadcast();

  Stream<List<Meal>> get mealsStream => _mealsController.stream;

  List<Meal> get meals => List.unmodifiable(_meals);

  /// Check if repository is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the repository by loading meals from the database
  /// Call this once at app startup
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await loadMeals();
      _isInitialized = true;
    } catch (e, stackTrace) {
      debugPrint('MealRepository.initialize() error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Load all meals from the database
  Future<void> loadMeals() async {
    try {
      final meals = await _dbHelper.getAllMeals();
      _meals.clear();
      _meals.addAll(meals);
      _notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('MealRepository.loadMeals() error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Add a new meal to the database
  Future<Meal> addMeal({
    required String mealName,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    DateTime? date,
    String? notes,
  }) async {
    try {
      final meal = Meal(
        mealId: 0, // Will be set by database
        mealName: mealName,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        date: date ?? DateTime.now(),
        notes: notes,
      );

      // Insert into database
      final id = await _dbHelper.insertMeal(meal);
      
      // Create meal with the database-generated ID
      final savedMeal = meal.copyWith(mealId: id);
      
      // Add to in-memory list
      _meals.add(savedMeal);
      _notifyListeners();
      
      return savedMeal;
    } catch (e, stackTrace) {
      debugPrint('MealRepository.addMeal() error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Update an existing meal in the database
  Future<void> updateMeal(Meal updatedMeal) async {
    try {
      // Update in database
      await _dbHelper.updateMeal(updatedMeal);
      
      // Update in-memory list
      final index = _meals.indexWhere((m) => m.mealId == updatedMeal.mealId);
      if (index != -1) {
        _meals[index] = updatedMeal;
        _notifyListeners();
      }
    } catch (e, stackTrace) {
      debugPrint('MealRepository.updateMeal() error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Remove a meal from the database
  Future<void> removeMealById(int id) async {
    try {
      // Delete from database
      await _dbHelper.deleteMeal(id);
      
      // Remove from in-memory list
      _meals.removeWhere((m) => m.mealId == id);
      _notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('MealRepository.removeMealById() error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Find a meal by its ID (synchronous for backward compatibility)
  /// Note: This searches the in-memory list. For fresh data, use findByIdAsync
  Meal? findById(int id) {
    try {
      return _meals.firstWhere((m) => m.mealId == id);
    } catch (e) {
      return null;
    }
  }

  /// Find a meal by its ID from the database (async)
  Future<Meal?> findByIdAsync(int id) async {
    try {
      return await _dbHelper.getMealById(id);
    } catch (e) {
      return null;
    }
  }

  /// Get the count of meals
  Future<int> getMealCount() async {
    return await _dbHelper.getMealCount();
  }

  void _notifyListeners() {
    _mealsController.add(List.unmodifiable(_meals));
  }

  /// Dispose resources
  void dispose() {
    _mealsController.close();
  }
}
