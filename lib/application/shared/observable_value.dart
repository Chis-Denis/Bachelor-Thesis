import 'dart:async';

class ObservableValue<T> {
  T _value;
  final StreamController<T> _controller = StreamController<T>.broadcast();

  ObservableValue(this._value);

  T get value => _value;

  Stream<T> get changes => _controller.stream;

  set value(T next) {
    _value = next;
    _controller.add(next);
  }

  void dispose() {
    _controller.close();
  }
}
