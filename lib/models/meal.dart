class Meal {
  final int mealId;
  final String mealName;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime date;
  final String? notes;

  Meal({
    required this.mealId,
    required this.mealName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.date,
    this.notes,
  });

  Meal copyWith({
    int? mealId,
    String? mealName,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    DateTime? date,
    String? notes,
  }) {
    return Meal(
      mealId: mealId ?? this.mealId,
      mealName: mealName ?? this.mealName,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  /// Convert Meal to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': mealId,
      'meal_name': mealName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'date': date.millisecondsSinceEpoch,
      'notes': notes,
    };
  }

  /// Create Meal from Map (from database)
  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      mealId: map['id'] as int,
      mealName: map['meal_name'] as String,
      calories: (map['calories'] as num).toDouble(),
      protein: (map['protein'] as num).toDouble(),
      carbs: (map['carbs'] as num).toDouble(),
      fat: (map['fat'] as num).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      notes: map['notes'] as String?,
    );
  }

  @override
  String toString() {
    return 'Meal(mealId: $mealId, mealName: $mealName, calories: $calories, date: $date)';
  }
}

