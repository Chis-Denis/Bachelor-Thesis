import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? helperText;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<String>? autofillHints;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;
  final int? maxLines;
  final bool readOnly;
  final bool autofocus;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.helperText,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.onSubmitted,
    this.onChanged,
    this.suffix,
    this.maxLines = 1,
    this.readOnly = false,
    this.autofocus = false,
    this.onTap,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      readOnly: readOnly,
      onTap: enabled ? onTap : null,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      onChanged: onChanged,
      autofocus: autofocus,
      inputFormatters: inputFormatters,
      maxLines: obscureText ? 1 : maxLines,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        suffixIcon: suffix,
      ),
    );
  }
}
