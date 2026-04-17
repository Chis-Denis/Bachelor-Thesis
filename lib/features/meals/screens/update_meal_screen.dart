import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/service_locator.dart';
import '../../../design/design.dart';
import '../entities/meal.dart';
import 'meal_form_fields.dart';

class UpdateMealScreen extends StatefulWidget {
  final int mealId;
  const UpdateMealScreen({super.key, required this.mealId});

  @override
  State<UpdateMealScreen> createState() => _UpdateMealScreenState();
}

class _UpdateMealScreenState extends State<UpdateMealScreen> {
  final _formKey = GlobalKey<FormState>();

  MealFormControllers? _controllers;
  Meal? _meal;
  bool _isLoading = true;
  bool _submitting = false;
  String? _loadError;

  Timer? _scaleDebounce;
  double _baseQuantity = 0;
  double _baseCalories = 0;
  double _baseProtein = 0;
  double _baseCarbs = 0;
  double _baseFat = 0;
  double _baseFiber = 0;
  double _baseSugar = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final meal = await mealsController.findById(widget.mealId);
      if (!mounted) return;
      if (meal == null) {
        setState(() {
          _isLoading = false;
          _loadError = 'Meal not found';
        });
        return;
      }
      final controllers = MealFormControllers(
        name: meal.name,
        type: meal.type,
        quantity: _format(meal.quantity),
        unit: meal.unit,
        calories: _format(meal.calories),
        protein: _format(meal.protein),
        carbs: _format(meal.carbs),
        fat: _format(meal.fat),
        fiber: _format(meal.fiber),
        sugar: _format(meal.sugar),
        notes: meal.notes ?? '',
        date: meal.date,
        time: TimeOfDay.fromDateTime(meal.date),
      );
      setState(() {
        _meal = meal;
        _controllers = controllers;
        _baseQuantity = meal.quantity;
        _baseCalories = meal.calories;
        _baseProtein = meal.protein;
        _baseCarbs = meal.carbs;
        _baseFat = meal.fat;
        _baseFiber = meal.fiber;
        _baseSugar = meal.sugar;
        _isLoading = false;
      });
      controllers.quantity.addListener(_onQuantityChanged);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Error loading meal: $e';
      });
    }
  }

  void _onQuantityChanged() {
    if (_baseQuantity <= 0) return;
    _scaleDebounce?.cancel();
    _scaleDebounce = Timer(const Duration(milliseconds: 400), _rescaleMacros);
  }

  void _rescaleMacros() {
    final c = _controllers;
    if (c == null || !mounted) return;
    if (_baseQuantity <= 0) return;
    final qty = double.tryParse(c.quantity.text);
    if (qty == null || qty <= 0) return;

    final ratio = qty / _baseQuantity;
    c.calories.text = _format(_baseCalories * ratio);
    c.protein.text = _format(_baseProtein * ratio);
    c.carbs.text = _format(_baseCarbs * ratio);
    c.fat.text = _format(_baseFat * ratio);
    c.fiber.text = _format(_baseFiber * ratio);
    c.sugar.text = _format(_baseSugar * ratio);
  }

  String _format(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }

  DateTime _combineDateTime(Meal meal) {
    final c = _controllers!;
    final d = c.date.value ?? meal.date;
    final t = c.time.value ?? TimeOfDay.fromDateTime(meal.date);
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  @override
  void dispose() {
    _scaleDebounce?.cancel();
    _controllers?.quantity.removeListener(_onQuantityChanged);
    _controllers?.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final meal = _meal;
    final c = _controllers;
    if (meal == null || c == null) return;
    if (!_formKey.currentState!.validate()) return;

    _scaleDebounce?.cancel();
    _rescaleMacros();

    setState(() => _submitting = true);
    final notes = c.notes.text.trim();
    final ok = await mealsController.update(meal.copyWith(
      name: c.name.text.trim(),
      type: c.type.value,
      quantity: double.parse(c.quantity.text),
      unit: c.unit.value,
      calories: double.parse(c.calories.text),
      protein: double.parse(c.protein.text),
      carbs: double.parse(c.carbs.text),
      fat: double.parse(c.fat.text),
      fiber: double.parse(c.fiber.text),
      sugar: double.parse(c.sugar.text),
      date: _combineDateTime(meal),
      notes: notes.isEmpty ? null : notes,
    ));
    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      Navigator.of(context).pop();
    } else {
      final err = mealsController.errorMessage ?? 'Could not update meal';
      mealsController.clearError();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Edit meal',
      showBack: true,
      maxWidth: AppSizes.formMaxWidth,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? Center(
                  child: Text(
                    _loadError!,
                    style: AppTypography.bodyMuted,
                    textAlign: TextAlign.center,
                  ),
                )
              : _buildForm(),
    );
  }

  Widget _buildForm() {
    final controllers = _controllers!;
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          MealFormFields(
            controllers: controllers,
            enabled: !_submitting,
            onSubmit: _save,
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
            onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
