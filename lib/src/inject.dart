import 'package:flutter/material.dart';
import 'package:inherited_state/src/inject_notifier.dart';

import 'inherited_inject.dart';
import 'reactive_controller.dart';

abstract class Injectable<T> {
  Widget inheritedInject(Widget child);
  String get name;
  T get singleton;
  InjectNotifier<T> get notifier;
  ReactiveController<T> get stateSingleton;
}

class Inject<T> implements Injectable<T> {
  Inject(this._creationFunction);

  final T Function() _creationFunction;

  @override
  String get name => '$T';

  final InjectNotifier<T> _notifier = InjectNotifier<T>(null);
  @override
  InjectNotifier<T> get notifier => _notifier;

  T _singleton;

  ReactiveController<T> _stateSingleton;

  @override
  T get singleton {
    _singleton ??= _creationFunction();
    return _singleton;
  }

  @override
  ReactiveController<T> get stateSingleton {
    _stateSingleton ??= ReactiveController<T>(this);
    return _stateSingleton;
  }

  @override
  Widget inheritedInject(Widget child) {
    return ValueListenableBuilder<T>(
      valueListenable: _notifier,
      builder: (ctx, _, __) {
        return InheritedInject<T>(
          child: child,
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
