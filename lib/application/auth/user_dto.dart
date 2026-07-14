import '../../domain/auth/user.dart';

class UserDto {
  final int id;
  final String username;
  final DateTime createdAt;
  final double balance;
  final bool isBusinessOwner;

  const UserDto({
    required this.id,
    required this.username,
    required this.createdAt,
    required this.balance,
    required this.isBusinessOwner,
  });

  factory UserDto.fromDomain(User user) => UserDto(
        id: user.id,
        username: user.username,
        createdAt: user.createdAt,
        balance: user.balance.amount,
        isBusinessOwner: user.isBusinessOwner,
      );
}
