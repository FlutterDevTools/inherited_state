import 'package:flutter/widgets.dart';

import 'inject.dart';

class InheritedInject<T> extends InheritedWidget {
  const InheritedInject({Key key, Widget child, @required this.injectable})
      : super(key: key, child: child);

  final Injectable<T> injectable;

  @override
  bool updateShouldNotify(InheritedInject<T> oldWidget) {
    return true;
  }
}
