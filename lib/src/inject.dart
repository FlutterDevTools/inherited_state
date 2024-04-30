import 'package:flutter/material.dart';
import 'package:inherited_state/src/inject_notifier.dart';

import 'inherited_inject.dart';
import 'reactive_controller.dart';

abstract class Injectable<T> {
  Widget inheritedInject(Widget child);
  String get name;
  Type get type;
  T get singleton;
  set singleton(T value);
  InjectNotifier<T?> get notifier;
  ReactiveController<T> get stateSingleton;

  void disposeSingleton();
}

/// [Inject] is used to register a type to a defined model instance function for
/// reactive or immutable state management.
class Inject<T> implements Injectable<T> {
  /// Registers a type to an instance function which is exposed as a singleton
  /// to its descendants.
  ///
  /// The type can be registered as a reactive state or service object.
  /// The [_creationFunction] is called lazily and the instance value
  /// is stored for later access.
  Inject(this._creationFunction);

  final T Function() _creationFunction;

  @override
  String get name => getName<T>();

  static String getName<T>() => '$T';

  // ignore: null_check_always_fails
  final InjectNotifier<T?> _notifier = InjectNotifier<T?>(null);
  @override
  InjectNotifier<T?> get notifier => _notifier;

  @override
  Type get type => T;

  T? _singleton;

  ReactiveController<T>? _stateSingleton;

  @override
  T get singleton {
    if (_singleton != null) return _singleton!;
    singleton = _creationFunction();
    return _singleton!;
  }

  @override
  set singleton(T value) {
    _singleton = value;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _notifier.value = value);
  }

  @override
  ReactiveController<T> get stateSingleton =>
      _stateSingleton ??= ReactiveController<T>(this);

  @override
  Widget inheritedInject(Widget child) {
    return ValueListenableBuilder<T?>(
      valueListenable: _notifier,
      builder: (ctx, _, __) => InheritedInject<T>(
        child: child,
        injectable: this,
      ),
    );
  }

  static InheritedInject<T>? staticOf<T>(BuildContext context,
      [bool subscribe = false]) {
    if (subscribe) {
      return context.dependOnInheritedWidgetOfExactType<InheritedInject<T>>();
    } else {
      return context
          .getElementForInheritedWidgetOfExactType<InheritedInject<T>>()
          ?.widget as InheritedInject<T>;
    }
  }

  @override
  void disposeSingleton() {
    try {
      (singleton as dynamic)?.dispose();
    } catch (e) {
      if (e is! NoSuchMethodError) {
        rethrow;
      }
    }
  }
}
