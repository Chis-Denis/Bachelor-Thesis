const String _currencySuffix = 'lei';

String formatLei(double value) {
  final isWhole = value == value.roundToDouble();
  return isWhole
      ? '${value.toStringAsFixed(0)} $_currencySuffix'
      : '${value.toStringAsFixed(2)} $_currencySuffix';
}
