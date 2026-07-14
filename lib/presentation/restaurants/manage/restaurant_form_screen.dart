import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../application/restaurants/restaurant_dto.dart';
import '../../../application/restaurants/restaurant_form_dto.dart';
import '../../../domain/restaurants/restaurant.dart';
import '../../common/app_scope.dart';
import '../../design/design.dart';
import 'restaurant_form_view_model.dart';

class RestaurantFormScreen extends StatefulWidget {
  final RestaurantDto? initial;

  const RestaurantFormScreen({super.key, this.initial});

  @override
  State<RestaurantFormScreen> createState() => _RestaurantFormScreenState();
}

class _RestaurantFormScreenState extends State<RestaurantFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _cuisine;
  late final TextEditingController _deliveryFee;
  late final TextEditingController _estMinutes;
  late final RestaurantFormViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _name = TextEditingController(text: initial?.name ?? '');
    _cuisine = TextEditingController(text: initial?.cuisine ?? '');
    _deliveryFee = TextEditingController(
        text: initial == null ? '' : initial.deliveryFee.toStringAsFixed(0));
    _estMinutes = TextEditingController(
        text: (initial?.estimatedMinutes ?? Restaurant.defaultEstimatedMinutes)
            .toString());
    _viewModel = RestaurantFormViewModel(AppScope.of(context).saveMyRestaurant)
      ..addListener(_onChanged);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _name.dispose();
    _cuisine.dispose();
    _deliveryFee.dispose();
    _estMinutes.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final form = RestaurantFormDto(
      name: _name.text.trim(),
      cuisine: _cuisine.text.trim(),
      deliveryFee: double.tryParse(_deliveryFee.text.trim()) ?? 0,
      estimatedMinutes: int.tryParse(_estMinutes.text.trim()) ??
          Restaurant.defaultEstimatedMinutes,
    );
    final success = await _viewModel.save(form);
    if (!mounted) return;
    if (!success) {
      final message = _viewModel.errorMessage ?? 'Could not save restaurant';
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
      title: widget.initial == null ? 'Create restaurant' : 'Edit restaurant',
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
                controller: _name,
                label: 'Restaurant name',
                enabled: !saving,
                validator: _required,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _cuisine,
                label: 'Cuisine',
                helperText: 'e.g. Italian, Vegan, BBQ',
                enabled: !saving,
                validator: _required,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _deliveryFee,
                label: 'Delivery fee (lei)',
                enabled: !saving,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _estMinutes,
                label: 'Estimated delivery (minutes)',
                enabled: !saving,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(label: 'Save', onPressed: _save, isLoading: saving),
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Required' : null;
}
