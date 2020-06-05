import 'package:flutter/widgets.dart';

import 'inject.dart';

class StateController<T> {
  const StateController(this._inject);

  final Inject<T> _inject;

  T get state => _inject.singleton;

  void setState(VoidCallback stateUpdateFn) {}
}
