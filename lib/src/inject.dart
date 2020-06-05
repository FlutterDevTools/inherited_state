import 'package:flutter/material.dart';

import 'inherited_inject.dart';
import 'state_controller.dart';

abstract class Injectable<T> {
  ///wrap with InheritedWidget
  Widget inheritedInject(Widget child);
  String get name;
  T get singleton;
  StateController<T> get stateSingleton;
}

class Inject<T> implements Injectable<T> {
  factory Inject(T Function() creationFunction) {
    final val = creationFunction();
    return Inject._internal(val, ValueNotifier<T>(val));
  }

  Inject._internal(this._singleton, this._notifier);

  String get name => '$T';

  final ValueNotifier<T> _notifier;
  final T _singleton;

  /// state singleton
  StateController<T> _stateSingleton;

  T get singleton => _singleton;

  StateController<T> get stateSingleton {
    _stateSingleton ??= StateController<T>(this);
    return _stateSingleton;
  }

  @override
  Widget inheritedInject(Widget child) {
    return ValueListenableBuilder(
      valueListenable: _notifier,
      child: child,
      builder: (ctx, _, child) {
        return InheritedInject<T>(
          child: child,
          getSingleton: () => stateSingleton,
        );
      },
    );
  }

  InheritedInject staticOf(BuildContext context) {
    final InheritedInject model =
        context.dependOnInheritedWidgetOfExactType<InheritedInject<T>>();
    return model;
  }
}
