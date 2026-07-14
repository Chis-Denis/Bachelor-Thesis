class Numbers {
  Numbers._();

  static String quantity(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);

  static String macro(double value) {
    if (value.abs() < 0.05) return '0';
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(0);
  }

  static String serving(double value) => value == value.truncateToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
}
