
import 'inject.dart';

class ReactiveController<T> {
  ReactiveController(this._inject) : super();

  final Injectable<T> _inject;

  T get state => _inject.singleton;

  void setState(void Function(T) stateUpdateFn) {
    stateUpdateFn(state);
    _inject.notifier.value = state;
  }
}
