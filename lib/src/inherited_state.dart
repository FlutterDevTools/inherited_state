import 'package:flutter/material.dart';

import 'inject.dart';
import 'reactive_controller.dart';

class RS {
  static ReactiveController<T> get<T>({BuildContext context}) =>
      ReactiveState.get(context: context);
}

class IS {
  static T get<T>() => ImmutableState.get();
}

class ImmutableState {
  static T get<T>() => InheritedState.getImmutableState<T>().singleton;
}

class ReactiveState {
  static ReactiveController<T> get<T>({BuildContext context}) {
    final state = InheritedState.getReactiveState<T>();
    if (context != null) state.staticOf(context);
    return state.stateSingleton;
  }
}

class InheritedState extends StatefulWidget {
  const InheritedState({
    Key key,
    @required this.reactives,
    @required this.immutables,
    @required this.builder,
  })  : assert(reactives != null),
        assert(immutables != null),
        assert(builder != null),
        super(key: key);

  final List<Injectable> reactives;
  final List<Injectable> immutables;
  final Widget Function(BuildContext) builder;

  static Inject<T> getReactiveState<T>() {
    return _InheritedState.reactiveSates['$T']?.last as Inject<T>;
  }

  static Inject<T> getImmutableState<T>() {
    return _InheritedState.immutableStates['$T']?.last as Inject<T>;
  }

  @override
  State<InheritedState> createState() => _InheritedState();
}

class _InheritedState extends State<InheritedState> {
  static final Map<String, List<Injectable<dynamic>>> reactiveSates =
      <String, List<Injectable<dynamic>>>{};
  static final Map<String, List<Injectable<dynamic>>> immutableStates =
      <String, List<Injectable<dynamic>>>{};
  final _reactives = <Injectable>[];
  final _immutables = <Injectable>[];

  @override
  void initState() {
    super.initState();
    if (widget.reactives != null) {
      _reactives.addAll(widget.reactives);
    }

    if (widget.immutables != null) {
      _immutables.addAll(widget.immutables);
    }

    for (final state in _reactives) {
      assert(state != null);
      final name = state.name;
      if (reactiveSates[name] == null) {
        reactiveSates[name] = [state];
      } else {
        reactiveSates[name].add(state);
      }
    }
    for (final dependency in _immutables) {
      assert(dependency != null);
      final name = dependency.name;
      if (immutableStates[name] == null) {
        immutableStates[name] = [dependency];
      } else {
        immutableStates[name].add(dependency);
      }
    }
  }

  @override
  void dispose() {
    for (final state in _reactives) {
      final name = state.name;
      reactiveSates[name]?.remove(state);
      if (reactiveSates[name].isEmpty) {
        reactiveSates.remove(name);

        try {
          (state.singleton as dynamic)?.dispose();
        } catch (e) {
          if (e is! NoSuchMethodError) {
            rethrow;
          }
        }
      }
    }

    for (final dependency in _immutables) {
      final name = dependency.name;
      immutableStates[name]?.remove(dependency);
      if (immutableStates[name].isEmpty) {
        immutableStates.remove(name);

        try {
          (dependency.singleton as dynamic)?.dispose();
        } catch (e) {
          if (e is! NoSuchMethodError) {
            rethrow;
          }
        }
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget _nestedState = Builder(
      builder: (BuildContext context) {
        return widget.builder(context);
      },
    );

    if (_reactives.isNotEmpty) {
      for (final state in _reactives.reversed) {
        _nestedState = state.inheritedInject(_nestedState);
      }
    }
    return _nestedState;
  }
}
