class User {
  final int id;
  final String username;
  final DateTime createdAt;
  final double balance;

  const User({
    required this.id,
    required this.username,
    required this.createdAt,
    required this.balance,
  });

  User copyWith({
    String? username,
    double? balance,
  }) {
    return User(
      id: id,
      username: username ?? this.username,
      createdAt: createdAt,
      balance: balance ?? this.balance,
    );
  }
}
