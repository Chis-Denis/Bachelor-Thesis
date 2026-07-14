import 'dart:async';

import 'package:flutter/material.dart';

import '../../application/meals/get_meal.dart';
import '../../application/meals/meal_dto.dart';
import '../../application/meals/meal_input.dart';
import '../../application/meals/update_meal.dart';
import '../../application/shared/macros_dto.dart';
import '../common/app_scope.dart';
import '../design/design.dart';
import 'meal_form.dart';

class UpdateMealScreen extends StatefulWidget {
  final int mealId;

  const UpdateMealScreen({super.key, required this.mealId});

  @override
  State<UpdateMealScreen> createState() => _UpdateMealScreenState();
}

class _UpdateMealScreenState extends State<UpdateMealScreen> {
  static const Duration _rescaleDelay = Duration(milliseconds: 400);

  final _formKey = GlobalKey<FormState>();

  late final GetMeal _getMeal;
  late final UpdateMeal _updateMeal;

  MealFormControllers? _controllers;
  MealDto? _meal;
  bool _isLoading = true;
  bool _submitting = false;
  String? _loadError;

  Timer? _scaleDebounce;
  double _baseQuantity = 0;
  MacrosDto _baseMacros = MacrosDto.zero;

  @override
  void initState() {
    super.initState();
    final deps = AppScope.of(context);
    _getMeal = deps.getMeal;
    _updateMeal = deps.updateMeal;
    _load();
  }

  @override
  void dispose() {
    _scaleDebounce?.cancel();
    _controllers?.quantity.removeListener(_onQuantityChanged);
    _controllers?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final result = await _getMeal(widget.mealId);
    if (!mounted) return;
    if (!result.isSuccess) {
      setState(() {
        _isLoading = false;
        _loadError = result.error;
      });
      return;
    }
    final meal = result.data;
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
      calories: _format(meal.macros.calories),
      protein: _format(meal.macros.protein),
      carbs: _format(meal.macros.carbs),
      fat: _format(meal.macros.fat),
      fiber: _format(meal.macros.fiber),
      sugar: _format(meal.macros.sugar),
      notes: meal.notes ?? '',
      date: meal.date,
      time: TimeOfDay.fromDateTime(meal.date),
    );
    setState(() {
      _meal = meal;
      _controllers = controllers;
      _baseQuantity = meal.quantity;
      _baseMacros = meal.macros;
      _isLoading = false;
    });
    controllers.quantity.addListener(_onQuantityChanged);
  }

  void _onQuantityChanged() {
    if (_baseQuantity <= 0) return;
    _scaleDebounce?.cancel();
    _scaleDebounce = Timer(_rescaleDelay, _rescaleMacros);
  }

  void _rescaleMacros() {
    final controllers = _controllers;
    if (controllers == null || !mounted || _baseQuantity <= 0) return;
    final quantity = double.tryParse(controllers.quantity.text);
    if (quantity == null || quantity <= 0) return;

    final ratio = quantity / _baseQuantity;
    controllers.calories.text = _format(_baseMacros.calories * ratio);
    controllers.protein.text = _format(_baseMacros.protein * ratio);
    controllers.carbs.text = _format(_baseMacros.carbs * ratio);
    controllers.fat.text = _format(_baseMacros.fat * ratio);
    controllers.fiber.text = _format(_baseMacros.fiber * ratio);
    controllers.sugar.text = _format(_baseMacros.sugar * ratio);
  }

  String _format(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);

  DateTime _combineDateTime(MealDto meal) {
    final controllers = _controllers!;
    final date = controllers.date.value ?? meal.date;
    final time = controllers.time.value ?? TimeOfDay.fromDateTime(meal.date);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _save() async {
    final meal = _meal;
    final controllers = _controllers;
    if (meal == null || controllers == null) return;
    if (!_formKey.currentState!.validate()) return;

    _scaleDebounce?.cancel();
    _rescaleMacros();

    setState(() => _submitting = true);
    final notes = controllers.notes.text.trim();
    final result = await _updateMeal(
      meal.id,
      MealInput(
        name: controllers.name.text.trim(),
        type: controllers.type.value,
        quantity: double.parse(controllers.quantity.text),
        unit: controllers.unit.value,
        macros: MacrosDto(
          calories: double.parse(controllers.calories.text),
          protein: double.parse(controllers.protein.text),
          carbs: double.parse(controllers.carbs.text),
          fat: double.parse(controllers.fat.text),
          fiber: double.parse(controllers.fiber.text),
          sugar: double.parse(controllers.sugar.text),
        ),
        date: _combineDateTime(meal),
        notes: notes.isEmpty ? null : notes,
      ),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (result.isSuccess) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? 'Could not update meal')),
      );
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
          AppButton(label: 'Save', onPressed: _save, isLoading: _submitting),
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
