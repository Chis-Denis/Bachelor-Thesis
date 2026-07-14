import 'package:flutter/widgets.dart';

import 'app_dependencies.dart';

class AppScope extends InheritedWidget {
  final AppDependencies dependencies;

  const AppScope({
    super.key,
    required this.dependencies,
    required super.child,
  });

  static AppDependencies of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing from the widget tree');
    return scope!.dependencies;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      dependencies != oldWidget.dependencies;
}
