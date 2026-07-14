import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../application/restaurants/menu_item_dto.dart';
import '../../../application/restaurants/menu_item_form_dto.dart';
import '../../../application/shared/macros_dto.dart';
import '../../common/app_scope.dart';
import '../../design/design.dart';
import 'menu_item_form_view_model.dart';

class MenuItemFormScreen extends StatefulWidget {
  final int restaurantId;
  final MenuItemDto? initial;

  const MenuItemFormScreen({
    super.key,
    required this.restaurantId,
    this.initial,
  });

  @override
  State<MenuItemFormScreen> createState() => _MenuItemFormScreenState();
}

class _MenuItemFormScreenState extends State<MenuItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _fields;
  late final MenuItemFormViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    final macros = initial?.macros;
    _fields = {
      'name': TextEditingController(text: initial?.name ?? ''),
      'description': TextEditingController(text: initial?.description ?? ''),
      'category': TextEditingController(text: initial?.category ?? ''),
      'price': TextEditingController(text: _num(initial?.price)),
      'calories': TextEditingController(text: _num(macros?.calories)),
      'protein': TextEditingController(text: _num(macros?.protein)),
      'carbs': TextEditingController(text: _num(macros?.carbs)),
      'fat': TextEditingController(text: _num(macros?.fat)),
      'fiber': TextEditingController(text: _num(macros?.fiber)),
      'sugar': TextEditingController(text: _num(macros?.sugar)),
    };
    final deps = AppScope.of(context);
    _viewModel = MenuItemFormViewModel(deps.addMenuItem, deps.updateMenuItem)
      ..addListener(_onChanged);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  String _num(double? value) => value == null || value == 0 ? '' : _trim(value);

  String _trim(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '$value';

  double _read(String key) => double.tryParse(_fields[key]!.text.trim()) ?? 0;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final form = MenuItemFormDto(
      name: _fields['name']!.text.trim(),
      description: _fields['description']!.text.trim(),
      category: _fields['category']!.text.trim(),
      price: _read('price'),
      macros: MacrosDto(
        calories: _read('calories'),
        protein: _read('protein'),
        carbs: _read('carbs'),
        fat: _read('fat'),
        fiber: _read('fiber'),
        sugar: _read('sugar'),
      ),
    );
    final success = await _viewModel.submit(
      restaurantId: widget.restaurantId,
      menuItemId: widget.initial?.id,
      form: form,
    );
    if (!mounted) return;
    if (!success) {
      final message = _viewModel.errorMessage ?? 'Could not save item';
      _viewModel.clearError();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final saving = _viewModel.isSaving;
    return AppScaffold(
      title: widget.initial == null ? 'Add item' : 'Edit item',
      showBack: true,
      maxWidth: AppSizes.formMaxWidth,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _fields['name']!,
                label: 'Item name',
                enabled: !saving,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _fields['description']!,
                label: 'Description',
                enabled: !saving,
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _fields['category']!,
                label: 'Category',
                helperText: 'e.g. Pizza, Sides, Desserts',
                enabled: !saving,
              ),
              const SizedBox(height: AppSpacing.md),
              _NumberField(
                  controller: _fields['price']!,
                  label: 'Price (lei)',
                  enabled: !saving),
              const SizedBox(height: AppSpacing.lg),
              _SectionLabel(label: 'Nutrition per serving'),
              const SizedBox(height: AppSpacing.sm),
              _NumberField(
                  controller: _fields['calories']!,
                  label: 'Calories (kcal)',
                  enabled: !saving),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                      child: _NumberField(
                          controller: _fields['protein']!,
                          label: 'Protein (g)',
                          enabled: !saving)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                      child: _NumberField(
                          controller: _fields['carbs']!,
                          label: 'Carbs (g)',
                          enabled: !saving)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                      child: _NumberField(
                          controller: _fields['fat']!,
                          label: 'Fat (g)',
                          enabled: !saving)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                      child: _NumberField(
                          controller: _fields['fiber']!,
                          label: 'Fiber (g)',
                          enabled: !saving)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _NumberField(
                  controller: _fields['sugar']!,
                  label: 'Sugar (g)',
                  enabled: !saving),
              const SizedBox(height: AppSpacing.lg),
              AppButton(label: 'Save', onPressed: _save, isLoading: saving),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool enabled;

  const _NumberField({
    required this.controller,
    required this.label,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTypography.subheading);
  }
}
