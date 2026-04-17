import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/service_locator.dart';
import '../../../design/design.dart';
import '../../foods/entities/food.dart';
import '../../foods/screens/food_search_screen.dart';
import '../entities/meal_type.dart';
import 'meal_form_fields.dart';

class CreateMealScreen extends StatefulWidget {
  const CreateMealScreen({super.key});

  @override
  State<CreateMealScreen> createState() => _CreateMealScreenState();
}

class _CreateMealScreenState extends State<CreateMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = MealFormControllers(
    type: MealType.defaultForHour(DateTime.now().hour),
    fiber: '0',
    sugar: '0',
  );

  bool _submitting = false;

  Food? _baseFood;
  Timer? _scaleDebounce;

  @override
  void initState() {
    super.initState();
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
    final picked = await Navigator.of(context).push<Food>(
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
    _controllers.calories.text = _format(picked.calories);
    _controllers.protein.text = _format(picked.protein);
    _controllers.carbs.text = _format(picked.carbs);
    _controllers.fat.text = _format(picked.fat);
    _controllers.fiber.text = _format(picked.fiber);
    _controllers.sugar.text = _format(picked.sugar);
  }

  void _setQuantitySilently(String value) {
    _controllers.quantity.removeListener(_onQuantityChanged);
    _controllers.quantity.text = value;
    _controllers.quantity.addListener(_onQuantityChanged);
  }

  void _onQuantityChanged() {
    if (_baseFood == null) return;
    _scaleDebounce?.cancel();
    _scaleDebounce = Timer(const Duration(milliseconds: 400), _rescaleMacros);
  }

  void _rescaleMacros() {
    final base = _baseFood;
    if (base == null || !mounted) return;
    final qty = double.tryParse(_controllers.quantity.text);
    if (qty == null || qty <= 0) return;
    if (base.servingSize <= 0) return;

    final ratio = qty / base.servingSize;
    _controllers.calories.text = _format(base.calories * ratio);
    _controllers.protein.text = _format(base.protein * ratio);
    _controllers.carbs.text = _format(base.carbs * ratio);
    _controllers.fat.text = _format(base.fat * ratio);
    _controllers.fiber.text = _format(base.fiber * ratio);
    _controllers.sugar.text = _format(base.sugar * ratio);
  }

  String _format(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }

  DateTime? _combineDateTime() {
    final d = _controllers.date.value;
    final t = _controllers.time.value;
    if (d == null && t == null) return null;
    final now = DateTime.now();
    final datePart = d ?? DateTime(now.year, now.month, now.day);
    final timePart = t ?? TimeOfDay.fromDateTime(now);
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
    final ok = await mealsController.add(
      name: _controllers.name.text.trim(),
      type: _controllers.type.value,
      quantity: double.parse(_controllers.quantity.text),
      unit: _controllers.unit.value,
      calories: double.parse(_controllers.calories.text),
      protein: double.parse(_controllers.protein.text),
      carbs: double.parse(_controllers.carbs.text),
      fat: double.parse(_controllers.fat.text),
      fiber: double.parse(_controllers.fiber.text),
      sugar: double.parse(_controllers.sugar.text),
      date: _combineDateTime(),
      notes: notes.isEmpty ? null : notes,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      Navigator.of(context).pop();
    } else {
      final err = mealsController.errorMessage ?? 'Could not save meal';
      mealsController.clearError();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _submitting;
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
              enabled: !busy,
              onSubmit: _save,
              onLookupNutrition: _openSearch,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Save',
              onPressed: _save,
              isLoading: _submitting,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'Cancel',
              variant: AppButtonVariant.secondary,
              onPressed: busy ? null : () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
