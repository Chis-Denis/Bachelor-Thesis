import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../repositories/meal_repository.dart';

class UpdateMealScreen extends StatefulWidget {
  final int mealId;

  const UpdateMealScreen({super.key, required this.mealId});

  @override
  State<UpdateMealScreen> createState() => _UpdateMealScreenState();
}

class _UpdateMealScreenState extends State<UpdateMealScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _mealNameController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatController;
  late final TextEditingController _notesController;
  final MealRepository _repository = MealRepository();

  @override
  void initState() {
    super.initState();
    _loadMeal();
  }

  void _loadMeal() {
    final meal = _repository.findById(widget.mealId);
    if (meal != null) {
      _mealNameController = TextEditingController(text: meal.mealName);
      _caloriesController = TextEditingController(text: meal.calories.toString());
      _proteinController = TextEditingController(text: meal.protein.toString());
      _carbsController = TextEditingController(text: meal.carbs.toString());
      _fatController = TextEditingController(text: meal.fat.toString());
      _notesController = TextEditingController(text: meal.notes ?? '');
    } else {
      _mealNameController = TextEditingController();
      _caloriesController = TextEditingController();
      _proteinController = TextEditingController();
      _carbsController = TextEditingController();
      _fatController = TextEditingController();
      _notesController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _mealNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _updateMeal() async {
    if (_formKey.currentState!.validate()) {
      final meal = _repository.findById(widget.mealId);
      if (meal != null) {
        try {
          await _repository.updateMeal(
            meal.copyWith(
              mealName: _mealNameController.text.trim(),
              calories: double.parse(_caloriesController.text),
              protein: double.parse(_proteinController.text),
              carbs: double.parse(_carbsController.text),
              fat: double.parse(_fatController.text),
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
            ),
          );
          if (mounted) {
            Navigator.of(context).pop();
          }
        } catch (e, stackTrace) {
          debugPrint('UpdateMealScreen._updateMeal() persistence error: $e');
          debugPrint('Stack trace: $stackTrace');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error updating meal: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Meal'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _mealNameController,
              decoration: const InputDecoration(
                labelText: 'Meal Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _caloriesController,
              decoration: const InputDecoration(
                labelText: 'Calories',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _proteinController,
              decoration: const InputDecoration(
                labelText: 'Protein (g)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _carbsController,
              decoration: const InputDecoration(
                labelText: 'Carbs (g)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fatController,
              decoration: const InputDecoration(
                labelText: 'Fat (g)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _cancel,
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _updateMeal,
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

