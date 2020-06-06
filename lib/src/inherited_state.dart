import 'package:flutter/material.dart';

import 'inject.dart';
import 'reactive_controller.dart';

/// Alias for [ImmutableState]
class IS {
  /// Alias for [ImmutableState.get]
  static T get<T>() => ImmutableState.get();
}

/// [ImmutableState] is used to access immutable state instance of a given pre-registered type.
/// This instance is not reactive and is useful for accessing objects like services, configs, etc.
class ImmutableState {
  /// Provides a way to access a pre-registered instance of type [T].
  static T get<T>() => InheritedState.getImmutableState<T>().singleton;
}

/// Alias for [ReactiveState]
class RS {
  /// Alias for [ReactiveState.getReactive]
  static ReactiveController<T> getReactive<T>([BuildContext context]) =>
      ReactiveState.getReactive(context);

  /// Alias for [ReactiveState.get]
  static T get<T>([BuildContext context]) => ReactiveState.get(context);

  /// Alias for [ReactiveState.set]
  static T set<T>([dynamic Function(T) call]) => ReactiveState.set(call);
}

/// [ReactiveState] is used to access reactive state controller of a given pre-registered type.
/// This instance is reactive and is useful for updating all subscribers when
/// the [ReactiveController.setState] method is called.
class ReactiveState {
  /// Provides a way to access a pre-registered reactive controller instance of type [T].
  /// If an optional [context] is provided, the widget is subscribed and will update on
  /// all changes whenever the [ReactiveController.setState] method is called.
  static ReactiveController<T> getReactive<T>([BuildContext context]) {
    final state = InheritedState.getReactiveState<T>();
    if (context != null) state.staticOf(context);
    return state.stateSingleton;
  }

  /// Provides a way to access a pre-registered reactive instance of type [T].
  /// [context] must be provided so the widget is subscribed and will update on
  /// all changes whenever the [ReactiveController.setState] method is called.
  static T get<T>(BuildContext context) {
    final state = InheritedState.getReactiveState<T>();
    if (context != null) state.staticOf(context);
    return state.singleton;
  }

  /// Provides a shortcut for updating state of type [T].
  /// This update can be mutable or immutable depending on if the setter [call] method
  /// returns the same type.
  ///
  /// This calls the underlying [ReactiveController.setState] method to update the state.
  static T set<T>([dynamic Function(T) call]) {
    final value = RS.getReactive<T>();
    value.setState(call);
    return value.state;
  }
}

/// [InheritedState] is used to register reactive and immutable state functions that
/// can be used by the descendant widgets.
class InheritedState extends StatefulWidget {
  /// [InheritedState] is used to register reactive and immutable state functions that
  /// can be used by the descendant widgets.
  ///
  /// Both [reactives] and [immutables] accept a list of [Inject]s that essentially
  /// registers a instance creation function to be used when a state type is requested.
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

  // static getImmutableCollection() {
  //   return _InheritedState.immutableStates;
  // }
  static void replaceReactive<T>(T state) {
    final key = Inject.getName<T>();
    print('replace reactive: $key / $state');
    // check equality.
    _InheritedState.reactiveSates[key].forEach((injectable) {
      if (injectable.singleton.runtimeType == T &&
          injectable.singleton != state) {
        // todo: do we have to dispose previous?
        // injectable.singleton?.dispose();
        injectable.singleton = state;
      }
      print("injecttt: ${injectable.singleton}");
    });
    //  == state;
    // _InheritedState.replace<T>(state);
  }

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
      allStates[state.name] ??= [];
      allStates[state.name].add(state);
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
      final key = state.name;
      if (!allStates.containsKey(key)) return;
      allStates[key].remove(state);
      if (allStates[key].isEmpty) {
        allStates.remove(key);
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
