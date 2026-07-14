import 'failures.dart';

class Quantity {
  final double value;

  const Quantity._(this.value);

  factory Quantity(double value) {
    if (value <= 0) {
      throw const ValidationFailure('Quantity must be greater than 0');
    }
    return Quantity._(value);
  }

  @override
  bool operator ==(Object other) => other is Quantity && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
