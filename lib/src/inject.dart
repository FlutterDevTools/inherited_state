import 'package:flutter/material.dart';
import 'package:inherited_state/src/inject_notifier.dart';

import 'inherited_inject.dart';
import 'state_controller.dart';

abstract class Injectable<T> {
  ///wrap with InheritedWidget
  Widget inheritedInject(Widget child);
  String get name;
  T get singleton;
  InjectNotifier<T> get notifier;
  StateController<T> get stateSingleton;
}

class Inject<T> implements Injectable<T> {
  factory Inject(T Function() creationFunction) {
    final val = creationFunction();
    return Inject._internal(val, InjectNotifier<T>(val));
  }

  Inject._internal(this._singleton, this._notifier);

  @override
  String get name => '$T';

  final InjectNotifier<T> _notifier;
  @override
  InjectNotifier<T> get notifier => _notifier;

  final T _singleton;

  /// state singleton
  StateController<T> _stateSingleton;

  @override
  T get singleton => _singleton;

  @override
  StateController<T> get stateSingleton {
    _stateSingleton ??= StateController<T>(this);
    return _stateSingleton;
  }

  @override
  Widget inheritedInject(Widget child) {
    return ValueListenableBuilder<T>(
      valueListenable: _notifier,
      builder: (ctx, _, __) {
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
