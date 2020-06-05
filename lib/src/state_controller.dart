
import 'inject.dart';

class StateController<T> {
  StateController(this._inject) : super();

  final Injectable<T> _inject;

  T get state => _inject.singleton;

  void setState(void Function(T) stateUpdateFn) {
    stateUpdateFn(state);
    _inject.notifier.value = state;
  }
}
