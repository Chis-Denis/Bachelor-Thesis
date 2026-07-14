class Money implements Comparable<Money> {
  final double amount;

  const Money(this.amount);

  static const Money zero = Money(0);

  Money operator +(Money other) => Money(amount + other.amount);

  Money operator -(Money other) => Money(amount - other.amount);

  Money scale(double factor) => Money(amount * factor);

  bool get isNegative => amount < 0;

  bool operator <(Money other) => amount < other.amount;

  bool operator >(Money other) => amount > other.amount;

  @override
  int compareTo(Money other) => amount.compareTo(other.amount);

  @override
  bool operator ==(Object other) => other is Money && other.amount == amount;

  @override
  int get hashCode => amount.hashCode;
}
