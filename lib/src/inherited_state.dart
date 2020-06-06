import 'package:flutter/material.dart';

import 'inject.dart';
import 'reactive_controller.dart';

/// Alias for [InheritedService]
class IS {
  /// Alias for [InheritedService.get]
  static T get<T>() => InheritedService.get();
}

/// [InheritedService] is used to access a service class instance of a given pre-registered type.
/// This instance is not reactive and is useful for accessing objects like services, configs, etc.
class InheritedService {
  /// Provides a way to access a pre-registered instance of type [T].
  static T get<T>() => InheritedState.getService<T>().singleton;
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
  /// returns the same type as [T].
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
    @required this.services,
    @required this.builder,
  })  : assert(reactives != null),
        assert(services != null),
        assert(builder != null),
        super(key: key);

  final List<Injectable> reactives;
  final List<Injectable> services;
  final Widget Function(BuildContext) builder;

  static void replaceReactive<T>(T state) {
    final key = Inject.getName<T>();
    print('replace reactive: $key / $state');
    // check equality.
    _InheritedState.reactiveSates[key].forEach((injectable) {
      if (injectable.singleton.runtimeType == T &&
          injectable.singleton != state) {
        injectable.dispose();
        injectable.singleton = state;
      }
      print('inject: ${injectable.singleton}');
    });
    //  == state;
    // _InheritedState.replace<T>(state);
  }

  static Inject<T> getReactiveState<T>() {
    return _InheritedState.reactiveSates[Inject.getName<T>()]?.last
        as Inject<T>;
  }

  static Inject<T> getService<T>() {
    return _InheritedState.services[Inject.getName<T>()]?.last as Inject<T>;
  }

  @override
  State<InheritedState> createState() => _InheritedState();
}

class _InheritedState extends State<InheritedState> {
  static final Map<String, List<Injectable<dynamic>>> reactiveSates =
      <String, List<Injectable<dynamic>>>{};
  static final Map<String, List<Injectable<dynamic>>> services =
      <String, List<Injectable<dynamic>>>{};
  final _reactives = <Injectable>[];
  final _services = <Injectable>[];

  @override
  void initState() {
    super.initState();
    _initStates(widget.reactives, _reactives, reactiveSates);
    _initStates(widget.services, _services, services);
  }

  static void _initStates(
      List<Injectable> widgetInjectables,
      List<Injectable> localInjectables,
      Map<String, List<Injectable>> allInjectables) {
    if (widgetInjectables != null) {
      localInjectables.addAll(widgetInjectables);
    }

    localInjectables.forEach((injectable) {
      assert(injectable != null);
      allInjectables[injectable.name] ??= [];
      allInjectables[injectable.name].add(injectable);
    });
  }

  @override
  void dispose() {
    _disposeStates(_reactives, reactiveSates);
    _disposeStates(_services, services);

    super.dispose();
  }

  static void _disposeStates(List<Injectable> injectables,
      Map<String, List<Injectable>> allInjectables) {
    injectables.forEach((injectable) {
      final key = injectable.name;
      if (!allInjectables.containsKey(key)) return;
      allInjectables[key].remove(injectable);
      if (allInjectables[key].isEmpty) {
        allInjectables.remove(key);
        injectable.dispose();
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
