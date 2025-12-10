import 'package:flutter/material.dart';
import '../repositories/meal_repository.dart';

class MealDetailsScreen extends StatelessWidget {
  final int mealId;

  const MealDetailsScreen({super.key, required this.mealId});

  @override
  Widget build(BuildContext context) {
    final repository = MealRepository();
    final meal = repository.findById(mealId);

    if (meal == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Meal Details'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: Text('Meal not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meal.mealName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${meal.calories.toInt()} kcal',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Protein ${meal.protein.toInt()}g  •  Carbs ${meal.carbs.toInt()}g  •  Fat ${meal.fat.toInt()}g',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            if (meal.notes != null && meal.notes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Notes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                meal.notes!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

