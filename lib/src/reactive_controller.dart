import 'package:inherited_state/src/inherited_state.dart';

import 'inject.dart';

class ReactiveController<T> {
  ReactiveController(this._inject) : super();

  final Injectable<T> _inject;

  T get state => _inject.singleton;

  void setState(dynamic Function(T) stateUpdateFn) {
    final dynamic newState = stateUpdateFn(state);
    if (newState?.runtimeType == T) {
      _inject.notifier.value = newState as T;
      InheritedState.replaceReactive(newState as T);
    } else {
      _inject.notifier.value = state;
    }
  }
}
