abstract interface class UnitOfWork {
  Future<T> execute<T>(Future<T> Function() action);
}
