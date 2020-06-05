import 'package:flutter/widgets.dart';

class InheritedInject<T> extends InheritedWidget {
  const InheritedInject({Key key, Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedInject<T> oldWidget) {
    return true;
  }
}
