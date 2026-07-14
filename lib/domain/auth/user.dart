import '../shared/money.dart';

class User {
  final int id;
  final String username;
  final DateTime createdAt;
  final Money balance;
  final bool isBusinessOwner;

  const User({
    required this.id,
    required this.username,
    required this.createdAt,
    required this.balance,
    required this.isBusinessOwner,
  });

  User withBalance(Money newBalance) => User(
        id: id,
        username: username,
        createdAt: createdAt,
        balance: newBalance,
        isBusinessOwner: isBusinessOwner,
      );
}
