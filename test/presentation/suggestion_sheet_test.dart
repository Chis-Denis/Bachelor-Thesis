import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calorietrack_flutter/application/shared/operation_result.dart';
import 'package:calorietrack_flutter/application/suggestions/meal_suggestion_dto.dart';
import 'package:calorietrack_flutter/application/suggestions/suggest_meals.dart';
import 'package:calorietrack_flutter/presentation/suggestions/suggestion_sheet.dart';

class _FakeSuggestMeals implements SuggestMeals {
  final Completer<OperationResult<List<MealSuggestionDto>>> _completer =
      Completer<OperationResult<List<MealSuggestionDto>>>();

  void resolveWith(OperationResult<List<MealSuggestionDto>> result) =>
      _completer.complete(result);

  @override
  Future<OperationResult<List<MealSuggestionDto>>> call() => _completer.future;
}

MealSuggestionDto _suggestion({
  required int id,
  required String itemName,
  String restaurantName = 'Test Kitchen',
  String category = 'Mains',
  double price = 24.5,
  double calories = 620,
  String reason = 'High in protein for your muscle-gain goal',
}) {
  return MealSuggestionDto(
    menuItemId: id,
    restaurantId: 1,
    restaurantName: restaurantName,
    itemName: itemName,
    category: category,
    price: price,
    calories: calories,
    reason: reason,
  );
}

Widget _host(SuggestMeals suggestMeals,
    {void Function(MealSuggestionDto)? onSelect}) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: ElevatedButton(
            onPressed: () => showSuggestionSheet(
              context,
              suggestMeals: suggestMeals,
              onSelect: onSelect ?? (_) {},
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('SuggestionSheet', () {
    testWidgets('shows a loading indicator while suggestions are fetched',
        (tester) async {
      final suggestMeals = _FakeSuggestMeals();
      await tester.pumpWidget(_host(suggestMeals));

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Finding your best matches…'), findsOneWidget);

      suggestMeals.resolveWith(const OperationResult.ok(<MealSuggestionDto>[]));
      await tester.pumpAndSettle();
    });

    testWidgets('renders the ranked suggestions once they arrive',
        (tester) async {
      final suggestMeals = _FakeSuggestMeals();
      await tester.pumpWidget(_host(suggestMeals));

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      suggestMeals.resolveWith(OperationResult.ok([
        _suggestion(id: 1, itemName: 'Grilled Chicken Bowl'),
        _suggestion(id: 2, itemName: 'Salmon Poke', price: 31),
      ]));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Grilled Chicken Bowl'), findsOneWidget);
      expect(find.text('Salmon Poke'), findsOneWidget);
      expect(
        find.text('High in protein for your muscle-gain goal'),
        findsNWidgets(2),
      );
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('shows the error message and a retry action on failure',
        (tester) async {
      final suggestMeals = _FakeSuggestMeals();
      await tester.pumpWidget(_host(suggestMeals));

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      suggestMeals.resolveWith(
        const OperationResult.fail('No suitable meals were found.'),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('No suitable meals were found.'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('reports the tapped suggestion through onSelect',
        (tester) async {
      final suggestMeals = _FakeSuggestMeals();
      MealSuggestionDto? selected;
      await tester.pumpWidget(
        _host(suggestMeals, onSelect: (suggestion) => selected = suggestion),
      );

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      suggestMeals.resolveWith(OperationResult.ok([
        _suggestion(id: 7, itemName: 'Grilled Chicken Bowl'),
      ]));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Grilled Chicken Bowl'));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.menuItemId, 7);
    });
  });
}
