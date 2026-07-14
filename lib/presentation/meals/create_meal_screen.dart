import 'dart:async';

import 'package:flutter/material.dart';

import '../../application/foods/food_dto.dart';
import '../../application/meals/add_meal.dart';
import '../../application/meals/meal_input.dart';
import '../../application/meals/meal_type_view.dart';
import '../../application/shared/macros_dto.dart';
import '../common/app_scope.dart';
import '../design/design.dart';
import '../foods/food_search_screen.dart';
import 'meal_form.dart';

class CreateMealScreen extends StatefulWidget {
  const CreateMealScreen({super.key});

  @override
  State<CreateMealScreen> createState() => _CreateMealScreenState();
}

class _CreateMealScreenState extends State<CreateMealScreen> {
  static const Duration _rescaleDelay = Duration(milliseconds: 400);

  final _formKey = GlobalKey<FormState>();
  final _controllers = MealFormControllers(
    type: MealTypeView.defaultForHour(DateTime.now().hour),
    fiber: '0',
    sugar: '0',
  );

  late final AddMeal _addMeal;
  bool _submitting = false;
  FoodDto? _baseFood;
  Timer? _scaleDebounce;

  @override
  void initState() {
    super.initState();
    _addMeal = AppScope.of(context).addMeal;
    _controllers.quantity.addListener(_onQuantityChanged);
  }

  @override
  void dispose() {
    _scaleDebounce?.cancel();
    _controllers.quantity.removeListener(_onQuantityChanged);
    _controllers.dispose();
    super.dispose();
  }

  Future<void> _openSearch() async {
    final picked = await Navigator.of(context).push<FoodDto>(
      MaterialPageRoute(
        builder: (_) =>
            FoodSearchScreen(initialQuery: _controllers.name.text.trim()),
      ),
    );
    if (picked == null || !mounted) return;

    _baseFood = picked;
    _controllers.name.text = picked.name;
    _controllers.unit.value = picked.servingUnit;
    _setQuantitySilently(_format(picked.servingSize));
    _controllers.calories.text = _format(picked.macros.calories);
    _controllers.protein.text = _format(picked.macros.protein);
    _controllers.carbs.text = _format(picked.macros.carbs);
    _controllers.fat.text = _format(picked.macros.fat);
    _controllers.fiber.text = _format(picked.macros.fiber);
    _controllers.sugar.text = _format(picked.macros.sugar);
  }

  void _setQuantitySilently(String value) {
    _controllers.quantity.removeListener(_onQuantityChanged);
    _controllers.quantity.text = value;
    _controllers.quantity.addListener(_onQuantityChanged);
  }

  void _onQuantityChanged() {
    if (_baseFood == null) return;
    _scaleDebounce?.cancel();
    _scaleDebounce = Timer(_rescaleDelay, _rescaleMacros);
  }

  void _rescaleMacros() {
    final base = _baseFood;
    if (base == null || !mounted) return;
    final quantity = double.tryParse(_controllers.quantity.text);
    if (quantity == null || quantity <= 0 || base.servingSize <= 0) return;

    final ratio = quantity / base.servingSize;
    _controllers.calories.text = _format(base.macros.calories * ratio);
    _controllers.protein.text = _format(base.macros.protein * ratio);
    _controllers.carbs.text = _format(base.macros.carbs * ratio);
    _controllers.fat.text = _format(base.macros.fat * ratio);
    _controllers.fiber.text = _format(base.macros.fiber * ratio);
    _controllers.sugar.text = _format(base.macros.sugar * ratio);
  }

  String _format(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);

  DateTime? _combineDateTime() {
    final date = _controllers.date.value;
    final time = _controllers.time.value;
    if (date == null && time == null) return null;
    final now = DateTime.now();
    final datePart = date ?? DateTime(now.year, now.month, now.day);
    final timePart = time ?? TimeOfDay.fromDateTime(now);
    return DateTime(
      datePart.year,
      datePart.month,
      datePart.day,
      timePart.hour,
      timePart.minute,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final notes = _controllers.notes.text.trim();
    final result = await _addMeal(MealInput(
      name: _controllers.name.text.trim(),
      type: _controllers.type.value,
      quantity: double.parse(_controllers.quantity.text),
      unit: _controllers.unit.value,
      macros: _readMacros(),
      date: _combineDateTime(),
      notes: notes.isEmpty ? null : notes,
    ));

    if (!mounted) return;
    setState(() => _submitting = false);
    if (result.isSuccess) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? 'Could not save meal')),
      );
    }
  }

  MacrosDto _readMacros() => MacrosDto(
        calories: double.parse(_controllers.calories.text),
        protein: double.parse(_controllers.protein.text),
        carbs: double.parse(_controllers.carbs.text),
        fat: double.parse(_controllers.fat.text),
        fiber: double.parse(_controllers.fiber.text),
        sugar: double.parse(_controllers.sugar.text),
      );

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Add meal',
      showBack: true,
      maxWidth: AppSizes.formMaxWidth,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            MealFormFields(
              controllers: _controllers,
              enabled: !_submitting,
              onSubmit: _save,
              onLookupNutrition: _openSearch,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: 'Save', onPressed: _save, isLoading: _submitting),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'Cancel',
              variant: AppButtonVariant.secondary,
              onPressed: _submitting ? null : () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
