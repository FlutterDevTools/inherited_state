import 'package:flutter/foundation.dart';
import 'package:inherited_state/src/inherited_state.dart';

import 'inject.dart';

class ReactiveController<T> {
  ReactiveController(this._inject) : super();

  final Injectable<T> _inject;

  T get state => _inject.singleton;
  ValueListenable<T?> get stateListener => _inject.notifier;

  void setState(dynamic Function(T)? stateUpdateFn) {
    final dynamic updateResult = stateUpdateFn?.call(state);
    final newState = updateResult is T ? updateResult : state;
    if (newState != null) {
      InheritedState.replaceReactive(_inject, newState);
    }
  }
}
