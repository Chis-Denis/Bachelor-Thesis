import '../../domain/shared/macros.dart';
import 'tables.dart';

class MacrosColumns {
  final String calories;
  final String protein;
  final String carbs;
  final String fat;
  final String fiber;
  final String sugar;

  const MacrosColumns({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
  });
}

class TableMacros {
  TableMacros._();

  static const MacrosColumns meals = MacrosColumns(
    calories: MealsTable.calories,
    protein: MealsTable.protein,
    carbs: MealsTable.carbs,
    fat: MealsTable.fat,
    fiber: MealsTable.fiber,
    sugar: MealsTable.sugar,
  );

  static const MacrosColumns foods = MacrosColumns(
    calories: FoodsTable.calories,
    protein: FoodsTable.protein,
    carbs: FoodsTable.carbs,
    fat: FoodsTable.fat,
    fiber: FoodsTable.fiber,
    sugar: FoodsTable.sugar,
  );

  static const MacrosColumns menuItems = MacrosColumns(
    calories: MenuItemsTable.calories,
    protein: MenuItemsTable.protein,
    carbs: MenuItemsTable.carbs,
    fat: MenuItemsTable.fat,
    fiber: MenuItemsTable.fiber,
    sugar: MenuItemsTable.sugar,
  );

  static const MacrosColumns orderItems = MacrosColumns(
    calories: OrderItemsTable.calories,
    protein: OrderItemsTable.protein,
    carbs: OrderItemsTable.carbs,
    fat: OrderItemsTable.fat,
    fiber: OrderItemsTable.fiber,
    sugar: OrderItemsTable.sugar,
  );
}

class MacrosRow {
  MacrosRow._();

  static Macros read(Map<String, Object?> row, MacrosColumns columns) => Macros(
        calories: _toDouble(row[columns.calories]),
        protein: _toDouble(row[columns.protein]),
        carbs: _toDouble(row[columns.carbs]),
        fat: _toDouble(row[columns.fat]),
        fiber: _toDouble(row[columns.fiber]),
        sugar: _toDouble(row[columns.sugar]),
      );

  static Map<String, Object?> toColumns(Macros macros, MacrosColumns columns) =>
      {
        columns.calories: macros.calories,
        columns.protein: macros.protein,
        columns.carbs: macros.carbs,
        columns.fat: macros.fat,
        columns.fiber: macros.fiber,
        columns.sugar: macros.sugar,
      };

  static double _toDouble(Object? value) => value is num ? value.toDouble() : 0;
}
