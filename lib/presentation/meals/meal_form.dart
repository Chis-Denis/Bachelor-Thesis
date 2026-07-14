import 'package:flutter/material.dart';

import '../../application/meals/meal_type_view.dart';
import '../common/formatters/date_format.dart';
import '../common/formatters/meal_type_label.dart';
import '../design/design.dart';

const List<String> kUnitOptions = [
  'serving',
  'g',
  'ml',
  'piece',
  'cup',
  'tbsp',
  'tsp',
  'oz',
];

class MealFormControllers {
  final TextEditingController name;
  final TextEditingController quantity;
  final TextEditingController calories;
  final TextEditingController protein;
  final TextEditingController carbs;
  final TextEditingController fat;
  final TextEditingController fiber;
  final TextEditingController sugar;
  final TextEditingController notes;
  final ValueNotifier<MealTypeView> type;
  final ValueNotifier<String> unit;
  final ValueNotifier<DateTime?> date;
  final ValueNotifier<TimeOfDay?> time;

  MealFormControllers({
    String name = '',
    String quantity = '1',
    String calories = '',
    String protein = '',
    String carbs = '',
    String fat = '',
    String fiber = '',
    String sugar = '',
    String notes = '',
    MealTypeView type = MealTypeView.snack,
    String unit = 'serving',
    DateTime? date,
    TimeOfDay? time,
  })  : name = TextEditingController(text: name),
        quantity = TextEditingController(text: quantity),
        calories = TextEditingController(text: calories),
        protein = TextEditingController(text: protein),
        carbs = TextEditingController(text: carbs),
        fat = TextEditingController(text: fat),
        fiber = TextEditingController(text: fiber),
        sugar = TextEditingController(text: sugar),
        notes = TextEditingController(text: notes),
        type = ValueNotifier<MealTypeView>(type),
        unit = ValueNotifier<String>(unit),
        date = ValueNotifier<DateTime?>(date),
        time = ValueNotifier<TimeOfDay?>(time);

  void dispose() {
    name.dispose();
    quantity.dispose();
    calories.dispose();
    protein.dispose();
    carbs.dispose();
    fat.dispose();
    fiber.dispose();
    sugar.dispose();
    notes.dispose();
    type.dispose();
    unit.dispose();
    date.dispose();
    time.dispose();
  }
}

class MealFormFields extends StatelessWidget {
  final MealFormControllers controllers;
  final bool enabled;
  final VoidCallback onSubmit;
  final VoidCallback? onLookupNutrition;

