import 'dart:async';
import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../repositories/meal_repository.dart';
import 'create_meal_screen.dart';
import 'meal_details_screen.dart';
import 'update_meal_screen.dart';
import '../widgets/meal_item.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final MealRepository _repository = MealRepository();
  List<Meal> _meals = [];
  bool _isLoading = true;
  late StreamSubscription<List<Meal>> _mealsSubscription;

  @override
  void initState() {
    super.initState();
    _loadInitialMeals();
    _mealsSubscription = _repository.mealsStream.listen((meals) {
      if (mounted) {
        setState(() {
          _meals = meals;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _loadInitialMeals() async {
    // Repository should be initialized in main.dart
    // But if initialization failed, try to initialize again and handle errors in this view
    try {
      if (!_repository.isInitialized) {
        // If not initialized (e.g., initialization failed in main.dart), try again
        await _repository.initialize();
      }
      // Get the meals that were loaded during initialization
      if (mounted) {
        setState(() {
          _meals = _repository.meals;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('MainScreen._loadInitialMeals() retrieve error: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _meals = _repository.meals; // Show whatever we have, even if empty
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading meals: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _mealsSubscription.cancel();
    super.dispose();
  }

  void _navigateToCreateMeal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateMealScreen()),
    );
  }

  void _navigateToMealDetails(Meal meal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MealDetailsScreen(mealId: meal.mealId),
      ),
    );
  }

  void _navigateToUpdateMeal(Meal meal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateMealScreen(mealId: meal.mealId),
      ),
    );
  }

  void _showDeleteDialog(Meal meal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete meal'),
          content: Text('Are you sure you want to delete ${meal.mealName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _repository.removeMealById(meal.mealId);
                } catch (e, stackTrace) {
                  debugPrint('MainScreen._showDeleteDialog() persistence error: $e');
                  debugPrint('Stack trace: $stackTrace');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting meal: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CalorieTrack'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _meals.isEmpty
              ? const Center(
                  child: Text(
                    'No meals yet.\nTap the + button to add one!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
              key: const Key('meals_list'),
              itemCount: _meals.length,
              itemBuilder: (context, index) {
                final meal = _meals[index];
                return MealItem(
                  key: ValueKey(meal.mealId),
                  meal: meal,
                  onTap: () => _navigateToMealDetails(meal),
                  onEdit: () => _navigateToUpdateMeal(meal),
                  onDelete: () => _showDeleteDialog(meal),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateMeal,
        tooltip: 'Add Meal',
        child: const Icon(Icons.add),
      ),
    );
  }
}

