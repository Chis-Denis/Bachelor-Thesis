import 'dart:async';

import 'package:flutter/foundation.dart';

abstract class ViewModel extends ChangeNotifier {
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  bool _disposed = false;

  void bind<T>(Stream<T> stream, void Function(T value) onData) {
    _subscriptions.add(stream.listen((value) {
      if (!_disposed) onData(value);
    }));
  }

  void notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}
