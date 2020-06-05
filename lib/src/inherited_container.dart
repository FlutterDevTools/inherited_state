import 'package:flutter/material.dart';

import 'inject.dart';
import 'state_controller.dart';

class SC {
  static StateController<T> get<T>({BuildContext context}) =>
      StateContainer.get(context: context);
}

class DC {
  static T get<T>() => DependencyContainer.get();
}

class DependencyContainer {
  static T get<T>() {
    final inject = InheritedContainer.getDependency<T>();
    return inject.singleton;
  }
}

class StateContainer {
  static StateController<T> get<T>({BuildContext context}) {
    final inject = InheritedContainer.getStateInject<T>();
    if (context != null) inject.staticOf(context);
    return inject.stateSingleton;
  }
}

class InheritedContainer extends StatefulWidget {
  const InheritedContainer({
    Key key,
    @required this.inject,
    @required this.dependencies,
    @required this.builder,
  })  : assert(inject != null),
        assert(builder != null),
        super(key: key);

  final List<Injectable> inject;
  final List<Injectable> dependencies;
  final Widget Function(BuildContext) builder;

  static Inject<T> getStateInject<T>() {
    return InheritedContainerState.allRegisteredStateModelInApp['$T']?.last
        as Inject<T>;
  }

  static Inject<T> getDependency<T>() {
    return InheritedContainerState.allRegisteredModelInApp['$T']?.last
        as Inject<T>;
  }

  @override
  State<InheritedContainer> createState() => InheritedContainerState();
}

class InheritedContainerState extends State<InheritedContainer> {
  static final Map<String, List<Injectable<dynamic>>>
      allRegisteredStateModelInApp = <String, List<Injectable<dynamic>>>{};
  static final Map<String, List<Injectable<dynamic>>> allRegisteredModelInApp =
      <String, List<Injectable<dynamic>>>{};
  final _injects = <Injectable>[];
  final _dependencies = <Injectable>[];

  @override
  void initState() {
    super.initState();
    if (widget.inject != null) {
      _injects.addAll(widget.inject);
    }

    if (widget.dependencies != null) {
      _dependencies.addAll(widget.dependencies);
    }

    for (final inject in _injects) {
      assert(inject != null);
      final name = inject.name;
      if (allRegisteredStateModelInApp[name] == null) {
        allRegisteredStateModelInApp[name] = [inject];
      } else {
        allRegisteredStateModelInApp[name].add(inject);
      }
    }
    for (final dependency in _dependencies) {
      assert(dependency != null);
      final name = dependency.name;
      if (allRegisteredModelInApp[name] == null) {
        allRegisteredModelInApp[name] = [dependency];
      } else {
        allRegisteredModelInApp[name].add(dependency);
      }
    }
  }

  @override
  void dispose() {
    for (final inject in _injects) {
      final name = inject.name;
      allRegisteredStateModelInApp[name]?.remove(inject);
      if (allRegisteredStateModelInApp[name].isEmpty) {
        allRegisteredStateModelInApp.remove(name);

        try {
          (inject.singleton as dynamic)?.dispose();
        } catch (e) {
          if (e is! NoSuchMethodError) {
            rethrow;
          }
        }
      }
    }

    for (final dependency in _dependencies) {
      final name = dependency.name;
      allRegisteredModelInApp[name]?.remove(dependency);
      if (allRegisteredModelInApp[name].isEmpty) {
        allRegisteredModelInApp.remove(name);

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
    Widget _nestedInject = Builder(
      builder: (BuildContext context) {
        return widget.builder(context);
      },
    );

    if (_injects.isNotEmpty) {
      for (final inject in _injects.reversed) {
        _nestedInject = inject.inheritedInject(_nestedInject);
      }
    }
    return _nestedInject;
  }
}
