import 'package:flutter/material.dart';

import 'inject.dart';
import 'state_controller.dart';

class Injector extends StatefulWidget {
  const Injector.intenal({
    Key key,
    @required this.inject,
    @required this.builder,
  })  : assert(inject != null),
        assert(builder != null),
        super(key: key);

  final List<Injectable> inject;
  final Widget Function(BuildContext) builder;

  static T get<T>() {
    final inject = _getInject<T>();
    return inject.singleton;
  }

  static StateController<T> getWithController<T>({BuildContext context}) {
    final inject = _getInject<T>();
    if (context != null) inject.staticOf(context);
    return inject.stateSingleton;
  }

  static Inject<T> _getInject<T>() {
    return InjectorState.allRegisteredModelInApp['$T']?.last as Inject<T>;
  }

  @override
  State<Injector> createState() => InjectorState();
}

class InjectorState extends State<Injector> {
  static final Map<String, List<Inject<dynamic>>> allRegisteredModelInApp =
      <String, List<Inject<dynamic>>>{};
  List<Injectable> _injects = [];

  @override
  void initState() {
    super.initState();
    if (widget.inject != null) {
      _injects.addAll(widget.inject);
    }

    for (final inject in _injects) {
      assert(inject != null);
      final name = inject.name;
      if (allRegisteredModelInApp[name] == null) {
        allRegisteredModelInApp[name] = [inject];
      } else {
        allRegisteredModelInApp[name].add(inject);
      }
    }
  }

  @override
  void dispose() {
    for (final inject in _injects) {
      final name = inject.name;
      allRegisteredModelInApp[name]?.remove(inject);
      if (allRegisteredModelInApp[name].isEmpty) {
        allRegisteredModelInApp.remove(name);

        try {
          (inject.singleton as dynamic)?.dispose();
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
    var _nestedInject = Builder(
      builder: (BuildContext context) {
        return widget.builder(context);
      },
    );

    if (_injects.isNotEmpty) {
      for (Inject<dynamic> inject in _injects.reversed) {
        _nestedInject = inject.inheritedInject(_nestedInject);
      }
    }
    return _nestedInject;
  }
}
