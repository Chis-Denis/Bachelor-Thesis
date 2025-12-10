import 'package:flutter/material.dart';
import '../models/meal.dart';

class MealItem extends StatelessWidget {
  final Meal meal;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MealItem({
    super.key,
    required this.meal,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          '${meal.mealName} • ${meal.calories.toInt()} kcal',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'P ${meal.protein.toInt()}g • C ${meal.carbs.toInt()}g • F ${meal.fat.toInt()}g',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