  const MealFormFields({
    super.key,
    required this.controllers,
    required this.enabled,
    required this.onSubmit,
    this.onLookupNutrition,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: controllers.name,
          label: 'Food or meal name',
          enabled: enabled,
          textInputAction: TextInputAction.next,
          validator: _requiredText,
          suffix: _buildLookupSuffix(),
        ),
        const SizedBox(height: AppSpacing.md),
        _TypeField(type: controllers.type, enabled: enabled),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
                child: _DateField(date: controllers.date, enabled: enabled)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
                child: _TimeField(time: controllers.time, enabled: enabled)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _NumberField(
                controller: controllers.quantity,
                label: 'Quantity',
                enabled: enabled,
                validator: _positiveNumber,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
                child: _UnitField(unit: controllers.unit, enabled: enabled)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _NumberField(
                controller: controllers.calories,
                label: 'Calories',
                enabled: enabled,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _NumberField(
                controller: controllers.protein,
                label: 'Protein (g)',
                enabled: enabled,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _NumberField(
                controller: controllers.carbs,
                label: 'Carbs (g)',
                enabled: enabled,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _NumberField(
                controller: controllers.fat,
                label: 'Fat (g)',
                enabled: enabled,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _NumberField(
                controller: controllers.fiber,
                label: 'Fiber (g)',
                enabled: enabled,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _NumberField(
                controller: controllers.sugar,
                label: 'Sugar (g)',
                enabled: enabled,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: controllers.notes,
          label: 'Notes (optional)',
          enabled: enabled,
          maxLines: 3,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onSubmit(),
        ),
      ],
    );
  }

  Widget? _buildLookupSuffix() {
    if (onLookupNutrition == null) return null;
    return IconButton(
      icon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
      tooltip: 'Search foods',
      onPressed: enabled ? onLookupNutrition : null,
    );
  }
}

class _TypeField extends StatelessWidget {
  final ValueNotifier<MealTypeView> type;
  final bool enabled;

  const _TypeField({required this.type, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MealTypeView>(
      valueListenable: type,
      builder: (context, value, _) {
        return DropdownButtonFormField<MealTypeView>(
          initialValue: value,
          onChanged:
              enabled ? (selected) => type.value = selected ?? value : null,
          decoration: const InputDecoration(labelText: 'Type'),
          items: [
            for (final option in MealTypeView.values)
              DropdownMenuItem(
                value: option,
                child: Text(MealTypeLabel.text(option)),
              ),
          ],
        );
      },
    );
  }
}

class _UnitField extends StatelessWidget {
  final ValueNotifier<String> unit;
  final bool enabled;

  const _UnitField({required this.unit, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: unit,
      builder: (context, value, _) {
        final items = {...kUnitOptions, value}.toList();
        return DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          onChanged:
              enabled ? (selected) => unit.value = selected ?? value : null,
          decoration: const InputDecoration(labelText: 'Unit'),
          items: [
            for (final option in items)
              DropdownMenuItem(value: option, child: Text(option)),
          ],
        );
      },
    );
  }
}

class _DateField extends StatefulWidget {
  final ValueNotifier<DateTime?> date;
  final bool enabled;

  const _DateField({required this.date, required this.enabled});

  @override
  State<_DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<_DateField> {
  final _controller = TextEditingController();

  static const int _maxYearsBack = 5;

  @override
  void initState() {
    super.initState();
    _syncText(widget.date.value);
    widget.date.addListener(_onDateChanged);
  }

  @override
  void dispose() {
    widget.date.removeListener(_onDateChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onDateChanged() => _syncText(widget.date.value);

  void _syncText(DateTime? value) {
    _controller.text = value == null ? 'Today' : formatFullDate(value);
  }

  Future<void> _pick() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.date.value ?? now,
      firstDate: DateTime(now.year - _maxYearsBack),
      lastDate: now,
      helpText: 'Select date',
    );
    if (picked != null) widget.date.value = picked;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime?>(
      valueListenable: widget.date,
      builder: (context, value, _) {
        return AppTextField(
          controller: _controller,
          label: 'Date',
          enabled: widget.enabled,
          readOnly: true,
          onTap: _pick,
          suffix: value == null
              ? const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                )
              : IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: 'Reset to today',
                  onPressed:
                      widget.enabled ? () => widget.date.value = null : null,
                ),
        );
      },
    );
  }
}

class _TimeField extends StatefulWidget {
  final ValueNotifier<TimeOfDay?> time;
  final bool enabled;

  const _TimeField({required this.time, required this.enabled});

  @override
  State<_TimeField> createState() => _TimeFieldState();
}

class _TimeFieldState extends State<_TimeField> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _syncText(widget.time.value);
    widget.time.addListener(_onTimeChanged);
  }

  @override
  void dispose() {
    widget.time.removeListener(_onTimeChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTimeChanged() => _syncText(widget.time.value);

  void _syncText(TimeOfDay? value) {
    if (value == null) {
      _controller.text = 'Now';
    } else {
      final hour = value.hour.toString().padLeft(2, '0');
      final minute = value.minute.toString().padLeft(2, '0');
      _controller.text = '$hour:$minute';
    }
  }

  Future<void> _pick() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: widget.time.value ?? TimeOfDay.now(),
      helpText: 'Select time',
    );
    if (picked != null) widget.time.value = picked;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TimeOfDay?>(
      valueListenable: widget.time,
      builder: (context, value, _) {
        return AppTextField(
          controller: _controller,
          label: 'Time',
          enabled: widget.enabled,
          readOnly: true,
          onTap: _pick,
          suffix: value == null
              ? const Icon(
                  Icons.schedule,
                  size: 18,
                  color: AppColors.textSecondary,
                )
              : IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: 'Reset to now',
                  onPressed:
                      widget.enabled ? () => widget.time.value = null : null,
                ),
        );
      },
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool enabled;
  final String? Function(String?)? validator;

  const _NumberField({
    required this.controller,
    required this.label,
    required this.enabled,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: validator ?? _nonNegativeNumber,
    );
  }
}

String? _requiredText(String? value) {
  if (value == null || value.trim().isEmpty) return 'Required';
  return null;
}

String? _nonNegativeNumber(String? value) {
  if (value == null || value.trim().isEmpty) return 'Required';
  final parsed = double.tryParse(value);
  if (parsed == null) return 'Enter a valid number';
  if (parsed < 0) return 'Must be 0 or greater';
  return null;
}

String? _positiveNumber(String? value) {
  if (value == null || value.trim().isEmpty) return 'Required';
  final parsed = double.tryParse(value);
  if (parsed == null) return 'Enter a valid number';
  if (parsed <= 0) return 'Must be greater than 0';
  return null;
}
