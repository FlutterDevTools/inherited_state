import 'package:flutter/material.dart';

import 'inject.dart';
import 'reactive_controller.dart';

class RS {
  static ReactiveController<T> get<T>([BuildContext context]) =>
      ReactiveState.get(context);
}

class IS {
  static T get<T>() => ImmutableState.get();
}

class ImmutableState {
  static T get<T>() => InheritedState.getImmutableState<T>().singleton;
}

class ReactiveState {
  static ReactiveController<T> get<T>([BuildContext context]) {
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
    return _InheritedState.reactiveSates[Inject.getName<T>()]?.last
        as Inject<T>;
  }

  static Inject<T> getImmutableState<T>() {
    return _InheritedState.immutableStates[Inject.getName<T>()]?.last
        as Inject<T>;
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
    _initStates(widget.reactives, _reactives, reactiveSates);
    _initStates(widget.immutables, _immutables, immutableStates);
  }

  static void _initStates(List<Injectable> widgetStates,
      List<Injectable> localStates, Map<String, List<Injectable>> allStates) {
    if (widgetStates != null) {
      localStates.addAll(widgetStates);
    }

    localStates.forEach((state) {
      assert(state != null);
      final name = state.name;
      if (allStates[name] == null) {
        allStates[name] = [state];
      } else {
        allStates[name].add(state);
      }
    });
  }

  @override
  void dispose() {
    _disposeStates(_reactives, reactiveSates);
    _disposeStates(_immutables, immutableStates);

    super.dispose();
  }

  static void _disposeStates(
      List<Injectable> states, Map<String, List<Injectable>> allStates) {
    states.forEach((state) {
      final name = state.name;
      allStates[name]?.remove(state);
      if (allStates[name].isEmpty) {
        allStates.remove(name);

        try {
          (state.singleton as dynamic)?.dispose();
        } catch (e) {
          if (e is! NoSuchMethodError) {
            rethrow;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget child = Builder(
      builder: (BuildContext context) {
        return widget.builder(context);
      },
    );

    return _reactives.reversed.fold(
      child,
      (child, inject) => inject.inheritedInject(child),
    );
  }
}
