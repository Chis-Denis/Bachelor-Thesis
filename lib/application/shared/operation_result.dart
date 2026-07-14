class OperationResult<T> {
  final T? data;
  final String? error;

  const OperationResult.ok([this.data]) : error = null;

  const OperationResult.fail(this.error) : data = null;

  bool get isSuccess => error == null;
}
