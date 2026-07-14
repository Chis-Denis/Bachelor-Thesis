class HashedPassword {
  final String salt;
  final String hash;

  const HashedPassword({required this.salt, required this.hash});
}
