import 'package:flutter/widgets.dart';

import 'app_state.dart';

/// Exposes the shared [AppState] down the tree. Access with `AppScope.of(context)`.
class AppScope extends InheritedWidget {
  final AppState state;

  const AppScope({super.key, required this.state, required super.child});

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in the widget tree');
    return scope!.state;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => oldWidget.state != state;
}
