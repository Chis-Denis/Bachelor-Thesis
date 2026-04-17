String formatLei(double value) {
  final isWhole = value == value.roundToDouble();
  return isWhole
      ? '${value.toStringAsFixed(0)} lei'
      : '${value.toStringAsFixed(2)} lei';
}
